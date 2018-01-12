#!/bin/bash

# define simulation parameters
sample="samples/SRR1216000"
readPair1="sim_1.fastq"
readPair2="sim_2.fastq"

simCount=30000000
simNoise=0.05
seed=0

runRsem=0
outSim="samples/rsem_sim_30M"

while getopts "ep:1:2:c:n:o:s:" opt; do
    case "$opt" in
	e)
	    runRsem=1
	    ;;
	c)
            simCount=$OPTARG
            ;;
        n)
            simNoise=$OPTARG
            ;; 
	o)
	    outSim=$OPTARG
	    ;;
	s)
	    seed=$OPTARG
	    ;;
        p)
            sample=$OPTARG
            ;;
        1)
            readPair1=$OPTARG
            ;;
        2)
            readPair2=$OPTARG
            ;;
    esac
done

### ref files
# ref_directory="./"
# txpfasta="hera1.2.noGRCh38.index/transcripts.fasta"
# genefasta="GRCh38.p10.genome.fa"
# gtf="gencode.v27.annotation.gtf"

### indices
rsemIndex="rsem.index"

### binaries
rsemBinary="/home/mohsen/RSEM-1.3.0/rsem-simulate-reads"




#build hera index to hav txpome
./script.index.sh -hg

#build rsem ref
./script.index.sh -e


if [ $runRsem == 1 ]
then
	#rsem rsem quant sample SRR1216000
	cmd="./script.map.sh -e -p ${sample} -1 ${readPair1} -2 ${readPair2}"
	echo $cmd
	eval $cmd

	#simulate reads with rsem
	mkdir samples/rsem_sim_30M/
	cmd="${rsemBinary} ${rsemIndex}/index ${sample}/result.rsem/out.stat/out.model  ${sample}/result.rsem/out.isoforms.results ${simNoise} ${simCount} ${outSim}/sim  --seed ${seed}"
	echo $cmd
	eval $cmd
fi
