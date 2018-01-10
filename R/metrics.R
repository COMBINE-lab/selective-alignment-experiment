rel_diff <- function(df, c1, c2, cutoff=1.0) {
  x <- df[[c1]]
  y <- df[[c2]]
  x[x < cutoff] = 0
  y[y < cutoff] = 0
  rd <- (x-y) / (x+y)
  rd[is.na(rd)] = 0
  rd
}

mard <- function(df, c1, c2, cutoff=1.0) {
  mean(abs(relDiff(df, c1, c2, cutoff)))
}