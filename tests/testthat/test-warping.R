test_that("barcode_warp", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  pca_wf5 <- barcode_warp(pca, bt, s = 5)

  testthat::expect_equal(pca_wf5,
  readRDS(file.path(tdir, "pca_wf5.RDS")))

})

test_that("engage_warp", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  um_wf5 <- engage_warp(pca, bt, s = 5)

  # even with set seed and one thread there is randomness in UMAP by machine so we are going to just test the class
  testthat::expect_equal(class(um_wf5),
  c("data.table", "data.frame"))

  testthat::expect_equal(nrow(um_wf5),
  nrow(pca))

  # this isn't ideal but i cant stabilize randomness and tests ensure input is consistent so problem is umap

})
