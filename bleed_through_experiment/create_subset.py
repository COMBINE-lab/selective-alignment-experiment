from __future__ import print_function
import pandas as pd
from tqdm import tqdm
from collections import defaultdict
import itertools
from Bio import SeqIO
import sys
import click

def getKmerScores(fastafile):
    #background = "/mnt/scratch1/bleed_through_mouse/ref/Trinity.fasta"
    threshold = 1
    background = fastafile
    k=31
    kmer_map = defaultdict(set)
    graph = defaultdict(list)
    transcript_lengths = {}

    record = (r for r in SeqIO.parse(background, "fasta"))
    counter = 0
    for r in record:
        tname = str(r.id)
        tseq = str(r.seq)
        transcript_lengths[tname] = len(tseq)
        for i in xrange(len(tseq)-k):
            if(len(tseq[i:i+k]) == 31):
                kmer_map[tseq[i:i+k]].add(tname)
        counter += 1
        if(counter%1000 == 0):
            sys.stdout.write("\r%d transcripts seen"%counter)
            sys.stdout.flush()
    for tr in tqdm(transcript_lengths.keys()):
        graph[tr] = []
    kmer_sim_score = {}
    for k,l in tqdm(kmer_map.items()):
        if len(l) > threshold:
            for subset in itertools.combinations(l,2):
                if not subset in kmer_sim_score:
                    t1, t2 = subset
                    graph[t1].append(t2)
                    graph[t2].append(t1)
                    kmer_sim_score[subset] = 1
                else:
                    kmer_sim_score[subset] += 1
    return transcript_lengths,kmer_map,kmer_sim_score,graph

def writeSampledFasta(infile,outfile,transcript_lengths,kmer_sim_score,graph):
    df = pd.DataFrame()
    if(len(kmer_sim_score) > 0):
        df = pd.DataFrame.from_dict(kmer_sim_score, orient='index')
    else:
        return None,None,None
    df.columns = ['count']
    df.sort_values(by=['count'], ascending=False,inplace=True)
    df.reset_index(level=0, inplace=True)
    
    used_tr = {}
    for tr in tqdm(transcript_lengths.keys()):
        used_tr[tr] = False
    present_tr = {}
    for t1, t2 in tqdm(df['index'].values):
        if not used_tr[t1] and not used_tr[t2]:
            present_tr[t1] = True
            used_tr[t1] = True
            for t in graph[t1]:
                used_tr[t] = True
    from Bio import SeqIO
    record = (r for r in SeqIO.parse(infile, "fasta") \
          if r.id in present_tr)
    count = SeqIO.write(record, outfile , "fasta")
    return present_tr,used_tr,df

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

@click.command()
@click.option('--fasta',  help='input')
@click.option('--out',  help='outfile')
@click.option('--stat',  is_flag=True, help='calculate stat', default=False)
@click.option('--plot',  is_flag=True, help='plot k-mer dist', default=False)
#@click.option('--threshold',  help='threshold')

def run(fasta, out, stat, plot):
    print("Constructing the graph for {}".format(fasta))

    transcript_lengths,kmer_map,kmer_sim_score,graph = getKmerScores(fasta)
    present_tr,used_tr,df = writeSampledFasta(fasta,out, transcript_lengths, kmer_sim_score, graph)

    print ("Percent of Bleed Through {}".format(float(len(present_tr))/float(len(used_tr))))

    print("Writing edge table .... finishing")
    dirn = os.path.dirname(out)
    df.to_csv( dirn+'/kmer_sim.tsv',sep='\t',index=False)

if __name__=="__main__":
    run()
    
