import matplotlib
matplotlib.use('PDF')
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
import pandas as pd
import numpy as np
import scipy.stats
import math
import seaborn as sns
#from sets import Set

def filterValues(colname, DF, val):
    DF.loc[DF[colname] < val, colname] = 0.0

def relError(c1, c2, DF, cutoff=0.00999999, verbose=False):
    import pandas as pd
    import numpy as np
    nz = DF[DF[c1] > cutoff]
    re = (nz[c1] - nz[c2]) / nz[c1]
    return re

def proportionalityCorrelation(c1, c2, DF, offset=0.01):
    import numpy as np
    return (2.0 * np.log(DF[c1] + offset).cov(np.log(DF[c2] + offset))) / (np.log(DF[c1] + offset).var() + np.log(DF[c2] + offset).var())

def relDiffTP(c1, c2, DF, cutoff=0.1):
    import pandas as pd
    import numpy as np
    tpindex = DF[DF[c1] > cutoff]
    rd = (tpindex[c2] - tpindex[c1]) / tpindex[c1]
    return rd

def getMedian(df): return df.mean()
def getMean(df): return df.mean()

def relDiff(c1, c2, DF, cutoff=0.01, verbose=False):
    import pandas as pd
    """
    Computes the relative difference between the values
    in columns c1 and c2 of DF.
    c1 and c2 are column names and DF is a Pandas data frame.
    Values less than cutoff will be treated as 0.
    The relative difference is defined as
    d(x_i, y_i) =
        0.0 if x_i and y_i are 0
        (x_i - y_i) / (0.5 * |x_i - y_i|) otherwise
    This function returns two values.
    rd is a DataFrame where the "relDiff" column contains all
    of the computed relative differences.
    nz is a set of indexes into rd for data points where
    x_i and y_i were not *both* zero.
    """
    import numpy as np
    rd = pd.DataFrame(data = {"Name" : DF.index, "relDiff" : np.zeros(len(DF.index))*np.nan})
    rd.set_index("Name", inplace=True)
    bothZero = DF.loc[(DF[c1] <= cutoff) & (DF[c2] <= cutoff)].index
    nonZero = DF.index.difference(bothZero)
    if (verbose):
        print("Zero occurs in both columns {} times".format(len(rd.loc[bothZero])))
        print("Nonzero occurs in at least 1 column {} times".format(len(rd.loc[nonZero])))
    allRD = 1.0 * ((DF[c1] - DF[c2]) / (DF[c1] + DF[c2]).abs())
    assert(len(rd.loc[nonZero]["relDiff"]) == len(allRD[nonZero]))
    rd["relDiff"][nonZero] = allRD[nonZero]
    if len(bothZero) > 0:
        rd["relDiff"][bothZero] = 0.0
    return rd, nonZero



cutoff = 0.0

method_count = 5 
sample_count = 5.0
MARDS = [[0 for x in range(method_count)] for y in range(method_count)]
spearmans = [[0 for x in range(method_count)] for y in range(method_count)]

for i in range(5996,int(5996+sample_count)) :
    sample_name = "./samples/SRR121" + str(i)
    print (sample_name)

    kallisto = pd.read_table(sample_name+"/result.kallisto/abundance.tsv",names=['Name','length','efflength','NumReads','tpm'],index_col="Name",header=1)
    hera = pd.read_table(sample_name+"/result.hera1.2/abundance.tsv",names=["Name","uMap",'length','efflength',"NumReads","tpm"],index_col="Name",header=1)
    sla = pd.read_table(sample_name+"/result.SLA09/quant.sf",index_col="Name")
    star = pd.read_table(sample_name+"/result.star.quant/quant.sf",index_col="Name")
    bowtie = pd.read_table(sample_name+"/result.bowtie2.quant/quant.sf",index_col="Name")

    methods = {}
    methods[0] = kallisto
    methods[1] = hera
    methods[2] = sla
    methods[3] = star
    methods[4] = bowtie

    for j in range(method_count):
        for k in range(method_count):
            method1 = methods[j]
            method2 = methods[k]
            #print (j,k)
            join = method1.join(method2,rsuffix="_t").fillna(0.0)
            rd, nonZero =  relDiff('NumReads', 'NumReads_t', join, cutoff)
            MARDS[j][k] += np.mean(rd['relDiff'].abs())

            spearmans[j][k] += scipy.stats.spearmanr(join['NumReads'],join['NumReads_t']).correlation

for i in range(method_count):
    MARDS[i] = [ x/sample_count for x in MARDS[i] ]

np.savetxt("MARDS.txt",MARDS,delimiter='\t', header='kallisto,hera,sla,star,bowtie',newline='\n')

for i in range(method_count):
    spearmans[i] = [ x/sample_count for x in spearmans[i] ]

np.savetxt("spearmans.txt",spearmans,delimiter='\t', header='kallisto,hera,sla,star,bowtie',newline='\n')

quit()




