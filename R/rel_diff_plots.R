source('selective-alignment-experiment/R/readers.R')
source('selective-alignment-experiment/R/plots.R')
source('selective-alignment-experiment/R/utils.R')
source('selective-alignment-experiment/R/metrics.R')
library(jsonlite)


d <- jsonlite::read_json('data.json')
dset <- "60 percent"
dset_print <- "60percent"

l <- list()

l[['hera']] <- read_hera(d[dset][[1]]$hera)
l[['kallisto']] <- read_kallisto(d[dset][[1]]$kallisto)
l[['star']] <- read_salmon(d[dset][[1]]$star)
l[['bowtie2']] <- read_salmon(d[dset][[1]]$bowtie2)
l[['selaln']] <- read_salmon(d[dset][[1]]$selaln)
t <- read_rsem_truth(d[dset][[1]]$truth)

m <- merge_tables(l, t)

print(head(m))

meth <- c('hera', 'kallisto', 'star', 'bowtie2', 'selaln')
cmeth <- combn(meth, 2)

for (i in seq(1,dim(cmeth)[2])) {
  m1 <- sprintf("NumReads.%s",cmeth[1,i])
  m2 <- sprintf("NumReads.%s", cmeth[2,i])
  print(paste("comparing", m1, "against", m2))
  p <- rel_diff_plot(m, "NumReads", m1, m2)
  fn <- sprintf("%s_rel_diff_%s_vs_%s.pdf", dset_print, cmeth[1,i], cmeth[2,i])
  ggsave(fn, p)
}