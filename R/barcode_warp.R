## ---- barcode_warp
#' Warp principal components towards linear projection of barcodes.
#' @param irl Matrix. Principal components matrix, output from `BarCluster::irlba_wrap`.
#' @param bt Data table. Barcode table of two columns cell IDs ("rn") and barcodes ("Barcode").
#' @param alpha Numeric. Alpha parameter, from 0 to 1.
#'
#' @return A matrix of the same dimensions as `irl` suitable for further reduction by UMAP. 
#'
#' @export barcode_warp
#' @md
barcode_warp <- function(irl, bt, alpha){

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

  revise_mat <- function(irl, mw, alpha){

      mo <- irl - mw

      mo <- mo * alpha

      mo <- irl - mo

      return(mo)

    }

  mo <- revise_mat(irl, mw, alpha)

  return(mo)

}
