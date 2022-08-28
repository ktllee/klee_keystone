# panels for cluster member comparison

# hidden tab panel for one category
twolist <- tabPanelBody(
  'lists1',
  
  fluidRow(
    # list of pages in cluster with first page
    column(
      width = 6,
      column(
        width = 11,
        textOutput('name1n'),
        selectizeInput(
          inputId = 'page1',
          label = 'Page',
          choices = NULL),
        selectInput(
          inputId = 'cluster1',
          label = 'Method',
          choices = cluster_type,
          width = '100%'),
        verbatimTextOutput('group1')),
      column(width = 1)
    ),
    
    # list of pages in cluster with second page
    column(
      width = 6,
      column(width = 1),
      column(
        width = 11,
        textOutput('name2n'),
        selectizeInput(
          inputId = 'page2',
          label = 'Page',
          choices = NULL),
        selectInput(
          inputId = 'cluster2',
          label = 'Method',
          choices = cluster_type,
          width = '100%'),
        verbatimTextOutput('group2'))
    )), br(),
    
  includeHTML('text/cat_clustername.txt')
)