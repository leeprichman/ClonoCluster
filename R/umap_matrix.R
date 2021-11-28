## ---- umap_matrix
#' Run `uwot::umap` on a matrix using Seurat v2.0 defaults.
#'
#' @param ce Matrix. Input matrix to reduce.
#' @param metric Character. Default "cosine", other options c("euclidean", "manhattan", "hamming", "correlation", "categorical").
#' @param n_neighbors Integer. Nearest neighbors to search, default 30.
#' @param n_components Integer. Number of UMAP dimensions to return.
#' @param min_dist Numeric. Minimum distance between points, default 0.3.
#' @param learning_rate Numeric. Initial learning rate for optimization. Default 1.
#' @param spread Numeric. Effective scale of embedded points. Default 1.
#' @param set_op_mix_ratio Numeric. Default is 1, pure fuzzy union.
#' @param local_connectivity Integer. Number of nearest neighbors to consider at local level. Default 1.
#' @param repulsion_strength Numeric. Weighting applied to negative sampling. Default 1.
#' @param negative_sample_rate Integer. Ratio of negative to positive samples to use for optimization of embedding. Default 5.
#' @param init Character. Default "spectral". Type of initialization for coordinates, other options c("normlaplacian", "random", "lvrandom", "laplacian", "pca", "spca", "agspectral") or matrix of coordinates.
#' @param seed_use Numeric. RNG seed passed to `set_seed`, default is 42.
#'
#' @return A data table of the input rownames, UMAP components, and seed used.
#'
#' @export umap_matrix
#' @md
umap_matrix <- function(ce,
                      metric = "cosine",
                      n_neighbors = 30L,
                      n_components = 2L,
                      min_dist = 0.3,
                      learning_rate = 1,
                      spread = 1,
                      set_op_mix_ratio = 1,
                      local_connectivity = 1L,
                      repulsion_strength = 1,
                      negative_sample_rate = 5L,
                      init = "spectral",
                      seed_use = 42,
                       ...){

  # run UMAP on PCA dimensions
  set.seed(seed_use)

  a <- uwot::umap(ce,
                  n_neighbors = n_neighbors,
                  metric = metric,
                  n_components = n_components,
                  n_epochs = NULL,
                  min_dist = min_dist,
                  learning_rate = learning_rate,
                  spread = spread,
                  set_op_mix_ratio = set_op_mix_ratio,
                  local_connectivity = local_connectivity,
                  repulsion_strength = repulsion_strength,
                  negative_sample_rate = negative_sample_rate,
                  init = init,
                  a = NULL,
                  b = NULL,
                  n_threads = 1,
                  fast_sgd = FALSE,
                  ...,
                  verbose = TRUE)

  a %<>% as.data.table

  rn <- rownames(ce)

  a <- cbind(rn, a)

  a  %>% data.table::setnames(paste0("V", 1:n_components), paste0("UMAP_", 1:n_components))

  a[, seed := seed_use]

  return(a)

}
