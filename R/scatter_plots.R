library(ggplot2)
require(gridExtra)
library(MASS)
library(LSD)

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

for (i in seq_along(methods)) {
  m <- methods[[i]]
  k <- sprintf("NumReads.%s",m)
  mlab <- sprintf("log(%s count + 1)",m)
  fname <- sprintf("%s_scatter.pdf",m)
  p1 <- ggplot(merged, aes(x=merged[['NumReads']]+1, y=merged[[k]]+1)) + 
    geom_hex(bins=100) + scale_x_log10() + scale_y_log10() + 
    scale_fill_gradient(trans='log') + theme_classic() + xlab('log(true count + 1)') +
    ylab(mlab)
  ggsave(file.path(path,"plots", "scatter", fname), p1)
  #s <- cor(merged$NumReads, merged[[k]], method='spearman')
  #p1 <- ggplot(m, aes(x=log(NumReads+1), y=log(k+1))) + geom_point(alpha=0.1) 
}