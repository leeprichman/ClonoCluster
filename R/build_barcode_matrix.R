## ---- build_barcode_matrix
#' Build a sparse matrix representing the barcode graph.
#'
#' @param bt Data.table. Columns are "rn" (cell ids) and "Barcode".
#' @param value Numeric. A value to be used for edge weights within barcodes. Default NULL will use the reciprocal of barcode size.
#'
#' @return A sparse matrix of class `dgCMatrix` suitable for `clonocluster_model` or `Seurat::FindClusters`.
#'
#' @export build_barcode_matrix
#' @md
build_barcode_matrix <- function(bt, value = NULL){

  bc <- bt[, .SD %>% unique, .SDcols = c("rn", "Barcode")] %>%
  dcast(rn ~ Barcode,
    fun.aggregate = function(x) ifelse(length(x) > 0, 1, 0))

  rn <- bc[, rn]

  bc <- bc[, .SD, .SDcols = 2:ncol(bc)] %>% as.matrix

  rownames(bc) <- rn
  # matrix to normalize size
  nm <- matrix(0, nrow = nrow(bc), ncol = nrow(bc),
    dimnames = list(rownames(bc), rownames(bc))) %>% as("dgCMatrix")

  l <- apply(bc, 2, function(x) which(x == 1))

  message("Making lineage matrix")

  pb <- utils::txtProgressBar(min = 0, max = length(l), style = 3)

  for (i in 1:length(l)){

    utils::setTxtProgressBar(pb, i)

    ll <- data.table::CJ(names(l[[i]]), names(l[[i]]))

    nm[ll[, V1], ll[, V2]] <- 1/length(l[[i]])

  }

  close(pb)

  if (!is.null(value)){

    nm@x[nm@x > 0] <- value

    nm %<>% as("dgCMatrix")

  }

  return(nm)

}
