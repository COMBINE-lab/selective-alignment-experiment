library(data.table)

read_salmon <- function(fn) {
  t <- read.table(fn, header=TRUE)
  t
}

read_kallisto <- function(fn) {
  t <- read.table(fn, header=TRUE)
  setnames(t, old=c("target_id", "length", "eff_length", "est_counts", "tpm"),
              new=c("Name", "Length", "EffectiveLength", "NumReads", "TPM"))
  t
}

read_rsem_truth <- function(fn) {
  t <- read.table(fn, header=TRUE)
  setnames(t, old=c("transcript_id", "gene_id", "length", "effective_length", 
                    "count", "TPM", "FPKM", "IsoPct"),
           new=c("Name", "gene_id", "Length", "EffectiveLength", 
                 "NumReads", "TPM", "FPKM", "IsoPct"))
  t
}

read_hera <- function(fn) {
  t <- read.table(fn, header=TRUE)
  setnames(t, old=c("target_id", "unique_map", "length", "eff_length", "est_counts", "tpm"),
           new=c("Name", "UniqueMap", "Length", "EffectiveLength", "NumReads", "TPM"))
  t
}