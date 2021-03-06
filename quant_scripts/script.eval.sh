#!/bin/bash

### sample
sample=""
noSensitive=0
truth=""
kmer=25
noSensitive=0

while getopts "np:t:m:" opt; do
    case "$opt" in
        n)
            noSensitive=1
            ;;
        p)
            sample=$OPTARG
            ;;
	t)
	    truth=$OPTARG
	    ;;
	m)
	    kmer=$OPTARG
	    ;;
    esac
done


### results
kallistoResults="result.kallisto.k${kmer}"
heraResults="result.hera1.2"
slaResults="result.SLA09.k${kmer}"
starAlignResults="result.star"
starQuantResults="result.star.quant"
bowtie2AlignResults="result.bowtie2"
bowtie2QuantResults="result.bowtie2.quant"
#bowtie2noSensitiveQuantResults="result.bowtie2.noSensitive.quant"

if [ $noSensitive == 1 ]
then
bowtie2QuantResults="result.bowtie2.noSensitive.quant"
fi

#truth="truth.tsv"
#truth="sim.sim.isoforms.results"
truthIndex="transcript_id"
truthCount="count"

#kallisto
cmd="python AnalyzeQuantification.py kallisto ${sample}/${kallistoResults}/abundance.tsv target_id est_counts ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd

#hera1.2
eval "sed -i 's/\#//g' ${sample}/${heraResults}/abundance.tsv" 
#eval "sed -i 's/\:ENSG[0-9]*//g' ${sample}/${heraResults}/abundance.tsv"
cmd="python AnalyzeQuantification.py hera1.2 ${sample}/${heraResults}/abundance.tsv target_id est_counts ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd

#sla
cmd="python AnalyzeQuantification.py selective-alignment ${sample}/${slaResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd


#star
cmd="python AnalyzeQuantification.py star ${sample}/${starQuantResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd



#bowtie2
cmd="python AnalyzeQuantification.py bowtie2 ${sample}/${bowtie2QuantResults}/quant.sf  Name NumReads ${sample}/${truth} ${truthIndex} ${truthCount}"
eval $cmd
