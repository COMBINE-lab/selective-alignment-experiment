rel_diff_plot <- function(d, true, x, y) {
  rdx <- rel_diff(d, true, x)
  rdy <- rel_diff(d, true, y)
  dt <- data.table(true=d[[true]], abs_diff=abs(rdx) - abs(rdy))
  print(sum(abs(rdx) > abs(rdy)))
  print(sum(abs(rdx) < abs(rdy)))
  print(head(dt))
  dt[is.na(dt)] <- 0.0
  l1 <- unlist(strsplit(x, "\\."))[2]
  l2 <- unlist(strsplit(y, "\\."))[2]
  top_points <- sprintf("ARD(%s) > ARD(%s) = %d", l1, l2, sum(abs(rdx) > abs(rdy)))
  bottom_points <- sprintf("ARD(%s) > ARD(%s) = %d", l2, l1, sum(abs(rdy) > abs(rdx)))
  p <- ggplot(dt, aes(true+1, abs_diff)) + stat_binhex(aes(fill=log(..count..+1)),bins=150) + 
    scale_x_continuous(trans="log2") +
    ylim(-1.01, 1.01) + 
    ylab(bquote("ARD"[.(l1)] ~ " - " ~ "ARD"[.(l2)])) + 
    xlab("log2(True read count)") + theme_minimal() +  geom_hline(yintercept=0, color='red', size=1.2) +
    annotate("text", x = 65536, y = 0.8, label = top_points) + 
    annotate("text", x = 65536, y = -0.8, label = bottom_points) +
    theme(text = element_text(size=20)) +
    scale_fill_continuous(guide="colourbar", name = "log(count+1)\n")
  return(p)
}

scatter_plot <- function(d, x, y) {
  ggplot(m, aes_string(x, y)) + geom_point() + scale_x_log10(limits=c(1e-3,NA)) + 
    scale_y_log10(limits=c(1e-3,NA)) + 
    theme_minimal() + stat_binhex(bins=90) + 
    scale_fill_gradientn(colors=c("blue", "green", "red"), trans="log10")
}