# script.simulations.sh

This script can be used to generate simulated paired end reads with either rsem-simulate-reads simulator or polyester from human transcripts obtained at: <br />
~~~shell
        wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz
        wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_26/GRCh38.p10.genome.fa.gz
~~~

## Generating samples with RSEM
~~~shell
./script.simulations.sh -e -p [input sample directory] -1 [input reads1 fileName] -2 [input reads2 fileName] -c [read count] -n [background noise] -o [output directory] -s [seed] 
~~~
## Options
1- The sample with which the rsem model will be built
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -p [sample directory] <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -1 [input sample reads1 fileName] <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -2 [input sample reads2 fileName] <br />
2- Number of reads that rsem shoul generate <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -c [read count] (default value = 30000000) <br />
3- The precentage of reads that don't come from the input transcriptome  <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -n [background noise] (default value = 0.05)  <br />
4- The directory where the simulated sample reads and truth file will be written at <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -o [output direcotry] <br />
5- The random number required for beginning simulation <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -s [seed] (default value = 0)

## Example
~~~shell
./script.simulations.sh -e -p ./samples/SRR1216000 -1 sim_1.fastq -2 sim_2.fastq -c 30000000 -n 0.05 - ./samples_rsem_30M -s 0
~~~


# script.index.sh

This script builds indices on human transcriptome obtained at: <br />
~~~shell
	wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz
	wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_26/GRCh38.p10.genome.fa.gz
~~~
The Hera index should be built first using genome + gtf files <br />
then other methods indices can be built using the output transcriptome by hera built index <br />
 
Indices for all the methods should be built with this script before running quantifications <br />

## How to run
~~~shell
./script.index.sh [methods to run] ...
~~~
## Methods to run
~~~shell
	-k : kallisto
	-h : hera with '--grch38 1' option
	-g : hera without '--grch38 1' option
	-l : selective alignment
	-s : star
	-b : bowtie2
	-r : rsem
~~~
## Additional options
kmer size: <br />
For kallisto and selective alignment we can specify the kmer size with which their indices are built <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-m [kmer size] (default value = 25)

## Example
~~~shell
./script.index.sh -kglsb -k 25	
~~~

## Ouput indices
kallisto : ./kallisto.index.[kmer size]  <br />
hera with grch38 option : ./hera.1.2.index/  <br />
hera without grch39 option : ./hera.1.2.noGRCh38.index/  <br />
selective alignment : ./SLA01.index.[kmer size]/  <br />
star : ./star.index/  <br />
bowtie2 : ./bowtie2.index/  <br />
rsem : ./rsem.index/ 

# script.map.sh

This script is for mapping and quantifying with different methods : kallisto, hera, selective-alignment, star, bowtie2 <br />
Before running this script, indices for all methods should be built in the same directory where this script is running using "./script.index.sh" <br />

## How to run
~~~shell
./script.map.sh [methods to run] -p [sample directory] -1 [reads1 fileName] -2 [reads2 fileName] -r [input format] ...
~~~~
## Required options
1- methods to run:  <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-k : kallisto <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-h : hera <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-l : selective alignment <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-s : star <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-b : bowtie2 <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-n : bowtie2 in not sensitive mode <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-r : rsem <br />
2- sample to run: <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-p [sample directory] : where the sample read files are located <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-1 [reads1 fileName] <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-2 [reads2 fileName] <br />
3- input reads format (necessary for mapping with bowtie2) <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-r f : reads are in fasta format <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-r q : reads are in fastq format <br />
## Additional options
1- edit distance - for selective alignment  (default value = 4) <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-d [edit distance]  <br />
2- index kmer size - for kallisto and selective alignment (default value = 25) <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-m [kmer size] <br />

## Example
~~~shell
./script.map.sh -khlsb -p samples/rsem_sim_30M -1 sim_1.q -2 sim_2.fq -r q -d 4 -m 31
~~~
## Result directories
kallisto : [sample directory]/result.kallisto.k[kmer size] <br />
hera  : [sample directory]/results.hera1.2 <br />
selective alignment : [sample directory]/result.SLA09.k[kmer size] <br />
star : <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	mapping results : [sample directory]/result.star <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	quantification results : [sample directory]/result.star.quant <br />
bowtie2 : <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	mapping results : [sample directory]/result.bowtie2 <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	quantification results : [sample directory]/result.bowtie2.quant <br />
bowtie2 not sensitive: <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	mapping results : [sample directory]/result.bowtie2.noSensitive <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	quantification results : [sample directory]/result.bowtie2.noSensitive.quant <br />

# script.eval.sh

For evaluating the accuracy of quantification with simulated samples with all methods, this script can be used to compute the spearman correlation and MARD (mean of absolute relative differences) of quantification results with truth counts <br />
Quantification results for all methods [kallisto, hera, selective alignment, star and bowtie2] should be calculated using "./script.map.sh" before running this script <br />

## How to run
./script.eval.sh -p [sample directory] -t [truth fileName] ... <br />

## Required options
1- sample to evaluate <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-p [sample directory] : where the quantification results and truth file are located <br />
2- truth file <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-t [truth fileName] : the name of the truth file located at [sample directiory] <br />

## Additional options 
1- index kmer size : for kallisto and selective alignment (default value = 25) <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-m [kmer size] : which kallisto and selective alignment results want to evaluate <br />
2- bowtie2 no sensitive <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	-n : evaluate bowti2 results mapped without sensitive option	<br />

## Example
~~~shell
./script,eval.sh -p samples/rsem_sim_30M -t sim.sim.isoforms.results <br />
~~~

