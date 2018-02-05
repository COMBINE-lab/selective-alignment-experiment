rmse <- function(df, c1, c2, cutoff=0.0) {
  x <- df[[c1]]
  y <- df[[c2]]
  x[x <= cutoff] <- 0
  y[y <= cutoff] <- 0
  error = x - y
  sqrt(mean(error^2))
}

mae <- function(df, c1, c2, cutoff=0.0)
{
  x <- df[[c1]]
  y <- df[[c2]]
  x[x <= cutoff] <- 0
  y[y <= cutoff] <- 0
  error = x - y
  mean(abs(error))
}

rel_diff <- function(df, c1, c2, cutoff=0.0) {
  x <- df[[c1]]
  y <- df[[c2]]
  x[x <= cutoff] <- 0
  y[y <= cutoff] <- 0
  both0 <- (x <= cutoff) & (y <= cutoff)
  nonzero <- (x > cutoff) | (y > cutoff)
  print(sprintf("num both 0  : %d", sum(both0)))
  print(sprintf("num nonzero : %d", sum(nonzero)))
  rd <- rep(0.0, length(y)) 
  rd[nonzero] <- (x[nonzero]-y[nonzero]) / (x[nonzero]+y[nonzero])
  rd[both0] <- 0
  print(length(rd))
  rd
}

mard <- function(df, c1, c2, cutoff=0.0) {
  mean(abs(rel_diff(df, c1, c2, cutoff)))
}