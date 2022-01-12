## ---- barcluster
#' Plot a Sankey Diagram from a table of unique IDs, and two or more columns indicating membership groups to progress through, in order.
#'
#' @param irl Matrix. Principal components matrix, output from `BarCluster::irlba_wrap`.
#' @param bt Data table. Barcode table of two columns cell IDs ("rn") and barcodes ("Barcode").
#' @param alpha Numeric. Alpha parameter or list of values to iterate over. Ranges from 0 to 1. A value of zero reflects only transcriptome edges, a value of one reflects only barcodes.
#' @param beta Numeric. Exponent on alpha to adjust curve sloping. Default is 0.1.
#' @param res Numeric. Resolution parameter passed to community detection algorithm.
#' @param method c("fast", "index"), how the barcode matrix is made, default is fast, if its going too slow try "index".
#' @param ... Additional arguments passed to `RunModularityClustering`.
#'
#' @import magrittr
#' @import data.table
#' @import Seurat
#' @import ggplot2
#' @import cowplot
#' @import scales
#' @import purrr
#' @import stringr
#' @import testthat
#' @import stats
#' @import uwot
#' @import reticulate
#' @import irlba
#' @import ROCR
#' @import ggalluvial
#' @import utils
#'
#' @return A long format data table with three columns, cell ID ("rn"), alpha value, beta value, and cluster assignment ("Group").
#'
#' @export barcluster
#' @md
barcluster <- function(irl, bt, alpha = c(0, 0.5, 1), beta = 0.1, res = 1, method = "fast", ...){

  if (method == "fast") nm <- build_barcode_matrix_fast(bt)

  if (method == "index") nm <- build_barcode_matrix(bt)

  if (!all(sort(rownames(nm)) == sort(rownames(irl)))) stop("barcodes names don't match PCA")

  neighbor.graphs <- Seurat::FindNeighbors(object = irl, k.param = 20,
            compute.SNN = TRUE, prune.SNN = 1/15,
            nn.method = "rann", annoy.metric = "euclidean",
            nn.eps = 0, verbose = TRUE, force.recalc = FALSE)

  m <- neighbor.graphs$snn

  rm("neighbor.graphs")

  beta_val <- beta

  dl <- lapply(alpha, function(alpha){

    # this internal function will make sure m and nm are in the same order
    mm2 <- barcluster_model(alpha = alpha, beta = beta_val, m = m, nm = nm)

    ids_b <- Seurat:::RunModularityClustering(SNN = mm2, resolution = res, ...)

    names(ids_b) <- colnames(mm2)

    ids_b <- matrix(ids_b, ncol = 1, dimnames = list(names(ids_b)))

    colnames(ids_b) <- "Group"

    ids_b %<>% as.data.table(keep.rownames = TRUE)

    ids_b[, alpha := alpha]

    ids_b[, resolution := res]

    return(ids_b)

  }) %>% data.table::rbindlist()

  dl[, beta := beta_val]

  return(dl)

}
