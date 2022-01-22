[![codecov](https://codecov.io/gh/leeprichman/BarCluster/branch/main/graph/badge.svg?token=GBJDQCGAWZ)](https://codecov.io/gh/leeprichman/BarCluster)![](https://img.shields.io/docker/pulls/leeprichman/barcluster)
# BarCluster

```

    ######                 #####                                           
    #     #   ##   #####  #       #      #    #  ####  ##### ###### #####  
    #     #  #  #  #    # #       #      #    # #        #   #      #    #
    ######  #    # #    # #       #      #    #  ####    #   #####  #    #
    #     # ###### #####  #       #      #    #      #   #   #      #####  
    #     # #    # #   #  #       #      #    # #    #   #   #      #   #  
    ######  #    # #    #  #####  ######  ####   ####    #   ###### #    #     

```
*Lineage barcodes as ground truth clusters in single cell RNA sequencing*

![](https://github.com/leeprichman/BarCluster/blob/main/readme_fig.png)

Welcome to BarCluster. To get started, you will need:

  1. A normalized or scaled count matrix of your barcoded cells

  2. A table of unique cell IDs and their assigned barcodes

You may also use sample data and a worked example demonstrated in the [tutorial](https://github.com/leeprichman/BarCluster/blob/main/Tutorial.html). If you are looking for the analysis and raw data from our 2022 paper, check out [this repo](https://github.com/leeprichman/BarCluster_paper).

## Dependencies

  * R version >= 3.6

  * `devtools` package for installation

## Installation

BarCluster is easily installed with the help of the `devtools` package:

```
install.packages("devtools")

devtools::install_github("leeprichman/BarCluster")
```

## Docker

BarCluster is also availble to use within a prebuilt docker image:

```
# pull the docker image
docker pull leeprichman/barcluster

# launch a container

cID=$(docker run -it -d leeprichman/barcluster /bin/bash)

# move any desired files onto the container

docker cp myfile.txt $cID:/myfilecopy.txt

# launch the interactive container

docker exec -it $cID bash

# launch R

R

```

Now you may follow the [tutorial](https://github.com/leeprichman/BarCluster/blob/main/Tutorial.html) or walkthrough below. At the end of the analysis you may recover output and shut down the container with:

```
docker cp $cID:/myoutput.txt ~/myagdockeroutput.txt

docker stop $cID

docker rm $cID

```

### Quickstart guide

#### Prep your input data

The input files you will need are:

 1. a two column table of cell IDs and Barcode assignments with the column names "rn" and "Barcode" respectively.

 2. a count matrix, with a a first column, "rn", of cell IDs and columns of gene counts

The latter can be retrieved from your Seurat object if you already have one:

```

cm <- myseuratobject[["RNA"]]@data

# transpose it so rows are cells and columns are genes
cm <- t(as.matrix(cm))

cm <- data.table::as.data.table(cm, keep.rownames = TRUE)

# save to file
data.table::fwrite(cm, "mycountmatrix.tsv", sep = "\t")

```

**N.B.:** *Make sure that cell IDs present in the barcode table are the only ones present in the count matrix and vice versa, otherwise you will get errors!*

#### Barcluster

For a worked example using provided sample data, check out the [tutorial](https://github.com/leeprichman/BarCluster/blob/main/Tutorial.html).

The first step is to generate our PCA matrix:

```
library(magrittr)
library(data.table)
library(BarCluster)

cm <- data.table::fread("mycountmatrix.tsv")

# convert data table to matrix
# make sure that rows are cells and columns are genes!
cm %<>% dt2m

# using 25 PCs
pca <- irlba_wrap(cm, npc = 25)

```

Now read in barcodes and BarCluster!

```
# two column table, "rn" (cell ID) and "Barcode"
bt <- data.table::fread("mybarcodetable.tsv")

# return the cluster assignments for range of alphas
clust <- barcluster(pca, bt, alpha = seq(0, 1, by = 0.1), beta = 0.1, res = 1)

```

`clust` is a data table with the cluster assignment of each cell at all alpha values.

#### Sankey visualization

Let's make a Sankey plot of the data. We will use the top 10 barcodes so that we can take the plot all the way to alpha = 1 without being unable to interpret it.

```
# get top 10 barcodes
wl <- bt[, .N, by = "Barcode"] %>% .[order(-N), Barcode[1:10]]

# get the cell ids from the top 10 barcodes
wl <- bt[Barcode %chin% wl, rn]

# plot alluvia
Plot_alluvia(clust[rn %chin% wl], # subset on cell IDs
              bt[rn %chin% wl], # subset on cell IDs
              col = cw_colors, # provided vector of colors
              border_size = 0.5,
              label_nodes = FALSE,
              xlab = "\u03B1", # unicode for alpha
              ylab = "# of cells")

```

This is a sample of what this looks like for the top 10 barcodes in the tutorial sample data:

![](https://github.com/leeprichman/BarCluster/blob/main/sankey_sample.png)

#### UMAP and Warp Factor

You can also generate UMAPs projections for visualization:

```

# warp factor of 0 (default UMAP)
umap_wf0 <- engage_warp(pca, bt, 0)

# warp factor of 5
umap_wf5 <- engage_warp(pca, bt, 5)

# warp factor of 10 (maximum)
umap_wf10 <- engage_warp(pca, bt, 10)

# combine to one table
umap <- list(umap_wf0, umap_wf5, umap_wf10) %>% data.table::rbindlist()

# plot
ggplot(umap, aes(x = UMAP_1, UMAP_2)) +
  geom_point(col = "dodgerblue") +
  facet_wrap(~warp, nrow = 1) +
  theme_void()

```

![](https://github.com/leeprichman/BarCluster/blob/main/sample_warps.png)

#### Other functions

Check out the [tutorial](https://github.com/leeprichman/BarCluster/blob/main/Tutorial.html) for:

  * Cluster number analysis to choose alpha values

  * Barcode to cluster concordance plots with `cast_confusion`

  * Cluster marker analysis with `Find_Markers_ROC`

  * Marker fidelity Sankey plots with `Plot_alluvia_track`

  * Marker fidelity heatmaps with `pheatmap`

  * Overlay clusters and UMI counts on warped UMAPs

## Testing

BarCluster is supported by unit testing with `testthat` and [codecov.io](about.codecov.io). To test the package after install:

```
testthat::test_package("BarCluster")
```

## Citation

[biorxiv link](link)

## Selected references

  * Wagner and Klein "Lineage tracing meets single-cell omics: opportunities and challenges" *Nature Reviews Genetics* 2020 [link](https://www.nature.com/articles/s41576-020-0223-2)

  * Goyal *et al.* “Cell Type Determination for Cardiac Differentiation Occurs Soon after Seeding of Human Induced Pluripotent Stem Cells.” *bioRxiv* 2021 [link](https://doi.org/10.1101/2021.08.08.455532)
