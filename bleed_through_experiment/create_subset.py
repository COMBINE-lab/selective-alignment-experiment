from __future__ import print_function
import pandas as pd
from tqdm import tqdm
from collections import defaultdict
import itertools
from Bio import SeqIO
import sys
import click
import os
import json
import pickle

def getKmerScores(fastafile):
    """
    Generate the graph for k-mer similarity
    Input: Fasta file

    return objects:
    transcript_lengths: dict tname -> length 
    graph: defaultdict(list) Adjacency list 
    kmer_map: defaultdict(set) kmer -> [t1,t2,...]
    kmer_sim_score: dict (t1,t2) -> Num of kmers common in both

    """
    #background = "/mnt/scratch1/bleed_through_mouse/ref/Trinity.fasta"
    threshold = 1
    background = fastafile
    k=31
    kmer_map = defaultdict(set)
    graph = defaultdict(list)
    kmer_sim_score = {}
    transcript_lengths = {}

    record = (r for r in SeqIO.parse(background, "fasta"))
    counter = 0
    for r in record:
        tname = str(r.id)
        tseq = str(r.seq)
        transcript_lengths[tname] = len(tseq)
        for i in xrange(len(tseq)-k+1):
            if(len(tseq[i:i+k]) == 31):
                kmer_map[tseq[i:i+k]].add(tname)
        counter += 1
        if(counter%1000 == 0):
            sys.stdout.write("\r%d transcripts seen"%counter)
            sys.stdout.flush()
        
    for tr in tqdm(transcript_lengths.keys()):
        graph[tr] = []

    for _,l in tqdm(kmer_map.items()):
        if len(l) > threshold:
            for subset in itertools.combinations(l,2):
                if not subset in kmer_sim_score:
                    t1, t2 = subset
                    graph[t1].append(t2)
                    graph[t2].append(t1)
                    kmer_sim_score[subset] = 1
                else:
                    kmer_sim_score[subset] += 1
    
    for subset,score in kmer_sim_score.items():
        t1,t2 = subset
        kmer_sim_score[subset] = float(score) / float(transcript_lengths[t1] + transcript_lengths[t2] - 2*k + 2) 

    return transcript_lengths, kmer_sim_score, graph

def writeSampledFasta(infile, outfile, transcript_lengths, df, graph, samp):
    """

    present_tr: set of transcripts that are present
    used_tr: set of transcripts that are used
    df: dataframe that stores kmer_sim_score | (t1,t2) | count |
    """

    
    #The covering algorithm
    #should take care of length 
    #distribution
    used_tr = {}
    present_tr = {}
    for tr in tqdm(transcript_lengths.keys()):
        used_tr[tr] = False

    if samp == 1:
        # Edge cover sampling 
        # select an edge make sure not to select
        # any other edges 
        for t1, t2 in tqdm(df['index'].values):
            if not used_tr[t1] and not used_tr[t2]:
                present_tr[t1] = True
                used_tr[t1] = True
                for t in graph[t1]:
                    used_tr[t] = True
    elif samp == 2:
        # Normal vertex cover sampling
        for t1, t2 in tqdm(df['index'].values):
            if not used_tr[t1] or not used_tr[t2]:
                if not used_tr[t1] :
                    present_tr[t1] = True
                    used_tr[t1] = True
                    for t in graph[t1]:
                        used_tr[t] = True
                elif not used_tr[t2] : 
                    present_tr[t2] = True
                    used_tr[t2] = True 
                    for t in graph[t2]:
                        used_tr[t] = True
    else:
        # Sparse edge cover sampling 
        # select an edge make sure not to select
        # any other edges 
        for t1, t2 in tqdm(df['index'].values):
            if not used_tr[t1] and not used_tr[t2]:
                present_tr[t1] = True
                used_tr[t1] = True
                used_tr[t2] = True
                for t in graph[t1]:
                    used_tr[t] = True
                for t in graph[t2]:
                    used_tr[t] = True
        
    #write the subset fasta file 
    record = (r for r in SeqIO.parse(infile, "fasta") \
          if r.id in present_tr)
    _ = SeqIO.write(record, outfile , "fasta")
    return present_tr, used_tr

def generateStat(transcript_lengths,kmer_map):
    tid_to_uniq_kmer = {}
    for k,l in tqdm(transcript_lengths.iteritems()):
        tid_to_uniq_kmer[k] = 0
    for k,tset in tqdm(kmer_map.iteritems()):
        for t in tset:
            if(len(tset) == 1):
                tid_to_uniq_kmer[t] += 1
    tid_to_uniq_kmer_frac = {}
    k=31
    for t,n in tqdm(tid_to_uniq_kmer.iteritems()):
        if(transcript_lengths[t]-k+1 >= 31):
            tid_to_uniq_kmer_frac[t] = float(n)/float(transcript_lengths[t]-k+1)
        else:
            tid_to_uniq_kmer_frac[t] = 0
    return tid_to_uniq_kmer_frac

#TODO multi-threading
@click.command()
@click.option('--fasta',  help='input')
@click.option('--prefix',  help='prefix for the output')
@click.option('--subset',  is_flag=True, help='write fasta file', default=False)
@click.option('--seed', type = int, help='seed value for randomization', default = 314)
@click.option('--samp', type = int, help='Type of smapling 1: Dense 2: Edge cover 3: Sparse cover')
#@click.option('--threshold',  help='threshold')


def run(fasta, prefix, subset, seed, samp):
    print("Constructing the graph for {}".format(fasta))
    #sort by kmer counts 
    transcript_lengths,kmer_sim_score,graph = None, None, None 
    df = pd.DataFrame()
    if os.path.exists(prefix + '/kmer_sim.pkl') and os.path.exists(prefix + '/transcript_length.json') \
         and os.path.exists(prefix + '/graph.json')  :
        transcript_lengths = json.load(open(prefix + "/transcript_length.json"))
        graph = json.load(open(prefix + "/graph.json"))
        kmer_sim_score = pickle.load(open(prefix + "/kmer_sim.pkl","rb"))


    else:
        transcript_lengths,kmer_sim_score,graph = getKmerScores(fasta)
        print("Writing kmer_sim, graph, transcript lengths .... finishing")
        #df.to_csv( prefix+'/kmer_sim.tsv',sep='\t',index=False)
        with open (prefix + "/kmer_sim.pkl", "wb") as fp:
            pickle.dump(kmer_sim_score,fp)
        with open(prefix + '/transcript_length.json' , "w") as fp:
            json.dump(transcript_lengths,fp)
        with open(prefix + '/graph.json' , "w") as fp:
            json.dump(graph,fp)

        
    if(len(kmer_sim_score) > 0):
        df = pd.DataFrame.from_dict(kmer_sim_score, orient='index')
    else:
        return None,None,None
    df.columns = ['count']
    df.sort_values(by=['count'], ascending=False,inplace=True)
    df.reset_index(level=0, inplace=True)

    import sys 
    if not subset:
        click.echo("Only kmer similarity would be written ",nl=True)
        sys.exit(0)

    if subset:
        out = prefix+"/subset_"+str(samp)+"_"+str(seed)+".fasta"
        present_tr,used_tr = writeSampledFasta(fasta,out, transcript_lengths, df, graph, samp)
        print ("Percent of Bleed Through {}".format(float(len(present_tr))/float(len(used_tr))))


if __name__=="__main__":
    run()
    
