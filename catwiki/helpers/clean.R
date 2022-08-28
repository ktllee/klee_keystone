# functions primarily for cleaning data before output

# dependencies
library(tidyverse)
library(visNetwork)

## for subcategories
# clean up subcategory data to display in table
subcatdf <- function (seed_dat) {
  display <- as.data.frame(as_ids(V(seed_dat$catnet)))
  names(display) <- c('Subcategory')
  display$Subcategory <- lapply(
    display$Subcategory, str_remove, pattern = 'Category:')
  return(display)}

# clean up subcategory data to display in visnetwork
subcatnet <- function (seed_dat, subselect = NULL) {
  # graph and subsetting
  g <- igraph::simplify(seed_dat$catnet)
  if (!is.null(subselect)) {g <- induced_subgraph(g, subselect)}
  gvis <- toVisNetworkData(g)
  gvis$nodes[['label']] <- 
    lapply(gvis$nodes[['label']], str_remove, pattern = 'Category:')
  # avoid error with no edges
  if (any(dim(gvis$edges) == 0)) {
    nodes <- data.frame(id = 1:3, font.size = 0)
    edges <- data.frame(from = c(1,2,3), to = c(2,3,1))
    display <- visNetwork(
      nodes, edges,
      main = list(text = 'No edges between selected nodes',
                  style = 'font-family:Courier')) %>% 
      visIgraphLayout(layout = 'layout_nicely') %>% 
      visNodes(color = list(background = "blue")) %>%
      visEvents(select = "function (nodes) {
        Shiny.setInputValue('current_node_selection', nodes.nodes)}")}
  # visnetwork
  else {
    display <- visNetwork(gvis$nodes, gvis$edges) %>% 
      visOptions(highlightNearest = T, nodesIdSelection = T) %>% 
      visIgraphLayout(layout = 'layout_with_graphopt') %>% 
      visNodes(color = list(background = "blue", highlight = 'red')) %>%
      visEvents(select = "function (nodes) {
        Shiny.setInputValue('current_node_selection', nodes.nodes)}")}
  return(display)}

## for pages (mostly == above, just did not want to add another argument)
# clean up page data to display in table
pagedatdf <- function (seed_dat) {
  display <- as.data.frame(as_ids(V(seed_dat$pagenet)))
  names(display) <- c('Title')
  return(display)}

# clean up page data to display in visnetwork
pagenetdisplay <- function (seed_dat, subselect = NULL) {
  # graph and subsetting
  g <- igraph::simplify(seed_dat$pagenet)
  if (!is.null(subselect)) {g <- induced_subgraph(g, subselect)}
  gvis <- toVisNetworkData(g)
  # avoid error with no edges
  if (any(dim(gvis$edges) == 0)) {
    nodes <- data.frame(id = 1:3, font.size = 0)
    edges <- data.frame(from = c(1,2,3), to = c(2,3,1))
    display <- visNetwork(
      nodes, edges,
      main = list(text = 'No edges between selected nodes',
                  style = 'font-family:Courier')) %>% 
      visIgraphLayout(layout = 'layout_nicely') %>% 
      visNodes(color = list(background = "blue")) %>%
      visEvents(select = "function (nodes) {
        Shiny.setInputValue('current_node_selection', nodes.nodes)}")}
  # visnetwork
  else {
    display <- visNetwork(gvis$nodes, gvis$edges) %>% 
      visOptions(highlightNearest = T, nodesIdSelection = T) %>% 
      visIgraphLayout(layout = 'layout_with_graphopt') %>% 
      visNodes(color = list(background = "blue", highlight = 'red')) %>%
      visEvents(select = "function (nodes) {
        Shiny.setInputValue('current_node_selection', nodes.nodes)}")}
  return(display)}

# cleaning function for page node data table
clean_node <- function (seed_dat) {
  pagnode <- seed_dat$pagnode
  # helper
  list_clean <- function (x, method) {
    listed <- unlist(strsplit(x, ','))
    listed <- list(listed[listed != ''])
    clean <- ifelse(identical(unlist(listed), character(0)), NA, listed)
    if (method == 'category') {
      uncat <- lapply(clean, str_remove, pattern = 'Category:')
      return(uncat)}
    else {
      clean <- unlist(clean)
      uniques <- unique(clean)
      return(uniques[which.max(tabulate(match(clean, uniques)))])}
  }
  # table to display
  display <- pagnode %>%
    rowwise() %>% 
    mutate(across(assess:imprtn, ~ list_clean(.x, 'mode')),
           cat = list_clean(cat, 'category')) %>% 
    select(title, chars, assess, imprtn, cat) %>% 
    rename(Title = title, Characters = chars, Assessment = assess,
           Importance = imprtn, Categories = cat)
  
  return(display)
}