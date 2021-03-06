import pandas as pd
import numpy as np
import sys
import scipy.stats
import math

def relDiff(c1, c2, DF, cutoff, verbose=False):
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
    rd = pd.DataFrame(data = {"Name" : DF.index, "relDiff" : np.zeros(len(DF.index))*np.nan})
    rd.set_index("Name", inplace=True)
    bothZero = DF.loc[(DF[c1] <= cutoff) & (DF[c2] <= cutoff)].index
    nonZero = DF.index.difference(bothZero)
    if (verbose):
        print("Zero occurs in both columns {} times".format(len(rd.loc[bothZero])))
        print("Nonzero occurs in at least 1 column {} times".format(len(rd.loc[nonZero])))
    allRD = 1.0 * ((DF[c1] - DF[c2]) / (DF[c1] + DF[c2]))
    #assert(len(rd.loc[nonZero]["relDiff"]) == len(allRD[nonZero]))
    rd["relDiff"][nonZero] = allRD[nonZero]
    if len(bothZero) > 0:
        rd["relDiff"][bothZero] = 0.0
    return rd, nonZero




def analyze_method(method, address, index_name, count_name,truth_address,truth_index,truth_count):
	
	#ans = pd.read_table(truth_address,index_col=truth_index)
	ans = {} 
	if "truth.tsv" in truth_address:
		ans = pd.read_table(truth_address,names=[truth_index,"dupp",truth_count],index_col=truth_index,sep=' ')
	else:
		ans = pd.read_table(truth_address,index_col=truth_index)

	#ans.drop_duplicates( keep='first')
	ans = ans.rename(columns = {truth_count:'count1'})
	print (method)
	result = pd.read_table(address,index_col=index_name)
	print (len(ans.loc[ans['count1'] <= cutoff].index))
	join_table = result.join(ans,rsuffix="_truth").fillna(0.0)

	rd, nonZero =  relDiff(count_name, 'count1', join_table, cutoff)
		
	MARD = np.mean(rd['relDiff'].abs())
	print ("MARD:\t\t",MARD)

	spearman = scipy.stats.spearmanr(join_table[count_name],join_table['count1']).correlation
	print ("SPEARMAN:\t",spearman)

cutoff = 0.0
def main():
	analyze_method(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6],sys.argv[7])


if __name__=="__main__":
	main()
