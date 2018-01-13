#1/bin/bash


runKallisto=0
runHera=0
runHeraNoGRCH=0
runSLA=0
runStar=0
runBowtie2=0
runRsem=0
kmer=0

while getopts "khlsbgem:" opt; do
    case "$opt" in
        k)
            runKallisto=1
            ;;
        h)
            runHera=1
            ;;
        g)
            runHeraNoGRCH=1
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
        e)
            runRsem=1
            ;;
	m)
	    kmer=$OPTARG
    esac
done


### ref files
ref_directory="./"
txpfasta="hera1.2.noGRCh38.index/transcripts.fasta"
genefasta="GRCh38.p10.genome.fa"
gtf="gencode.v27.annotation.gtf"


### binaries
kallistoBinary="/home/mohsen/kallisto_linux-v0.43.1/kallisto"
heraBinary="/home/mohsen/hera-v1.2/build/hera_build"
slaBinary="/home/mohsen/Salmon09-SelectiveAlignment/salmon/bin/salmon"
starBinary="/home/mohsen/STAR-2.5.3a/bin/Linux_x86_64/STAR"
bowtie2Binary="/home/mohsen/bowtie2-2.3.3.1-linux-x86_64/bowtie2-build"
bowtie2Path="/home/mohsen/bowtie2-2.3.3.1-linux-x86_64/"
rsemBinary="/home/mohsen/RSEM-1.3.0/rsem-prepare-reference"

### outputs
kallistoIndex="kallisto.index.${kmer}"
heraIndex="hera1.2.index"
heraIndexNoGRCH="hera1.2.noGRCh38.index"
slaIndex="SLA09.index.${kmer}"
starIndex="star.index"
bowtie2Index="bowtie2.index"
rsemIndex="rsem.index"


#kallisto0.43 index
if [ $runKallisto == 1 ]
then
	cmd="/usr/bin/time -o index.kallisto.time.${kmer} \"${kallistoBinary}\"  index -i \"${kallistoIndex}\" -k ${kmer} \"${ref_directory}\"/\"${txpfasta}\""
	echo $cmd
	eval $cmd
fi

#hera1.2 index
if [ $runHera == 1 ]
then
	cmd="/usr/bin/time -o index.hera1.2.time \"${heraBinary}\" --fasta  \"${ref_directory}\"/\"${genefasta}\" --gtf \"${ref_directory}\"/\"${gtf}\" --grch38 1  --outdir \"${heraIndex}\""
	echo $cmd
	eval $cmd
fi

#hera1.2 index no grch38
if [ $runHeraNoGRCH == 1 ]
then
	cmd="/usr/bin/time -o index.hera1.2.time \"${heraBinary}\" --fasta  \"${ref_directory}\"/\"${genefasta}\" --gtf \"${ref_directory}\"/\"${gtf}\"  --outdir \"${heraIndexNoGRCH}\""
	echo $cmd
	eval $cmd
fi


#sla09 index
if [ $runSLA == 1 ]
then
	cmd="/usr/bin/time -o index.SLA09.time.${kmer} \"${slaBinary}\"  index -t \"${ref_directory}\"/\"${txpfasta}\" -i \"${slaIndex}\" -k ${kmer} -p 16"
	echo $cmd
	eval $cmd
fi

#star index
if [ $runStar == 1 ]
then
	eval "mkdir \"${starIndex}\""
	cmd="/usr/bin/time -o index.star.time \"${starBinary}\" --runThreadN 16 --runMode genomeGenerate --genomeDir \"${starIndex}\"/ --outFileNamePrefix \"${starIndex}\"/ --genomeFastaFiles \"${ref_directory}\"/\"${txpfasta}\"  --limitGenomeGenerateRAM 57993269973 --genomeChrBinNbits 12"
	echo $cmd
	eval $cmd
fi


#bowtie2 index
if [ $runBowtie2 == 1 ]
then
	eval "mkdir \"${bowtie2Index}\""
	cmd="/usr/bin/time -o index.bowtie2.time \"${bowtie2Binary}\" -f \"${ref_directory}\"/\"${txpfasta}\"  \"${bowtie2Index}\"/index"
	echo $cmd
	eval $cmd
fi

#rsem index
if [ $runRsem == 1 ]
then
	eval "mkdir \"${rsemIndex}\""
	cmd="/usr/bin/time -o index.rsem.time ${rsemBinary} --bowtie2 --bowtie2-path ${bowtie2Path}  ${ref_directory}/${txpfasta} ${rsemIndex}/index"
	echo $cmd
	eval $cmd
fi
