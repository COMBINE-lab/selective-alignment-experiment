import numpy as np
import pandas as pd

import scipy.stats
import math
import click



def getMergedDataFrameFast(typeof,files):
    truth = pd.read_table(files[typeof]["truth"], delim_whitespace=True, \
       usecols=["transcript_id", "count"])
    df = truth
    df.rename(index=str, \
            columns={"transcript_id": "Name", "count": "count"}, inplace = True)
    
    sla = pd.read_table(files[typeof]["SLA"], delim_whitespace=True, \
                                 usecols=["Name", "NumReads"])
    df = pd.merge(df,sla, how="outer", on = "Name").fillna(0.0)
    
    kallisto = pd.read_table(files[typeof]["kallisto"], delim_whitespace=True, \
                                     usecols=["target_id", "est_counts"])
    kallisto.rename(index=str, columns={"target_id": "Name", \
                                                "est_counts": "NumReads_KAL"}, inplace = True)
    df = pd.merge(df,kallisto, how="outer", on = "Name").fillna(0.0)
    
    hera = pd.read_table(files[typeof]["hera"], delim_whitespace=True, \
                                     usecols=["#target_id", "est_counts"])
    hera["#target_id"]= hera["#target_id"].str.split(":",expand=True)[0]
    hera.rename(index=str, columns={"#target_id": "Name", \
                                               "est_counts": "NumReads_hera"}, inplace = True)
    df = pd.merge(df,hera, how="outer", on = "Name").fillna(0.0)
    return (df,truth,sla,kallisto,hera)

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
    #return rd, nonZero
    return rd.abs().mean()[0]

@click.command()
@click.option('--truth', help='truth file')
@click.option('--quant',help='quant folder')

def run(truth,quant):
    prefix = quant 
    types = ["bleed_through"]
    files = {}
    for t in types:
        fileinfo = {}
        fileinfo["truth"]= truth 
        fileinfo["SLA"] =  "/".join([prefix,"salmon_out","quant.sf"])
        fileinfo["kallisto"] = "/".join([prefix,"kallisto_out","abundance.tsv"])
        #fileinfo["bowtie"] = "/".join([prefix,t,"quant","bowtie_out","quant.sf"])
        fileinfo["hera"] = "/".join([prefix,"hera_out","abundance.tsv"])
        files[t] = fileinfo

    df, truth, sla,kallisto,hera = getMergedDataFrameFast("bleed_through",files)
    print("\tSpearman\tMARD\n")
    print("Kallisto\t{}\t{}\n".format(df["count"].corr(df["NumReads_KAL"],method="spearman"),relDiff('count','NumReads_KAL',df)))
    print("SLA\t{}\t{}\n".format(df["count"].corr(df["NumReads"],method="spearman"),relDiff('count','NumReads',df)))
    print("hera\t{}\t{}\n".format(df["count"].corr(df["NumReads_hera"],method="spearman"),relDiff('count','NumReads_hera',df)))

if __name__ == '__main__' :
    run()

    