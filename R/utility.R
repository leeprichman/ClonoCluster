## ---- tdt
#' Flip a count matrix data.table.
#'
#' @param dt A data.table to be flipped.
#'
#' @export tdt
#' @md
tdt <- function(dt){

  rn <- dt[, .SD, .SDcols = 1] %>% unlist

  t_dt <- dt[, .SD, .SDcols = 2:ncol(dt)] %>% t

  colnames(t_dt) <- rn

  t_dt %<>% data.table::as.data.table(keep.rownames = TRUE)

  return(t_dt)

}

## ---- dt2m
#' Convert a data.table to matrix.
#'
#' @param dt A data.table to be converted to a matrix.
#'
#' @export dt2m
#' @md
dt2m <- function(dt){

  rn <- dt[, .SD, .SDcols = 1] %>% unlist

  m <- dt[, .SD, .SDcols = 2:ncol(dt)] %>% as.matrix

  rownames(m) <- rn

  return(m)

}

## ---- ttheme
#' internal function, plot theming.
#'
#' @export ttheme
#' @md
ttheme <- theme(axis.title = element_text(size = 8, face = "bold", color = "black"),
                axis.text = element_text(size = 8, color = "black"),
                plot.title = element_text(size = 8, face = "bold", color = "black", hjust = 0.5))


## ---- FindAllMarkers_Seurat
#' A wrapper to call Seurat to FindAllMarkers on given groups.
#'
#' @param so A Seurat object or path to one.
#' @param clust A table of cellIDs and group assignments.
#' @param method Passed to the `test.use` argument of `Seurat::FindAllMarkers`, default is "roc".
#' @param ... All other arguments passed to `Seurat::FindAllMarkers`.
#'
#' @return A data.table of the output.
#'
#' @export FindAllMarkers_Seurat
#' @md
FindAllMarkers_Seurat <- function(so, clust, method = "roc", ...){

  if (class(o)[1] == "character"){

    obj <- o %>% readRDS()

  } else{

    obj <- o

  }

  # replace the active.ident vector with our own classifications for cells
  v <- obj@active.ident

  vt <- data.table::data.table(rn = names(v))

  dto <- lapply(clust[, alpha %>% unique], function(a){

    vt <- merge(vt, clust[alpha == a], by = "rn", all.x = TRUE)

    if (vt[, is.na(Group) %>% any])
      warning(paste0("Not all cellIDs in Seurat Object were assigned to a group and will be",
       "treated as one NA group. Check input."))

    v2 <- vt[, Group]

    names(v2) <- vt[, rn]

    obj@active.ident <- v2 %>% as.factor

    de <- Seurat::FindAllMarkers(obj, test.use = method, ...)

    de %<>% data.table::as.data.table(keep.rownames = TRUE)

    dt[, alpha := a]

    return(de)

  }) %>% data.table::rbindlist()

  dto %>% data.table::setnames("cluster", "Group")

  if (method == "roc"){

    dto[myAUC > 0.5, direction := "greater"]
    dto[myAUC < 0.5, direction := "less"]

    # fix flipped auc
    dto[, auc := ifelse(auc == "less", 1 - myAUC, myAUC)]

    dto %<>% .[, .SD, , .SDcols = c("rn", "auc", "direction", "Group", "alpha")]

  }

  return(dto)

}
