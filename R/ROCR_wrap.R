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
