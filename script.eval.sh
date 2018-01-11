#!/bin/bash

### sample
sample=""

while getopts "khlsbp:" opt; do
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
        p)
            sample=$OPTARG
            ;;
    esac
done


### results
kallistoResults="result.kallisto"
heraResults="result.hera1.2"
slaResults="result.SLA09"
starAlignResults="result.star"
starQuantResults="result.star.quant"
bowtie2AlignResults="result.bowtie2"
bowtie2QuantResults="result.bowtie2.quant"

truth="truth.tsv"
truthIndex="transcript_id"
truthCount="count"

#kallisto
cmd="python script_quant_anal.py kallisto ${sample}/${kallistoResults}/abundance.tsv target_id est_counts ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd

#hera1.2
eval "sed -i 's/\#//g' ${sample}/${heraResults}/abundance.tsv" 
eval "sed -i 's/\:ENSG[0-9]*//g' ${sample}/${heraResults}/abundance.tsv"
cmd="python script_quant_anal.py hera1.2 ${sample}/${heraResults}/abundance.tsv target_id est_counts ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd

#sla
cmd="python script_quant_anal.py selective-alignment ${sample}/${slaResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd


#star
cmd="python script_quant_anal.py star ${sample}/${starQuantResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd



#bowtie2
cmd="python script_quant_anal.py bowtie2 ${sample}/${bowtie2QuantResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd
