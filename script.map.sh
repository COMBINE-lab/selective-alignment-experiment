#!/bin/bash

runKallisto=0
runHera=0
runSLA=0
runStar=0
runBowtie2=0


#sample
sample=""
readPair1=""
readPair2=""

readTyp=""

while getopts "khlsbp:1:2:r:" opt; do
    case "$opt" in
	k)
            runKallisto=1
            ;;
        h)
            runHera=1
            ;; 
	l)
	    runSLA=1
	    ;;
        s)
            runStar=1
            ;;
        b)
            runBowtie2=1
            ;;       
	r)
            readType=$OPTARG
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
ref_directory="../Indices/HomoSapiens.38.80/"
txpfasta="Homo_sapiens.GRCh38.80.fa"
genefasta="Homo_sapiens.GRCh38.dna.primary_assembly.fa"
gtf="Homo_sapiens.GRCh38.80.gtf"

### indices
kallistoIndex="kallisto.index"
heraIndex="hera1.2.noGRCh38.index"
slaIndex="SLA09.index"
starIndex="star.index"
bowtie2Index="bowtie2.index"

### sample
#sample="sim30"
#readPair1="sim2_1.fq"
#readPair2="sim2_2.fq"

### binaries
kallistoBinary="/home/mohsen/kallisto_linux-v0.43.1/kallisto"
heraBinary="/home/mohsen/hera-v1.2/build/hera"
slaBinary="/home/mohsen/Salmon_SLA09_SeededAlignment/salmon/build/src/salmon"
starBinary="/home/mohsen/STAR-2.5.3a/bin/Linux_x86_64/STAR"
bowtie2Binary="/home/mohsen/bowtie2-2.3.3.1-linux-x86_64/bowtie2"
salmonBinary="/home/mohsen/Salmon-latest_linux_x86_64/bin/salmon"

### results
kallistoResults="result.kallisto"
heraResults="result.hera1.2"
slaResults="result.SLA09"
starAlignResults="result.star"
starQuantResults="result.star.quant"
bowtie2AlignResults="result.bowtie2"
bowtie2QuantResults="result.bowtie2.quant"

#kallisto
if [ $runKallisto == 1 ]
then
	cmd="/usr/bin/time -o \"${sample}\"/quant.kallisto.time \"${kallistoBinary}\"  quant -i \"${kallistoIndex}\"  -o \"${sample}\"/\"${kallistoResults}\" -t 16  \"${sample}\"/\"${readPair1}\" \"${sample}\"/\"${readPair2}\""
	echo $cmd
	eval $cmd
fi

#hera1.2
if [ $runHera == 1 ]
then
	cmd="/usr/bin/time -o  \"${sample}\"/quant.hera1.2.time   \"${heraBinary}\"  quant -i \"${heraIndex}\"  -t 16 -1 \"${sample}\"/\"${readPair1}\" -2 \"${sample}\"/\"${readPair2}\" -o \"${sample}\"/\"${heraResults}\""
	echo $cmd
	eval $cmd
fi

#sla
if [ $runSLA == 1 ]
then
	cmd="/usr/bin/time -o \"${sample}\"/quant.SLA09.time  \"${slaBinary}\"   quant -i \"${slaIndex}\" -la -1 \"${sample}\"/\"${readPair1}\" -2 \"${sample}\"/\"${readPair2}\" -o \"${sample}\"/\"${slaResults}\"  -p 16  --softFilter --editDistance 4 --rangeFactorizationBins 4"
	echo $cmd
	eval $cmd
fi

#star
if [ $runStar == 1 ]
then
	eval "mkdir \"${sample}\"/\"${starAlignResults}\""
	cmd="/usr/bin/time -o \"${sample}\"/map.star.time  \"${starBinary}\" --runThreadN 16 --genomeDir \"${starIndex}\"/  –-outFilterMultimapNmax 200 -–outFilterMismatchNmax 99999 –-outFilterMismatchNoverLmax 0.2 -–alignIntronMin 1000 –-alignIntronMax 0 –-limitOutSAMoneReadBytes 1000000 --outSAMtype BAM Unsorted --readFilesIn  \"${sample}\"/\"${readPair1}\" \"${sample}\"/\"${readPair2}\" --outFileNamePrefix \"${sample}\"/\"${starAlignResults}\"/"
	echo $cmd
	eval $cmd

	cmd="/usr/bin/time -o \"${sample}\"/quant.star.time  \"${salmonBinary}\" quant -t \"${ref_directory}\"/\"${txpfasta}\"  -la -a \"${sample}\"/\"${starAlignResults}\"/Aligned.out.bam  -o \"${sample}\"/\"${starQuantResults}\" -p 16  --useErrorModel --rangeFactorizationBins 4"
	echo $cmd
	eval $cmd
fi

#bowtie2
if [ $runBowtie2 == 1 ]
then
	eval "mkdir \"${sample}\"/\"${bowtie2AlignResults}\""
	cmd="/usr/bin/time -o \"${sample}\"/map.bowtie2.time \"${bowtie2Binary}\"  -${readType} --phred33 --sensitive --dpad 0 --gbar 99999999 --mp 1,1 --np 1 --score-min L,0,-0.1 -I 1 -X 1000 --no-mixed --no-discordant -p 16 -k 200 -x \"${bowtie2Index}\"/index -1 \"${sample}\"/\"${readPair1}\" -2 \"${sample}\"/\"${readPair2}\" | samtools view -S -b -o \"${sample}\"/\"${bowtie2AlignResults}\"/Aligned.out.bam -"
	echo $cmd
	eval $cmd

	cmd="/usr/bin/time -o \"${sample}\"/quant.bowtie2.time  \"${salmonBinary}\" quant -t \"${ref_directory}\"/\"${txpfasta}\"  -la -a \"${sample}\"/\"${bowtie2AlignResults}\"/Aligned.out.bam  -o \"${sample}\"/\"${bowtie2QuantResults}\" -p 16  --useErrorModel --rangeFactorizationBins 4"
	echo $cmd
	eval $cmd
fi
