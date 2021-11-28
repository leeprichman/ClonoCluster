## ---- cast_confusion
#' Generate confusion matrix for two clusterings, then return summary statistics.
#'
#' @param clusters Data.table. Columns are cell ids and cluster assignment.
#' @param barcodes Data.table. Columns are cell ids and barcode assignment.
#'
#' @return A data.table with summary statistics from the contingency tables, for each barcode, the cluster(s) with the highest number of true positives is returned.
#'
#' @export cast_confusion
#' @md
cast_confusion <- function(clusters, barcodes){

  a <- clusters %>% data.table::copy()

  b <- barcodes %>% data.table::copy()

  a %>% setnames(names(.), c("rn", "cluster"))

  b %>% setnames(names(.), c("rn", "barcode"))

  d <- merge(a, b, by = "rn")

  l <- d[, .N, by = c("cluster", "barcode")]

  l[, keep := N == max(N), by = c("barcode")]

  l <- l[keep == TRUE]

  ml <- list()

  dt <- data.table::data.table()

  # list confusion matrices
  for (i in 1:nrow(l)){

    cc <- l[i, cluster]

    bb <- l[i, barcode]

    m <- matrix(c(d[cluster == cc & barcode == bb, rn %>% length],
              d[cluster != cc & barcode == bb, rn %>% length],
              d[cluster == cc & barcode != bb, rn %>% length],
              d[cluster != cc & barcode != bb, rn %>% length]),
              nrow = 2, ncol = 2)

    rownames(m) <- c("Cluster on", "Cluster off")

    colnames(m) <- c("Barcode on", "Barcode off")

    ml[[length(ml) + 1]] <- m

    dt <- data.table::rbindlist(
            list(dt,
                  data.table::data.table(cluster = cc, barcode = bb, ind = length(ml))
              ),
              fill = TRUE)

  }

  # calculate summary statistics on confusion matrix
  do <- lapply(1:nrow(dt), function(n){

    m <- ml[[dt[n, ind]]]

    tp <- m[1,1]
    tn <- m[2,2]
    fp <- m[1,2]
    fn <- m[2,1]

    Po <- sum(diag(m)) / sum(m)

    Pp <- (rowSums(m)[1] / sum(m)) * (colSums(m)[1] / sum(m))

    Pn <- (rowSums(m)[2] / sum(m)) * (colSums(m)[2] / sum(m))

    Pe <- Pp + Pn

    kappa <- (Po - Pe) / (1 - Pe)

    do <- data.table::data.table(tp = tp, tn = tn, fp = fp, fn = fn,
                          tpr = tp / (tp + fn),
                          fpr = fp / (fp + tn),
                          ppv = tp / (tp + fp),
                          cohens_k = kappa)

    do[, gstat := sqrt(ppv * tpr)]

    do[, f_score := (2 * ppv * tpr) / (ppv + tpr)]

    do <- cbind(dt[n], do)

    return(do)

  }) %>% data.table::rbindlist(use.names = TRUE)

  print("It's super effective!")

  do[, ind := NULL]

  return(do)

}
