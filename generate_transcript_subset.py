import sys, os
import pandas as pd
from collections import defaultdict
from Bio import SeqIO

gid_tid_file = sys.argv[1]
tid_list = sys.argv[2]
transcriptome_file = sys.argv[3]
gene_prob = sys.argv[4]
tr_prob = sys.argv[5]
total_prob = float(gene_prob) * float(tr_prob)

df = pd.read_table(gid_tid_file,header=None,names=['gid','tid'])
pdtid = pd.read_table(tid_list,header=None,names=['tid'])
df2 = df[df['tid'].isin(pdtid['tid'])]

gid_tid = defaultdict(list)
for row in df2.itertuples():
    gid_tid[row.gid].append(row.tid)

background = []
for g,tlist in gid_tid.iteritems():
    if len(tlist) > 1:
        for t in tlist:
            background.append(t)
print len(background)

import random
import tqdm
tokeep = []
groundset = []
gene_prob = float(gene_prob)/100
tr_prob = float(tr_prob)/100
for g,tlist in tqdm.tqdm(gid_tid.iteritems()):
    if len(tlist) > 1:
        if(random.random() <= gene_prob):
            for t in tlist:
                if(random.random() <= tr_prob):
                    tokeep.append(t)
                groundset.append(t)

print len(tokeep)
subset_transcriptome_file = os.path.join(os.path.dirname(transcriptome_file),"transcriptome_"+str(int(total_prob/100))+".fa")
subset_gid_tid_file = os.path.join(os.path.dirname(gid_tid_file),"gid_tid_"+str(int(total_prob/100))+".txt")

df3 = df2.loc[df2['tid'].isin(tokeep)]
df3.to_csv(subset_gid_tid_file,sep="\t",header=False,index=False)

record = (r for r in SeqIO.parse(transcriptome_file,"fasta") if r.id in tokeep)
count = SeqIO.write(record,subset_transcriptome_file,"fasta")
