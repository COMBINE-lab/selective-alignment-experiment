source('readers.R')
source('utils.R')
source('plots.R')
source('metrics.R')
library(jsonlite)

methods = c('hera', 'bowtie2', 'star', 'selaln', 'kallisto')

mreaders <- list(hera=read_hera, bowtie2=read_salmon, star=read_salmon, selaln=read_salmon, kallisto=read_kallisto)

d <- jsonlite::read_json('../data.json')
dset <- '60 percent'

dflist <- list()
print(d[dset][[1]]['truth'])
t <- read_rsem_truth(file.path(d[dset][[1]]['truth']))

for (m in methods) {
  print(sprintf("reading in results for %s", m))
  dflist[[m]] <- mreaders[[m]](file.path(d[dset][[1]][m]))
}

print("merging data frames")

merged <- merge_tables(dflist, t)

for (m in methods) {
  k <- sprintf("NumReads.%s",m)
  s <- cor(merged$NumReads, merged[[k]], method='spearman') 
  mrd <- mard(merged, "NumReads", k)
  print(sprintf("truth vs. %s", m))
  print("============")
  print(sprintf(" spearman %f", s))
  print(sprintf(" mard %f", mrd))
  cat("\n")
}