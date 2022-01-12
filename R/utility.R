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
