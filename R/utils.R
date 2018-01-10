label_cols <- function(d, name) {
  names(d) = unlist(lapply(names(d), 
                                function(x) { if (x == "Name") { x } else { paste0(x, ".", name) } }))
  d
}

merge_tables_no_truth <- function(dlist) {

  if (length(dlist) == 1) {
    merged <- dlist[[names(dlist)[1]]]
    merged <- label_cols(dlist[[1]], names(dlist)[1])
  } else if (length(dlist) >= 2) {
    merged1 <- label_cols(dlist[[1]], names(dlist)[1])
    merged2 <- label_cols(dlist[[2]], names(dlist)[2])
    merged <- merge(merged1, merged2, by="Name")
  }
  
  if (length(dlist) > 2) {
    for (idx in seq_along(dlist[c(-1,2)])) {
      merged1 <- label_cols(dlist[[idx]], names(dlist)[idx])
      merged <- merge(merged, merged1, by="Name")
    }
  }
  merged
}

merge_tables <- function(dlist, truth=NULL) {
  if (is.null(truth)) {
    merge_tables_no_truth(dlist)
  } else {
    m <- truth
    for (idx in seq_along(dlist)) {
      merged1 <- label_cols(dlist[[idx]], names(dlist)[idx])
      m <- merge(m, merged1, by="Name", how="outer", all=TRUE)#, suffixes=c("", paste0(".",name)))
    }
    m[is.na(m)] <- 0.0
    m
  }
}