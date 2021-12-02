## ---- RunModularityClustering
#' internal function to run louvain algorithm lifted from `Seurat`.
#'
#' @export RunModularityClustering
#' @md
RunModularityClustering <- function(
  SNN = matrix(),
  modularity = 1,
  resolution = 1,
  algorithm = 1,
  n.start = 1,
  n.iter = 10,
  random.seed = 42,
  print.output = TRUE,
  temp.file.location = NULL,
  edge.file.name = NULL
) {
  edge_file <- ''
  clusters <- RunModularityClusteringCpp(
    SNN,
    modularity,
    resolution,
    algorithm,
    n.start,
    n.iter,
    random.seed,
    print.output,
    edge_file
  )
  return(clusters)
}

## ---- RunModularityClusteringCpp
#' internal function to call C code from`Seurat` for community detection.
#'
#' @export RunModularityClusteringCpp
#' @md
RunModularityClusteringCpp <- function(SNN, modularityFunction, resolution,
  algorithm, nRandomStarts, nIterations, randomSeed, printOutput,
  edgefilename) {
    .Call('_Seurat_RunModularityClusteringCpp', PACKAGE = 'Seurat', SNN,
    modularityFunction, resolution, algorithm, nRandomStarts, nIterations,
    randomSeed, printOutput, edgefilename)
}
