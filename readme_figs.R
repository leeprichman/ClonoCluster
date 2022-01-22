library(data.table)
library(magrittr)
library(Seurat)
library(BarCluster)
library(ggplot2)
library(pheatmap)
library(cowplot)

# get the location of the sample data installed with barcluster
dir <- system.file(package = "BarCluster") %>% file.path(., "extdata")

# count matrix file
cm <- file.path(dir, "YG1_sample_genes.txt") %>% data.table::fread() %>% tdt %>% dt2m

# barcode assignment file
bt <- file.path(dir, "YG1_sample_barcodes.txt") %>% data.table::fread()

# sankets
pca <- irlba_wrap(cm, npc = 25)

als <- seq(0, 1, by = 0.1)

# return the cluster assignments for range of alphas
clust <- barcluster(pca, bt, alpha = als, beta = 0.1, res = 1.5)

wl <- bt[, .N, by = "Barcode"] %>% .[order(-N), Barcode[1:10]]

wl <- bt[Barcode %chin% wl, rn]

p1 <- Plot_alluvia(clust[rn %chin% wl & alpha < 0.6],
                  bt[rn %chin% wl],
                  label_nodes = FALSE,
                  reverse = FALSE,
                  border_size = 0.5,
                  col = cw_colors
                  ) +
                  theme_void() +
                  theme(legend.position = "none",
                  plot.title = element_blank(),
                  plot.subtitle = element_blank())

ggsave(plot = p1, "sankey_void.pdf", height = 3, width = 6)

p2 <- Plot_alluvia(clust[rn %chin% wl],
                  bt[rn %chin% wl],
                  col = cw_colors,
                  border_size = 0.5,
                  label_nodes = FALSE,
                  xlab = "\u03B1",
                  ylab = "# of cells")

ggsave(plot = cowplot::plot_grid(plotlist = p2, ncol = 1), "sankey_sample.png", height = 6, width = 6)

# warp factor of 0 (default UMAP)
umap_wf0 <- engage_warp(pca, bt, 0)

# warp factor of 5
umap_wf5 <- engage_warp(pca, bt, 5)

# warp factor of 10 (maximum)
umap_wf10 <- engage_warp(pca, bt, 10)

# combine to one table
umap <- list(umap_wf0, umap_wf5, umap_wf10) %>% data.table::rbindlist()

umap %<>% .[order(warp)]

umap[, warp := paste("Warp factor =", warp)]

umap[, warpf := factor(warp,
  levels = c("Warp factor = 0", "Warp factor = 5", "Warp factor = 10"),
  ordered = TRUE)]

# plot
p <- ggplot(umap, aes(x = UMAP_1, UMAP_2)) +
  geom_point(col = cw_colors[2], size = 0.1, alpha = 0.4) +
  facet_wrap(~warpf, nrow = 1) +
  theme_void()

ggsave(plot = p, "sample_warps.png", height = 2, width = 6)

# warps for svg
# lets do multiple warp factors
wfs <- c(0, 4, 8)

# get our warped UMAPs
umaps <- lapply(wfs, function(s){

  uws <- engage_warp(pca, bt, s)

  return(uws)

}) %>% data.table::rbindlist()

# add our barcodes to the table

umaps <- merge(umaps, bt, by = "rn")

# color by barcode and put singlets into one category
umaps[, Barcode :=
        ifelse(rn %>% unique %>% length > 1, Barcode, "Singlet"),
        by = "Barcode"]

ums <- ggplot(umaps[Barcode != "Singlet"], aes(x = UMAP_1, y = UMAP_2)) +
    geom_point(aes(col = Barcode), size = 0.1, alpha = 0.5) +
    facet_wrap(~warp) +
    scale_color_manual(values = c(cw_colors, c25)) +
    ttheme +
    theme_void() +
    theme(legend.position = "none", strip.text = element_blank())

ggsave(plot = ums, "warps_void.pdf", height = 2, width = 6)
