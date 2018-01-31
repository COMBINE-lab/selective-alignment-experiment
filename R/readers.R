library(data.table)

read_salmon <- function(fn) {
  t <- read_tsv(fn, col_names=TRUE)
  t
}

read_polyester_truth <- function(fn) {
  t <- read_tsv(fn, col_names=TRUE)
  #print(head(t))
  setnames(t, old=c("transcript_id", "count"),
           new=c("Name", "NumReads"))
  t
}
read_kallisto <- function(fn) {
  t <- read_tsv(fn, col_names=TRUE)
  setnames(t, old=c("target_id", "length", "eff_length", "est_counts", "tpm"),
              new=c("Name", "Length", "EffectiveLength", "NumReads", "TPM"))
  t
}

read_rsem_truth <- function(fn) {
  t <- read_tsv(fn, col_names=TRUE)
  setnames(t, old=c("transcript_id", "gene_id", "length", "effective_length", 
                    "count", "TPM", "FPKM", "IsoPct"),
           new=c("Name", "gene_id", "Length", "EffectiveLength", 
                 "NumReads", "TPM", "FPKM", "IsoPct"))
  t
}

read_hera <- function(fn) {
  t <- read_tsv(fn, col_names=TRUE)
  setnames(t, old=c("target_id", "unique_map", "length", "eff_length", "est_counts", "tpm"),
           new=c("Name", "UniqueMap", "Length", "EffectiveLength", "NumReads", "TPM"))
  t
}