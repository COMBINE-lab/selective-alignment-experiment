#!/bin/bash

# define simulation parameters
sample="samples/SRR1216000"
readPair1="sim_1.fastq"
readPair2="sim_2.fastq"

simCount=30000000
simNoise=0.05
errorRate=0
seed=0

buildTxp=0
runRsem=0
runPolyester=0
outSim=""
baseVectorFile=""

while getopts "beyp:1:2:c:n:o:s:r:v:" opt; do
    case "$opt" in
	b)
	    buildTxp=1
	    ;;
	e)
	    runRsem=1
	    ;;
	y)
	    runPolyester=1
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
	r)
	    errorRate=$OPTARG
	    ;;
	v)
	    baseVectorFile=$OPTARG
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
ref_directory="./"
txpfasta="hera1.2.noGRCh38.index/transcripts.fasta"
genefasta="GRCh38.p10.genome.fa"
gtf="gencode.v27.annotation.gtf"

### indices
rsemIndex="rsem.index"

### binaries
rsemBinary="/home/mohsen/RSEM-1.3.0/rsem-simulate-reads"



if [ $buildTxp == 1 ]
then
	#build hera index to hav txpome
	./script.index.sh -hg
fi

# running rsem simulation
if [ $runRsem == 1 ]
then
	#build rsem ref
	./script.index.sh -e

	#rsem rsem quant sample SRR1216000
	cmd="./script.map.sh -e -p ${sample} -1 ${readPair1} -2 ${readPair2}"
	echo $cmd
	eval $cmd

	#simulate reads with rsem
	cmd= mkdir ${outSim}
	echo $cmd
	eval $cmd
	cmd="${rsemBinary} ${rsemIndex}/index ${sample}/result.rsem/out.stat/out.model  ${sample}/result.rsem/out.isoforms.results ${simNoise} ${simCount} ${outSim}/sim  --seed ${seed}"
	echo $cmd
	eval $cmd
fi

#running polyester simulation
if [ $runPolyester == 1 ]
then
	cmd= mkdir ${outSim}
	echo $cmd
	eval $cmd
	cmd="Rscript PolyesterSimulation.R ${txpfasta} ${outSim} ${seed} ${baseVectorFile} ${errorRate}"
	echo $cmd
	eval $cmd
fi
