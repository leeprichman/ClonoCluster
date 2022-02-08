test_that("full clonocluster", {

  pca <- readRDS(file.path(tdir, "pca.RDS"))

  clust <- clonocluster(pca, bt, alpha = c(0,0.25, 0.5, 0.75 ,1), beta = 1, res = 1.5)

  to <- file.path(tdir, "test_clonocluster_output.tsv") %>% data.table::fread()

  testthat::expect_equal(clust, to)

})
