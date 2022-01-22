test_that("umap matrix", {

  pca <- file.path(tdir, "pca.RDS") %>% readRDS

  um <- umap_matrix(pca, seed_use = 42)

  # even with set seed and one thread there is randomness in UMAP by machine so we are going to just test the class
  testthat::expect_equal(class(um),
  c("data.table", "data.frame"))

  testthat::expect_equal(nrow(um),
  nrow(pca))

  # this isn't ideal but i cant stabilize randomness and tests ensure input is consistent so problem is umap

})
