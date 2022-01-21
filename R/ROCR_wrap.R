## ---- ROCR_wrap
#' Fast AUC calculation.
#'
#' @param x Numeric. First vector of values.
#' @param y Numeric. Second vector of values.
#' @param return_curve Logical. Default FALSE. Return the ROC curve values.
#'
#' @return AUC value (always > 0.5) or ROC curve values.
#'
#' @export ROCR_wrap
#' @md

ROCR_wrap <- function(x, y, return_curve = FALSE){

  pred <-  ROCR::prediction(predictions = c(x, y),
                      labels = c(rep(x = 1, length(x = x)), rep(x = 0, length(x = y))),
                      label.ordering = 0:1)

  perf <- ROCR::performance(prediction.obj = pred,
                          measure = "auc")

  auc <- perf@y.values[[1]]

  flip <- FALSE

  if (auc < 0.5) {

    pred <-  ROCR::prediction(predictions = c(x, y),
                        labels = c(rep(x = 0, length(x = x)), rep(x = 1, length(x = y))),
                        label.ordering = 0:1)

    perf <- ROCR::performance(prediction.obj = pred,
                            measure = "auc")

    auc <- perf@y.values[[1]]

    flip <- TRUE

  }

  if (!return_curve) return(auc * 100)

  roct <- data.table::data.table(thresh = pred@cutoffs[[1]],
                                tp = pred@tp[[1]],
                                fp = pred@fp[[1]],
                                tn = pred@tn[[1]],
                                fn = pred@fn[[1]],
                                tpr = pred@tp[[1]] / pred@n.pos[[1]],
                                fpr = pred@fp[[1]] / pred@n.neg[[1]],
                                ppv = pred@tp[[1]] / (pred@tp[[1]] + pred@fp[[1]]),
                                npv = pred@tn[[1]] / (pred@tn[[1]] + pred@fn[[1]]),
                                auc = auc * 100)

  roct[, is_flipped := flip]

  return(roct)

}

## ---- Find_Markers_ROC
#' Fast AUC calculation wrapper for clusters.
#'
#' @param dl A data.table of cluster assignments, output from `barcluster`, with minimum columns c("rn", "Group", "alpha").
#' @param cm Matrix. A count matrix.
#'
#' @return A table of marker AUCs and thresholds for all clusters.
#'
#' @export Find_Markers_ROC
#' @md

Find_Markers_ROC <- function(dl, cm){

  fast_comp <- function(v, x, y){

    a <- ROCR_wrap(x = v[x], y = v[y], return_curve = TRUE)

    a[, dist := sqrt(((1 - tpr)^2) + ((fpr)^2))]

    a <- a[dist == min(dist)]

    auc <- a[, auc %>% unique]

    flip <- a[, is_flipped %>% unique]

    thresh <- a[, thresh %>% unique %>% .[1]]

    return(data.table::data.table(auc = auc, flip = flip, thresh = thresh))

  }

  pb <- utils::txtProgressBar(min = 0,
    max = length(dl[, alpha %>% unique %>% length]),
    style = 3)

  aucts <- lapply(dl[, alpha %>% unique], function(a){

    tr <- dl[alpha == a]

    tr_auc <- lapply(tr[, Group %>% unique], function(go){

      utils::setTxtProgressBar(pb, which(go == tr[, Group %>% unique]))

      ing <- tr[Group == go, rn]

      if (length(ing) < 10) return(NULL)

      outg <- tr[Group != go, rn]

      auc <- apply(cm, 2, function(x) fast_comp(x, ing, outg))

      do <- lapply(auc %>% seq_along, function(n){

        d <- auc[[n]]

        g <- names(auc)[n]

        d[, rn := g]

        return(auc[[n]])

      }) %>% data.table::rbindlist()

      do[, Group := go]

      return(do)

    }) %>% data.table::rbindlist()

    tr_auc[, alpha := a]

    return(tr_auc)

  }) %>% data.table::rbindlist()

  aucts[, direction := ifelse(flip, "less", "greater")]

  aucts[, flip := NULL]

  aucts %<>% .[, .SD, .SDcols = c("rn", "auc", "thresh",
                                "direction", "Group", "alpha")]

  close(pb)

  return(aucts)

}
