test_that("clonocluster_model", {

  pca <- readRDS(file.path(tdir, "pca.RDS"))

  tnm <- readRDS(file.path(tdir,"barcode_matrix.RDS"))

  neighbor.graphs <- Seurat::FindNeighbors(object = pca, k.param = 20,
        compute.SNN = TRUE, prune.SNN = 1/15, nn.method = "rann",
        annoy.metric = "euclidean", nn.eps = 0, verbose = TRUE,
        force.recalc = FALSE)

  m <- neighbor.graphs$snn

  rm("neighbor.graphs")

  mm2 <- clonocluster_model(alpha = 0.5, beta = 1, m, tnm)

  testthat::expect_equal(mm2, readRDS(file.path(tdir, "mm2.RDS")))

})
