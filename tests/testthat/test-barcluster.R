test_that("full barcluster", {

  pca <- readRDS(file.path(tdir, "pca.RDS"))

  clust <- barcluster(pca, bt, alpha = c(0,0.25, 0.5, 0.75 ,1), beta = 1, res = 1.5)

  to <- file.path(tdir, "test_barcluser_output.tsv") %>% data.table::fread()

  testthat::expect_equal(clust, to)

})
