test_that("Plot alluvia", {

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  p <- Plot_alluvia(to[alpha < 1], bt, ltype = "text")

  #ggsave(plot = p[[1]], file.path(tdir,"Plot_alluvia_sample_out.pdf"))

  #ggsave(plot = p[[2]], file.path(tdir, "Plot_alluvia_sample_out_reverse.pdf"))

  pdigest <- digest::digest(p, algo = "md5")

  testthat::expect_equal(pdigest,
  "1e862583de4d4ee36e82124a57b37a7a")

})

test_that("Plot alluvia track", {

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  p <- Plot_alluvia_track(to[alpha < 1],
              ids = list(bt[Barcode == "C9", rn],
                        bt[Barcode == "C1", rn],
                        bt[Barcode == "C5", rn]),
              ltype = "text",
              col2 = "grey80")

  #ggsave(plot = p, file.path(tdir,"Plot_alluvia_track_out.pdf"))

  pdigest <- digest::digest(p, algo = "md5")

  testthat::expect_equal(pdigest,
  "6fd7d816f5cdb787f4ef831eacee2066")

})

test_that("Plot alluvia counts", {

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  p <- Plot_alluvia_counts(to[alpha < 1],
              counts = cm[, "ACTA2"] %>% as.matrix,
              ltype = "text")

  #ggsave(plot = p, file.path(tdir,"Plot_alluvia_counts_out.pdf"))

  pdigest <- digest::digest(p, algo = "md5")

  testthat::expect_equal(pdigest,
  "145ec2add40470af7fc3d0f603527c96")

})
