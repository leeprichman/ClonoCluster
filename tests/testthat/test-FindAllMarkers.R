test_that("Seurat Find Markers", {

  gt <- file.path(dir, "YG1_sample_genes.txt") %>%
        data.table::fread() %>% .[1:50] %>% dt2m()

  so <- CreateSeuratObject(counts = gt)

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  marks <- FindAllMarkers_Seurat(so, clust = to[alpha < 1])

  marks[, Group := as.character(Group) %>% as.numeric()]

  tmarks <- data.table::fread(file.path(tdir,"seurat_markers.txt")) %>%
    .[alpha < 1]

  testthat::expect_equal(marks, tmarks)

})

test_that("Find_Markers_ROC", {

  to <- file.path(tdir, "test_barcluster_output.tsv") %>% data.table::fread()

  marks <- Find_Markers_ROC(to, cm)

  tmarks <- data.table::fread(file.path(tdir,"Find_Markers_ROC_output.txt"))

  testthat::expect_equal(marks, tmarks)

})
