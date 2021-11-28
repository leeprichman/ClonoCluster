## ---- Plot_alluvia
#' Plot a Sankey Diagram from a table of unique IDs, and two or more columns indicating membership groups to progress through, in order.
#'
#' @param dl A data table, with three columns, c("rn", "Group", "alpha").
#' @param bl A data table, with two columns, c("rn", "Barcode")
#' @param cols Character. Vector of colors values, default is c25.
#' @param title Character. Passed to `ggtitle`.
#' @param xlab Character. Passed to `xlab`.
#' @param ylab Character. Passed to `ylab`.
#' @param flow_alpha Numeric. Alpha value for the alluvial ribbons.
#' @param node_alpha Numeric. Alpha value for the strata, passed to geom_rect.
#' @param stack_colors Boolean. Should nodes be represented as stacked colors representing the contributing alluvia? Default TRUE.
#' @param label_nodes Boolean. Should clusters be labeled with geom_label? Default TRUE.
#' @param label_size Numeric. size of geom_text labels font.
#' @param ltype One of c("label", "text"). Passed as the geom to annotation. Default is "label"
#' @param reverse Boolean. Default TRUE, return plot colored by clusters and barcodes.
#'
#' @return Returns a ggplot object or two of the Sankey Plot.
#'
#' @export Plot_alluvia
#' @md
Plot_alluvia <- function(dl,
                        bl,
                        title = "",
                        xlab = "",
                        ylab = "",
                        flow_alpha = 0.2,
                        node_alpha = 1,
                        stack_colors = TRUE,
                        label_nodes = TRUE,
                        label_size = 2,
                        ltype = "label",
                        reverse = TRUE,
                        cols = seurat.extension::c25){

    dt <- dl %>% data.table::copy() %>% .[, .SD, .SDcols = c("rn", "Group", "alpha")]

    bt <- bl %>% data.table::copy()

    mina <- dt[, alpha %>% min]

    maxa <- dt[, alpha %>% max]

    dt0 <- dt[alpha == mina, Group, by = "rn"] %>% setnames("Group", "init")

    dt1 <- dt[alpha == maxa, Group, by = "rn"] %>% setnames("Group", "final")

    dt[, alpha := as.factor(alpha)]

    dt[, Group := factor(Group, ordered = TRUE, levels = rev(dt[, Group %>% unique %>% sort]))]

    dt <- merge(dt, dt0, by = "rn")

    dt <- merge(dt, dt1, by = "rn")

    dt[, init := as.factor(init)]

    dt[, final := as.factor(final)]

    dt <- dt[, .SD, .SDcols = c("rn", "alpha", "Group", "init", "final")]

    nt <- dt[, .N, by = c("alpha", "Group")]

    ntl <- nt %>% split(by = "alpha")

    nt <- lapply(ntl, function(nt){

      nt %<>% .[order(-Group)]

      nt[, ymax := cumsum(N)]

      nt[, ymin := ymax - N]

    }) %>% data.table::rbindlist()

    dt <- merge(dt, bt, by = "rn")

    nt <- merge(nt,
          dt[alpha == maxa, .SD %>% unique, .SDcols = c("alpha", "Group", "Barcode")],
          by = c("Group", "alpha"), all.x = TRUE)

    # collapse barcode label to single row (only necessary if max alpha is not 1)
    nt[, Barcode := paste(Barcode %>% na.omit %>% unique %>% sort, collapse = "_"), by = c("Group", "alpha")]

    nt[alpha == mina, label := paste("Tr\nCluster:", Group)]
    nt[alpha == maxa, label := paste("Barcode\n", Barcode, sep = "")]
    nt[!alpha %in% c(mina, maxa),
        label := paste("Alpha ", alpha, ":\n", Group, sep = "")]

    nt[, y := mean(c(ymax, ymin)), by = 1:nrow(nt)]

    rt <- dt[alpha != mina, .N, by = c("Group", "alpha", "init")]

    rtr <- dt[alpha != maxa, .N, by = c("Group", "alpha", "final")]

    rt <- merge(rt,
      nt[, .SD %>% unique, .SDcols = c("alpha", "Group", "ymin", "ymax")],
      by = c("Group", "alpha"))

    rtr <- merge(rtr,
      nt[, .SD %>% unique, .SDcols = c("alpha", "Group", "ymin", "ymax")],
      by = c("Group", "alpha"))

    rtl <- rt %>% split(by = c("Group", "alpha"))

    rtrl <- rtr %>% split(by = c("Group", "alpha"))

    rt <- lapply(rtl, function(rt){

      rt %<>% .[order(init)]

      rt[, cumN := cumsum(N)]

      rt[, ysmax := ymin + cumN]

      rt[, ysmin := ysmax - N]

    }) %>% data.table::rbindlist()

    rt[, xmin := as.numeric(alpha) - 0.17]

    rt[, xmax := as.numeric(alpha) + 0.17]

    rtr <- lapply(rtrl, function(rt){

      rt %<>% .[order(final)]

      rt[, cumN := cumsum(N)]

      rt[, ysmax := ymin + cumN]

      rt[, ysmin := ysmax - N]

    }) %>% data.table::rbindlist()

    rtr[, xmin := as.numeric(alpha) - 0.17]

    rtr[, xmax := as.numeric(alpha) + 0.17]

    v <- rt$init %>% unique

    names(v) <- cols[1:length(v)]

    rt[, initcol := names(v)[which(v == init)] %>% unique, by = "init"]

    v2 <- rtr$final %>% unique

    names(v2) <- cols[1:length(v2)]

    rtr[, finalcol := names(v2)[which(v2 == final)] %>% unique, by = "final"]

    rt2 <- rt[, .SD %>% unique, .SDcols = c("Group", "alpha", "xmin", "xmax", "ymin", "ymax")]

    rt2r <- rtr[, .SD %>% unique, .SDcols = c("Group", "alpha", "xmin", "xmax", "ymin", "ymax")]

    val1 <- names(v)

    names(val1) <- v

    val2 <- names(v2)

    names(val2) <- v2

    p <- ggplot(dt,
           aes(x = alpha, stratum = Group, alluvium = rn,
               label = Group)) +
      scale_color_manual(values = val1) +
      scale_fill_manual(values = val1) +
      geom_flow(stat = "alluvium", lode.guidance = "frontback",
                aes(color = init), alpha = flow_alpha) +
      geom_stratum(color = "black", aes(fill = init), size = 2, alpha = node_alpha) +
      theme_bw() +
      theme(legend.position = "none",
            plot.title = element_text(hjust = 0.5, face = "bold"),
            panel.grid = element_blank(),
            axis.line.x = element_blank(),
            panel.border = element_blank()) +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title, subtitle = "Colored by initial clusters")

      if (stack_colors) p <- p +
      annotate("rect",
      xmin = rt$xmin, xmax = rt$xmax, ymax = rt$ysmax, ymin = rt$ysmin,
      color = NA, fill = rt$initcol, alpha = node_alpha) +
      annotate("rect",
      xmin = rt2$xmin, xmax = rt2$xmax, ymax = rt2$ymax, ymin = rt2$ymin,
      color = "black", fill = NA, size = 2)

      if (label_nodes) p <- p +
      annotate(ltype,
      x = nt$alpha, y = nt$y, label = nt$label,
      size = label_size)

      if(reverse == FALSE)
        return(p)

      p2 <- ggplot(dt,
             aes(x = alpha, stratum = Group, alluvium = rn,
                 label = Group)) +
        scale_color_manual(values = val2) +
        scale_fill_manual(values = val2) +
        geom_flow(stat = "alluvium", lode.guidance = "frontback",
                  aes(color = final), alpha = flow_alpha) +
        geom_stratum(color = "black", aes(fill = final), size = 2, alpha = node_alpha) +
        theme_bw() +
        theme(legend.position = "none",
              plot.title = element_text(hjust = 0.5, face = "bold"),
              panel.grid = element_blank(),
              axis.line.x = element_blank(),
              panel.border = element_blank()) +
        xlab(xlab) +
        ylab(ylab) +
        ggtitle(title, subtitle = "Colored by barcode")

        if (stack_colors) p2 <- p2 +
        annotate("rect",
        xmin = rtr$xmin, xmax = rtr$xmax, ymax = rtr$ysmax, ymin = rtr$ysmin,
        color = NA, fill = rtr$finalcol, alpha = node_alpha) +
        annotate("rect",
        xmin = rt2r$xmin, xmax = rt2r$xmax, ymax = rt2r$ymax, ymin = rt2r$ymin,
        color = "black", fill = NA, size = 2)

        if (label_nodes) p2 <- p2 +
        annotate(ltype,
        x = nt$alpha, y = nt$y, label = nt$label,
        size = label_size)

        return(list(p, p2))

}
