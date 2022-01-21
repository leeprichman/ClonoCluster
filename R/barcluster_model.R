## ---- barcluster_model
#' Return the barcluster network graph for clustering.
#'
#' @param alpha Numeric. Between zero and one, with zero representing complete transcriptome and 1 representing complete barcode graphs.
#' @param beta Numeric. Exponent on alpha to adjust curve sloping. Default is 0.1.
#' @param m Object of class `dgCMatrix`, the graph of transcriptome edges derived from SNN jaccard index. Usually from `Seurat::FindNeighbors`.
#' @param nm Output of `build_barcode_matrix` or `build_barcode_matrix_fast`.
#'
#' @return A sparse matrix of class `dgCMatrix` suitable for `Seurat:::RunModularityClustering`.
#'
#' @export barcluster_model
#' @md
barcluster_model <- function(alpha, beta = 0.1, m, nm){

  nm <- nm[rownames(m), colnames(m)]

  mm2 <- ((alpha ^ beta) * (nm - m)) + m

  mm2 %<>% as.matrix %>% as("dgCMatrix")

  return(mm2)

}
