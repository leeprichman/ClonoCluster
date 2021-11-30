## ---- Plot_alluvia_track
#' Plot a Sankey Diagram from a table of unique IDs, and two or more columns indicating membership groups to progress through, in order.
#'
#' @param dl A data table, with three columns, c("rn", "Group", "alpha").
#' @param ids List. A list of character vectors containing rownames in dl (cellIDs) for each group to be tracked.
#' @param cols Character. Vector of colors values of length equal to the number of groups to be tracked.
#' @param title Character. Passed to `ggtitle`.
#' @param xlab Character. Passed to `xlab`.
#' @param ylab Character. Passed to `ylab`.
#' @param flow_alpha Numeric. Alpha value for the alluvial ribbons.
#' @param node_alpha Numeric. Alpha value for the strata, passed to geom_rect.
#' @param border_size Numeric. Rectangle thickness around the sankey nodes. Default 2.
#' @param label_nodes Boolean. Should clusters be labeled with geom_label? Default TRUE.
#' @param label_size Numeric. size of geom_text labels font.
#' @param ltype One of c("label", "text"). Passed as the geom to annotation. Default is "label"
#'
#' @return Returns a ggplot object or two of the Sankey Plot.
#'
#' @export Plot_alluvia_track
#' @md
Plot_alluvia_track <- function(dl,
                        ids,
                        title = "",
                        xlab = "",
                        ylab = "",
                        flow_alpha = 0.2,
                        node_alpha = 1,
                        border_size = 2,
                        label_nodes = TRUE,
                        label_size = 2,
                        ltype = "text",
                        cols = BarCluster::cw_colors){

    dt <- dl %>% data.table::copy() %>% .[, .SD, .SDcols = c("rn", "Group", "alpha")]

    if (class(ids)[1] != "list") ids <- list(ids)

    dt[, alpha := as.factor(alpha)]

    lapply(ids %>% seq_along, function(l){

      dt[rn %chin% ids[[l]], init := paste0("L", l)]

    })

    dt[is.na(init), init := "00"]

    dt[, Group := factor(Group, ordered = TRUE, levels = rev(dt[, Group %>% unique %>% sort]))]

    dt[, init := as.factor(init)]

    dt <- dt[, .SD, .SDcols = c("rn", "alpha", "Group", "init")]

    nt <- dt[, .N, by = c("alpha", "Group")]

    ntl <- nt %>% split(by = "alpha")

    nt <- lapply(ntl, function(nt){

      nt %<>% .[order(-Group)]

      nt[, ymax := cumsum(N)]

      nt[, ymin := ymax - N]

    }) %>% data.table::rbindlist()

    nt[, label := paste("Alpha ", alpha, ":\n", Group, sep = "")]

    nt[, y := mean(c(ymax, ymin)), by = 1:nrow(nt)]

    rt <- dt[, .N, by = c("Group", "alpha", "init")]

    rt <- merge(rt,
      nt[, .SD %>% unique, .SDcols = c("alpha", "Group", "ymin", "ymax")],
      by = c("Group", "alpha"))

    rtl <- rt %>% split(by = c("Group", "alpha"))

    rt <- lapply(rtl, function(rt){

      rt %<>% .[order(init)]

      rt[, cumN := cumsum(N)]

      rt[, ysmax := ymin + cumN]

      rt[, ysmin := ysmax - N]

    }) %>% data.table::rbindlist()

    rt[, xmin := as.numeric(alpha) - 0.17]

    rt[, xmax := as.numeric(alpha) + 0.17]

    v <- rt$init %>% unique %>% sort

    names(v) <- c(cols[1:(length(v) - 1)], "grey")

    rt[, initcol := names(v)[which(v == init)] %>% unique, by = "init"]

    rt2 <- rt[, .SD %>% unique, .SDcols = c("Group", "alpha", "xmin", "xmax", "ymin", "ymax")]

    val1 <- names(v)

    names(val1) <- v

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
      ggtitle(title)

      p <- p +
      annotate("rect",
      xmin = rt$xmin, xmax = rt$xmax, ymax = rt$ysmax, ymin = rt$ysmin,
      color = NA, fill = rt$initcol, alpha = node_alpha) +
      annotate("rect",
      xmin = rt2$xmin, xmax = rt2$xmax, ymax = rt2$ymax, ymin = rt2$ymin,
      color = "black", fill = NA, size = border_size)

      if (label_nodes) p <- p +
      annotate(ltype,
      x = nt$alpha, y = nt$y, label = nt$label,
      size = label_size)

      return(p)

}
