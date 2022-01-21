test_that("cast confusion", {

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  cc <- cast_confusion(clusters = to[, .(rn, Group)], barcodes = bt)

  cc %<>% setorderv(names(.))

  testthat::expect_equal(cc,
  data.table::fread(file.path(tdir, "cc_validation.txt")))

})
