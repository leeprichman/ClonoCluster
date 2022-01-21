test_that("barcode_warp", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  pca_wf5 <- barcode_warp(pca, bt, s = 5)

  testthat::expect_equal(pca_wf5,
  readRDS(file.path(tdir, "pca_wf5.RDS")))

})

test_that("engage_warp", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  um_wf5 <- engage_warp(pca, bt, s = 5)

  testthat::expect_equal(um_wf5,
  data.table::fread(file.path(tdir, "umap_wf5.txt")))

})
