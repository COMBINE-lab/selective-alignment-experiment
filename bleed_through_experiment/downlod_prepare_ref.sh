#Since hera can not run without reference therefore we run hera first to prepare
#index 
#downlaod ref for mouse and human
# Mouse is uploaded to zenodo
hera_index_binary="/home/hirak/Projects/hera/build/hera_build"
currdir=$PWD
ref=$1

gtffile=gencode.v27.annotation.gtf
pcgtffile=gencode.v27.pc.gtf
genome=GRCh38.p10.genome.fa

#download human annotation
echo "Downloading references from web"
mkdir -p $ref
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz -O $ref/gencode.v27.annotation.gtf.gz
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/GRCh38.p10.genome.fa.gz -O $ref/GRCh38.p10.genome.fa.gz
cd $ref

echo "Unzipping genome..."
gunzip GRCh38.p10.genome.fa.gz
echo "Unzipping genome done..."
echo "Unzipping gtf..."
gunzip gencode.v27.annotation.gtf.gz
echo "Unzipping gtf done..."


#generate pc gtf
echo "Extracting the pc genes..."
#echo "awk -F \"\\\t\" '($3 == \"gene\") { split($9,a,\";\"); if(a[2] ~ \"protein_coding\") print $0; next}{if($1 \!~ \"#\") print $0}' $gtffile > $pcgtffile"
#awk -F "\t" '($3 == "gene") { split($9,a,";"); if(a[2] ~ "protein_coding") print $0; next}{if($1 !~ "#") print $0}' $gtffile > $pcgtffile

#generate hera gemome
echo "Building hera indices..."
#$hera_index_binary --fasta $genome --gtf $pcgtffile --outdir hera_idx_pc
$hera_index_binary --fasta $genome --gtf $gtffile --outdir hera_idx

#mv hera_idx_pc/transcripts.fasta ./transcripts_pc.fasta
mv hera_idx/transcripts.fasta ./transcripts_all.fasta

sed '/^>/ s/:.*//' transcripts_all.fasta > transcripts_all.fa
#sed '/^>/ s/:.*//' transcripts_pc.fasta > transcripts_pc.fa

rm transcripts_all.fasta
#rm transcripts_pc.fasta
#rm -fr hera_idx_pc
rm -fr hera_idx


echo "Reference ready ... deleting hera indices"
cd $currdir
