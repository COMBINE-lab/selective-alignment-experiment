# selective-alignment-experiment
The scripts here are designed to produce an adverserial data set to show the effectiveness of alignment-based methods over other tools.

To run the pipeline we need rsem, bowtie2, kallisto and salmon. The analysis of the quantification results need other python packages. So installing a conda package is preferable

~~~shell
 conda create --name <env> req.list 
 source activate env
~~~

### Preprocessing the reference
#### Downloading gtf and fasta files
~~~shell
# GTF
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_26/gencode.v26.annotation.gtf.gz
# Genome
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_26/GRCh38.p10.genome.fa.gz
# Transcriptome
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_26/gencode.v26.pc_transcripts.fa.gz
# unzip them
gunzip gencode.v26.annotation.gtf.gz
gunzip GRCh38.p10.genome.fa.gz
gunzip gencode.v26.pc_transcripts.fa.gz
# clean fasta file b/c gencode names are longer 
# create transcript_clean.fasta
# Also create a tid.txt file
./clean_gencode.sh gencode.v26.pc_transcripts.fa
~~~

#### preparing gid-tid list in the parent directory of the reference files
~~~shell
# generate gid_tid.txt
./make_gid_tid.sh ./gencode.v26.annotation.gtf
# generate the transcriptome file using fewer transcripts,
# gene_prob is probability of choosing a multi-isoform gene 
# tr_prob is probability of choosing a transcript from the 
# chosen gene, produces gid_tid_subset.txt and
# trandcript_<percent>.fa
python generate_transcript_subset.py gid_tid.txt tid.txt transcript_clean.fa <gene_prob> <tran_prob> 
~~~

#### RSEM pipeline for generating simulated reads
~~~shell
# This will generate the simulation directory rsem_test and
# rsem_sim file inside would contain sim_1.fq and sim_2.fq with
# 15M reads 
snakemake -j 9 -s pipleline.snake run_rsem --config out="rsem_test" subset="gid_tid_subset.txt" tr=transcript_<percent>.fa
~~~

#### Generate refernce from genome and gtf for hera 
~~~shell
mkdir rsem_prep_ref
rsem-prepare-reference --gtf gencode.v26.annotation.gtf --bowtie2 --bowtie2-path <bio-env>/bin/ GRCh38.primary_assembly.genome.fa rsem_prep_ref/reference
~~~

#### Running different tools 
~~~shell
# Generate indices for different tools
snakemake -j 16 -s pipleline.snake build_indices --config out="./rsem_test" indices="./test_indices" 
# Running the tools
snakemake -j 16 -s pipleline.snake run_fast_tools --config out="./rsem_test" quant="./test_quant" indices="./test_indices/"
~~~




