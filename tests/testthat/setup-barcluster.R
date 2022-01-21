library(data.table)
library(magrittr)
library(Seurat)
library(BarCluster)
library(testthat)

# get the location of the sample data installed with barcluster
dir <- system.file(package = "BarCluster") %>% file.path(., "extdata")

# count matrix file
cm <- file.path(dir, "YG1_sample_genes.txt") %>% data.table::fread() %>% .[1:50] %>%
  tdt() %>% dt2m()

# barcode assignment file
bt <- file.path(dir, "YG1_sample_barcodes.txt") %>% data.table::fread()

tdir <- file.path(dir, "test_validation")

oldseed <- .Random.seed
