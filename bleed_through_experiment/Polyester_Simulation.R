#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


library(polyester)
library(Biostrings)

#error
if (length(args) < 2) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} 

txpFastaFile <- args[1]
salmonModelFile <- args[2]

txnames <- fasta.index(txpFastaFile)$desc
salmonModel <- read.table(salmonModelFile,header=TRUE)
df = salmonModel[match(txnames, salmonModel$Name),]
countMatSalmon <- matrix(df$NumReads, nrow=length(txnames))

seed_val = sample.int(200, 1)
for (i in seed_val){
set.seed(i)
simulate_experiment_countmat(txpFastaFile, 
                             readmat=countMatSalmon, 
                             outdir=paste0(args[3],"/reads_",i), 
                             readlen=100,
                             #size=1e6,
                             strand_specific=F, 
                                 paired=TRUE, 
                             error_model='uniform',
                             gzip=TRUE,
                             error_rate=0.001) 
    }