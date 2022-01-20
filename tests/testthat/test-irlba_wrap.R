test_that("irlba_wrap", {

  pca <- irlba_wrap(cm, npc = 5)

  testthat::expect_equal(pca, readRDS(file.path(tdir, "pca.RDS")))

})
