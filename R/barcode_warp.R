## ---- barcode_warp
#' Warp principal components towards linear projection of barcodes.
#'
#' @param irl Matrix. Principal components matrix, output from `clonocluster::irlba_wrap`.
#' @param bt Data table. Barcode table of two columns cell IDs ("rn") and barcodes ("Barcode").
#' @param s Numeric. Warp factor, from 0 to 10.
#'
#' @return A matrix of the same dimensions as `irl` suitable for further reduction by UMAP.
#'
#' @export barcode_warp
#' @md
barcode_warp <- function(irl, bt, s){

  bt %<>% data.table::as.data.table()

  mw <- lapply(bt[, Barcode %>% unique], function(bc){

      wl <- bt[Barcode == bc, rn]

      mw <- irl[wl, ]

      if (length(wl) == 1){

        mw <- mw %>% as.matrix %>% t

        rownames(mw) <- wl

        return(mw)

    }

    mv <- apply(mw, 2, mean)

      for (i in names(mv)){
        mw[, i] <- mv[i]
    }

    return(mw)

  }) %>% purrr::reduce(rbind)

  mw <- mw[rownames(irl), ]

  revise_mat <- function(irl, mw, s){

      mo <- irl - mw

      mo <- mo * (s/10)

      mo <- irl - mo

      return(mo)

    }

  mo <- revise_mat(irl, mw, s)

  return(mo)

}

## ---- engage_warp
#' Warp principal components and return modified umap.
#'
#' @param pca Matrix. Principal components matrix, output from `clonocluster::irlba_wrap`.
#' @param bt Data table. Barcode table of two columns cell IDs ("rn") and barcodes ("Barcode").
#' @param s Numeric. Warp factor, from 0 to 10.
#' @param ... Other arguments passed to `umap_matrix`.
#'
#' @return UMAP output from the warped PCA.
#'
#' @export engage_warp
#' @md
engage_warp <- function(pca, bt, s, ...){

  mo <- barcode_warp(irl = pca, bt, s)

  um <- umap_matrix(mo, ...)

  um[, warp := s]

  return(um)

}
