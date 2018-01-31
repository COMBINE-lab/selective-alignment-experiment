library(tidyverse)
source('readers.R')
source('utils.R')
source('plots.R')
source('metrics.R')
library(jsonlite)
library(stargazer)

methods = c('hera', 'Bowtie2', 'STAR', 'selaln', 'selaln-or', 'kallisto')

mreaders <- list(hera=read_hera, Bowtie2=read_salmon, STAR=read_salmon, selaln=read_salmon, `selaln-or`=read_salmon, kallisto=read_kallisto)

jsonFile <- '../../results/sim30/data.json'
d <- jsonlite::read_json(jsonFile)
path <- normalizePath(dirname(jsonFile))
dset <- d['experiment']

dflist <- list()
print(d['truth'])
t <- read_rsem_truth(file.path(path, d['truth']))
#t <- read_polyester_truth(file.path(d[dset][[1]]['truth']))

for (m in methods) {
  print(sprintf("reading in results for %s", m))
  dflist[[m]] <- mreaders[[m]](file.path(path, d[m]))
}

print("merging data frames")

merged <- merge_tables(dflist, t)
print(head(merged))

mnames <- rep('', length(methods))
spears <- rep(0.0, length(methods))
mards <- rep(0.0, length(methods))

for (i in seq_along(methods)) {
  m <- methods[[i]]
  k <- sprintf("NumReads.%s",m)
  s <- cor(merged$NumReads, merged[[k]], method='spearman')
  mrd <- mard(merged, "NumReads", k, cutoff=0.0)
  meanae <- mae(merged, "NumReads", k, cutoff=0.0)
  print(sprintf("truth vs. %s", m))
  print("============")
  print(sprintf(" spearman %f", s))
  print(sprintf(" mard %f", mrd))
  print(sprintf(" MAE %f", meanae))
  cat("\n")
  mnames[[i]] <- m
  spears[[i]] <- s
  mards[[i]] <- mrd
}

res <- data.frame(method=mnames, spearman=spears, mard=mards)
print(stargazer(res, summary=FALSE))
