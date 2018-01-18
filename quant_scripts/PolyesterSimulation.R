#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
print(args)
library(polyester)
library(Biostrings)
library(dplyr)

input_file <- args[1]
output_file <- args[2]
seed_sample <- args[3]

base_file_address <- args[4]

in_error_rate<-args[5]

base_file = read.table(base_file_address,header=TRUE)
#rownames(base_file) <- base_file$transcript_id

print("here")
print(head(base_file))

message(input_file)
nseq <- length(fasta.seqlengths(input_file))
txnames <- fasta.index(input_file)$desc

print(head(txnames))

#reorder base vector
txcounts = c()
df = base_file[match(txnames, base_file$transcript_id),]
txcounts = df$count
print("Here are the new vector values")
print(head(txcounts))
#txcounts =  

# samples
set.seed(as.numeric(seed_sample))

#c1 <- base_file$count
c1 <- txcounts
print(typeof(c1))
print(head(c1))
print(nseq)
base <- matrix(c1, nrow=nseq)

write(length(base))

write_true_abund <- function(df, fn) {
	bf <- data.frame(df[,1])
	rownames(bf) <- txnames
	bf <- cbind(Name=rownames(bf), bf)
	colnames(bf) <- c("transcript_id", "count")
	write.table(bf, fn, quote=FALSE)
}

dir.create(file.path(output_file), showWarnings=TRUE)
write_true_abund(base, file.path(output_file, "truth.tsv"))

all <- base 
simulate_experiment_countmat(input_file, readmat=all, outdir=output_file, readlen=75, strand_specific=F, paired=TRUE, error_model='uniform', error_rate=as.double(in_error_rate)) 
