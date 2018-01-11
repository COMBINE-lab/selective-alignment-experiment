#1/bin/bash


runKallisto=0
runHera=0
runHeraNoGRCH=0
runSLA=0
runStar=0
runBowtie2=0

while getopts "khlsbg" opt; do
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
    esac
done


### ref files
ref_directory="../Indices/HomoSapiens.38.80/"
txpfasta="Homo_sapiens.GRCh38.80.fa"
genefasta="Homo_sapiens.GRCh38.dna.primary_assembly.fa"
gtf="Homo_sapiens.GRCh38.80.gtf"


### binaries
kallistoBinary="/home/mohsen/kallisto_linux-v0.43.1/kallisto"
heraBinary="/home/mohsen/hera-v1.2/build/hera_build"
slaBinary="/home/mohsen/Salmon_SLA09_SeededAlignment/salmon/build/src/salmon"
starBinary="/home/mohsen/STAR-2.5.3a/bin/Linux_x86_64/STAR"
bowtie2Binary="/home/mohsen/bowtie2-2.3.3.1-linux-x86_64/bowtie2-build"

### outputs
kallistoIndex="kallisto.index"
heraIndex="hera1.2.index"
heraIndexNoGRCH="hera1.2.noGRCh38.index"
slaIndex="SLA09.index"
starIndex="star.index"
bowtie2Index="bowtie2.index"

#kallisto0.43 index
if [ $runKallisto == 1 ]
then
	cmd="/usr/bin/time -o index.kallisto.time \"${kallistoBinary}\"  index -i \"${kallistoIndex}\" -k 25 \"${ref_directory}\"/\"${txpfasta}\""
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
	cmd="/usr/bin/time -o index.SLA09.time \"${slaBinary}\"  index -t \"${ref_directory}\"/\"${txpfasta}\" -i \"${slaIndex}\" -k 25 -p 16"
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
	#eval "mkdir \"${bowtie2Index}\""
	cmd="/usr/bin/time -o index.bowtie2.time \"${bowtie2Binary}\" -f \"${ref_directory}\"/\"${txpfasta}\"  \"${bowtie2Index}\"/index"
	echo $cmd
	eval $cmd
fi
