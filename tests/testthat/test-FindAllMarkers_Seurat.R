test_that("Seurat Find Markers", {

  gt <- file.path(dir, "YG1_sample_genes.txt") %>%
        data.table::fread() %>% .[1:50] %>% dt2m()

  so <- CreateSeuratObject(counts = gt)



  marks <- FindAllMarkers_Seurat(so, clust)

})
