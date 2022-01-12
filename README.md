# BarCluster
Lineage informed scRNAseq clustering method

  * docker badge

## Citation

## Selected references

#### Dependencies

## Installation

BarCluster is easily installed with the help of the `devtools` package:

```
devtools::install_github("leeprichman/BarCluster")
```

### Docker

BarCluster is also availble to use within a prebuilt docker image:

```
# pull the docker image
docker pull leeprichman/BarCluster

# launch a container

cID=$(docker run -it -d leeprichman/BarCluster /bin/bash)

# move any desired files onto the container

docker cp myfile.txt $cID:/myfilecopy.txt

# launch the interactive container

docker exec -it $cID bash

# launch R

R

```

Now you may follow the usage examples below. At the end of the analysis you may recover output and shut down the container with:

```
docker cp $cID:/myoutput.txt ~/myagdockeroutput.txt

docker stop $cID

docker rm $cID

```

### Walkthrough

#### Prep your input data

The input files you will need are:

 1. a two column table of cell IDs and Barcode assignments with the column names "rn" and "Barcode" respectively.

 2. a count matrix, with a a first column, "rn", of cell IDs and columns of gene counts

The latter can be retrieved from your Seurat object if you already have one:

```

cm <- myseuratobject[["RNA"]]@data

cm <- t(as.matrix(cm))

cm <- data.table::as.data.table(cm, keep.rownames = TRUE)

data.table::fwrite(cm, "mycountmatrix.tsv", sep = "\t")

```

**N.B.:** *Make sure that cell IDs present in the barcode table are the only ones present in the count matrix and vice versa, otherwise you will get errors!*

#### Barcluster

For a worked example using provided sample data, see link.

The first step is to generate our PCA matrix:

```
library(magrittr)
library(data.table)
library(BarCluster)

cm <- data.table::fread("mycountmatrix.tsv")

cm %<>% dt2m

# using 25 PCs
pca <- irlba_wrap(cm, npc = 25)

```

Now read in barcodes and BarCluster!

```

bt <- data.table::fread("mybarcodetable.tsv")

# return the cluster assignments for range of alphas
clust <- barcluster(pca, bt, alpha = seq(0, 1, by = 0.1), beta = 0.1, res = 1)

```

#### diagnostic plots to identify alphas

#### Sankey plot

#### warp umap

#### identify markers
