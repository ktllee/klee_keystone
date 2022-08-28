# functions to deal with the clustering

# create clusters and save (see: ../pull_data)
seed_cluster <- function (seed_dat) {
  # simplify
  page <- igraph::simplify(seed_dat$pagenet)
  
  # clusters
  true_comm <- make_clusters(as.undirected(page, mode = 'collapse'),
                             membership = V(page)$comm)
  hier <- cluster_fast_greedy(as.undirected(page, mode = 'collapse'))
  label <- cluster_label_prop(as.undirected(page, mode = 'collapse'))
  louvain <- cluster_louvain(as.undirected(page, mode = 'collapse'))
  infomap <- cluster_infomap(as.undirected(page, mode = 'collapse'))
  walktrap <- cluster_walktrap(as.undirected(page, mode = 'collapse'))
  
  # in case spectral fails out
  spectral <- tryCatch({
    cluster_leading_eigen(as.undirected(page, mode = 'collapse'))},
    error = function (e) {NULL})

  # save
  seed_cluster <-
    list(true = true_comm, hier = hier, spec = spectral, label = label,
         louvain = louvain, infomap = infomap, walktrap = walktrap)
  
  # append to existing data
  single_item <- list(cluster = seed_cluster)
  new_dat <- c(seed_dat, single_item)
  return(new_dat)
}


# confusion matrix
plot_cluster <- function (seed_dat, method_long) {
  # possible methods:  vi, nmi, split.join, rand, adjusted.rand
  method_name <- c('Variation of information', 'Normalized mutual information',
                  'Split-join distance', 'Rand Index', 'Adjusted Rand Index')
  method_poss <- c('vi', 'nmi', 'split.join', 'rand', 'adjusted.rand')
  method_nicks <- c('VI', 'NMI', 'S/J', 'RI', 'ARI')
  nick <- method_nicks[which(method_name == method_long)]
  method <- method_poss[which(method_name == method_long)]
  
  # cluster types in order
  candid <- seed_dat$cluster
  if (is.null(candid$spec)) {
    cluster_types <- c('True', 'Hierarchical', 'Label Prop.',
                       'Louvain', 'Infomap', 'Walktrap')
  } else {
    cluster_types <- c('True', 'Hierarchical', 'Spectral', 'Label Prop.',
                       'Louvain', 'Infomap', 'Walktrap')
  }
  n <- length(cluster_types)
  
  # comparison matrix
  final <- matrix(0, length(candid), length(candid))
  for (i in seq_along(candid)) {
    for (j in seq_along(candid)) {
      final[i, j] = igraph::compare(candid[[i]], candid[[j]], method)
    }
  }
  rownames(final) <- cluster_types
  colnames(final) <- rownames(final)
  
  # set up matrix for plotting
  net_mat <- final %>% 
    as.data.frame() %>%
    rownames_to_column('cluster1') %>%
    pivot_longer(-c(cluster1), names_to = 'cluster2', values_to = 'index')
  indorder <- sort(net_mat$index)
  if (method %in% c('vi', 'split.join')) {
    minind <- indorder[n + 1]
    maxind <- indorder[n^2]
  } else {
    minind <- indorder[1]
    maxind <- sort(net_mat$index)[n^2 - n]
  }
  
  # plot
  ggplot(net_mat, aes(cluster1, cluster2)) +
    geom_tile(aes(fill = index), color = 'grey', size = 0.5) + 
    geom_text(aes(label = round(index, 3))) +
    scale_fill_viridis_c(option = 'A', direction = 1,
                         limits = c(minind, maxind),
                         begin = 0.2, end = 1, alpha = 0.7) +
    theme(axis.text.x = element_text(angle = 30)) +
    labs(x = 'Method 1', y = 'Method 2', fill = nick) %>% 
    return()
}
