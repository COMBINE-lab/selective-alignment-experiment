

### script.map.sh

# description
This script is for mapping and quantifying with different methods : kallisto, hera, selective-alignment, star, bowtie2
Before running this script, indices for all methods should be built in the same directory where this script is running using "./script.index.sh"

# how to run
./script.map.sh [methods to run] -p [sample directory] -1 [reads1 fileName] -2 [reads2 fileName] -r [input format] ...

# required options
1- methods to run: 
	-k : kallisto
	-h : hera
	-l : selective alignment
	-s : star
	-b : bowtie2
	-n : bowtie2 in not sensitive mode
	-r : rsem
2- sample to run:
	-p [sample directory] : where the sample read files are located at
	-1 [reads1 fileName]
	-2 [reads2 fileName]
3- input reads format (necessary for mapping with bowtie2)
	-r f : reads are in fasta format
	-r q : reads are in fastq format
# additional options
1- edit distance - for selective alignment  (default value = 4)
	-d [edit distance] 
2- index kmer size - for kallisto and selective alignment (default value = 25)
	-m [kmer size]

# example
./script.map.sh -khlsb -p samples/rsem_sim_30M -1 sim_1.q -2 sim_2.fq -r q -d 4 -m 31

# result directories
kallisto : [sample directory]/result.kallisto.k[kmer size]
hera  : [sample directory]/results.hera1.2
selective alignment : [sample directory]/result.SLA09.k[kmer size]
star :
	mapping results : [sample directory]/result.star
	quantification results : [sample directory]/result.star.quant
bowtie2 :
	mapping results : [sample directory]/result.bowtie2
	quantification results : [sample directory]/result.bowtie2.quant
bowtie2 not sensitive:
	mapping results : [sample directory]/result.bowtie2.noSensitive
	quantification results : [sample directory]/result.bowtie2.noSensitive.quant
### script.eval.sh

# description
For evaluating the accuracy of quantification with simulated samples with all methods, this script can be used to compute the spearman correlation and MARD (mean of absolute relative differences) of quantification results with truth counts
Quantification results for all methods [kallisto, hera, selective alignment, star and bowtie2] should be calculated using "./script.map.sh" before running this script

# how to run
./script.eval.sh -p [sample directory] -t [truth fileName] ...

# required options
1- sample to evaluate
	-p [sample directory] : where the quantification results and truth file are located
2- truth file
	-t [truth fileName] : the name of the truth file located at [sample directiory]

# additional options 
1- index kmer size : for kallisto and selective alignment (default value = 25)
	-m [kmer size] : which kallisto and selective alignment results want to evaluate
2- bowtie2 no sensitive
	-n : evaluate bowti2 results mapped without sensitive option	

# example
./script,eval.sh -p samples/rsem_sim_30M -t sim.sim.isoforms.results

