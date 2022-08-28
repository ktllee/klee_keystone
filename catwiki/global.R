# dependencies
library(shiny)
library(shinythemes)
library(tidyverse)
library(DT)
library(igraph)
library(visNetwork)

# helpers
source('helpers/clean.R')
source('helpers/cluster.R')
source('helpers/family.R')

# master list of file and cat names
namekey <- read_csv('data/names.csv') %>%
  mutate(full = paste0('Category:', title))

# master lists of choices
cluster_type <- 
  c('True', 'Hierarchical', 'Spectral', 'Label Prop.', 'Louvain',
    'Infomap', 'Walktrap')
index_type <- 
  c('Variation of information', 'Normalized mutual information',
    'Split-join distance', 'Rand Index', 'Adjusted Rand Index')

# panels
source('panels/catnetvis.R')
source('panels/clustermat.R')
source('panels/clusternames.R')
source('panels/pagnetvis.R')

# data import
datam <- readRDS('data/nets.rds')