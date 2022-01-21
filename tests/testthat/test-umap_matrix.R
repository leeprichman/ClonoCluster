test_that("umap matrix", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  um <- umap_matrix(pca)

  testthat::expect_equal(um,
  data.table::fread(file.path(tdir, "umap.txt")))

})
