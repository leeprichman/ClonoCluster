## ---- Plot_alluvia_counts
#' Plot a Sankey Diagram from a table of unique IDs, and two or more columns indicating membership groups to progress through, in order.
#'
#' @param dl A data table, with at least three columns, c("rn", "Group", "alpha"), from `barcluster`.
#' @param counts A matrix with one count column and rownames equivalent to "rn".
#' @param col_start Character. Starting value for color gradient, default is "gray100".
#' @param col_end Character. Ending value for color gradient, default is "darkblue".
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
#' @return Returns a ggplot object of the Sankey Plot, alluvia are directly proportional to counts and node colors are the average of all contributing cells.
#'
#' @export Plot_alluvia_counts
#' @md
Plot_alluvia_counts <- function(dl,
                        counts,
                        title = "",
                        xlab = "",
                        ylab = "",
                        flow_alpha = 0.2,
                        node_alpha = 1,
                        border_size = 2,
                        label_nodes = TRUE,
                        label_size = 2,
                        ltype = "text",
                        col_start = "gray100",
                        col_end = "darkblue"){

    dt <- dl %>% data.table::copy() %>% .[, .SD, .SDcols = c("rn", "Group", "alpha")]

    dt[, alpha := as.factor(alpha)]

    dt[, Group := factor(Group, ordered = TRUE, levels = rev(dt[, Group %>% unique %>% sort]))]

    dt <- dt[, .SD, .SDcols = c("rn", "alpha", "Group")]

    nt <- dt[, .N, by = c("alpha", "Group")]

    ntl <- nt %>% split(by = "alpha")

    nt <- lapply(ntl, function(nt){

      nt %<>% .[order(-Group)]

      nt[, ymax := cumsum(N)]

      nt[, ymin := ymax - N]

    }) %>% data.table::rbindlist()

    nt[, label := paste("Alpha ", alpha, ":\n", Group, sep = "")]

    nt[, y := mean(c(ymax, ymin)), by = 1:nrow(nt)]

    rt <- dt[, .N, by = c("Group", "alpha")]

    rt <- merge(rt,
      nt[, .SD %>% unique, .SDcols = c("alpha", "Group", "ymin", "ymax")],
      by = c("Group", "alpha"))

    rt[, xmin := as.numeric(alpha) - 0.17]

    rt[, xmax := as.numeric(alpha) + 0.17]

    if (class(counts)[1] == "matrix" || class(counts)[1] == "array"){

      counts <- data.table::data.table(rn = rownames(counts), UMI = counts[, 1])

    }

    counts %>% setnames(names(counts), c("rn", "UMI"))

    dt <- merge(dt, counts, by = "rn")

    dt[, mean_UMI := mean(UMI), by = c("Group", "alpha")]

    cv <- dt[, mean_UMI %>% unique %>% sort]

    cvv <- colorRampPalette(c(col_start,col_end))(length(cv))

    cvt <- data.table::data.table(mean_UMI = cv, cvv)

    dt <- merge(dt, cvt, by = "mean_UMI")

    names(cvv) <- cvv

    p <- ggplot(dt,
           aes(x = alpha, stratum = Group, alluvium = rn,
               label = Group)) +
      scale_color_gradient(low = col_start, high = col_end, name = "scaled counts") +
      scale_fill_manual(values = cvv, guide = "none") +
      geom_flow(stat = "alluvium", lode.guidance = "frontback",
                aes(color = UMI), alpha = flow_alpha) +
      geom_stratum(color = "black", aes(fill = cvv), size = border_size, alpha = node_alpha) +
      theme_bw() +
      theme(legend.position = "right",
            legend.title = element_text(size = 6),
            legend.key.size = unit(5, "mm"),
            legend.text = element_text(size = 6),
            plot.title = element_text(hjust = 0.5, face = "bold"),
            panel.grid = element_blank(),
            axis.line.x = element_blank(),
            panel.border = element_blank()) +
      xlab(xlab) +
      ylab(ylab) +
      ggtitle(title)

      # p <- p +
      # annotate("rect",
      # xmin = rt$xmin, xmax = rt$xmax, ymax = rt$ysmax, ymin = rt$ysmin,
      # color = NA, fill = rt$initcol, alpha = node_alpha)

      if (label_nodes) p <- p +
      annotate(ltype,
      x = nt$alpha, y = nt$y, label = nt$label,
      size = label_size)

      return(p)

}
