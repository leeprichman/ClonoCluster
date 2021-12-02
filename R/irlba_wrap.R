## ---- irlba_wrap
#' A wrapper to run approximate PCA on a count matrix.
#'
#' @param gt Matrix. Rows are cell IDs, columns are gene counts.
#' @param npc Integer. Number of PCs to compute with `irlba::irlba`, default is 100.
#' @param seed_use Integer. RNG seed for PCA, default is 42.
#'
#' @return A matrix with cell as rows, PCs as features/columns.
#'
#' @export irlba_wrap
#' @md
irlba_wrap <- function(gt, npc = 100, seed_use = 42){

  set.seed(seed_use)

  irl <- irlba::irlba(A = gt, nv = npc)

  irl <- irl$u %*% diag(irl$d)

  colnames(irl) <- paste0("PC_", 1:ncol(irl))

  rownames(irl) <- rownames(gt)

  return(irl)

}
