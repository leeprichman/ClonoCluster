test_that("build matrix slow then fast", {

  nm <- build_barcode_matrix(bt)

  nm2 <- build_barcode_matrix_fast(bt)

  testthat::expect_equal(nm, nm2)

  tnm <- readRDS(file.path(tdir,"barcode_matrix.RDS"))

  testthat::expect_equal(nm, tnm)

  testthat::expect_equal(nm2, tnm)

})
