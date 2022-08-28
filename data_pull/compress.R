# dependencies
library(tidyverse)
library(igraph)

# master list of file and cat names
namekey <- read_csv('data_pull/names.csv') %>%
  mutate(full = paste0('Category:', title))

########## data import
# function to read a single seed
read_seed <- function (seed) {
  filenames <- list.files(path = 'data_pull/data',
                          pattern = paste0('^', seed, '\\D.*csv$'))
  filenames <- paste0('data_pull/data/', filenames)
  seed_dat <- lapply(filenames, read_csv)
  names(seed_dat) <- c('catedge', 'pagedge', 'pagnode')
  return(seed_dat)
}
# apply to all seeds
datam <- lapply(namekey$seed, read_seed)
names(datam) <- namekey$seed

######### networks
# function to produce necessary networks
seed_net <- function (seed_dat) {
  # cleaning data frames
  seed_dat$pagnode[['onecat']] <- 
    lapply(seed_dat$pagnode[['cat']], function(x) strsplit(x, ',')[[1]])
  seed_dat[[3]] <- seed_dat[[3]] %>% 
    group_by(onecat) %>% mutate(comm = cur_group_id()) %>% ungroup()
  
  # networks
  catnet <- graph_from_data_frame(seed_dat$catedge)
  pagenet <- graph_from_data_frame(seed_dat$pagedge,
                                   vertices = seed_dat$pagnode)
  nets <- list(catnet = catnet, pagenet = pagenet)
  new_dat <- c(seed_dat, nets)
  return(new_dat)
}
# apply to all
datam <- lapply(datam, seed_net)


########## clustering
# function for the community detection matrix
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

# apply to all
datam <- lapply(datam, seed_cluster)


### saving as rds
saveRDS(datam, 'data_pull/nets.rds')