# functions for finding a "family" of nodes in the same cluster

# return sibling pages given cluster method and page
findsibs <- function (seed_dat, cluster, page_choice) {
  # access network of pages
  pagenet <- seed_dat$pagenet
  # save cluster type
  nicks <- c('true', 'hier', 'spec', 'label', 'louvain', 'infomap', 'walktrap')
  cluster_scheme <- nicks[which(cluster_type == cluster)]
  clustering <- seed_dat$cluster[[cluster_scheme]]
  # gather members
  memb <- clustering$membership[V(pagenet)$name == page_choice]
  memb_nodes <- V(pagenet)[clustering$membership == memb]
  return(as_ids(memb_nodes))
}


