# panels for subcategory networks

# hidden tab panel for no categories
nocatvis <- fluidRow(
  align = 'center', 
  br(), br(),
  'Input at least one category to begin.')


# hidden tab panel for one category
onecatvis <- fluidRow(
  fluidRow(
    align = 'center',
    
    # column with data table
    column(
      width = 5,
      includeHTML('text/cat_tablelabel.txt'), br(), br(),
      dataTableOutput('table1')),
  
    # column with network graph
    column(
      width = 7,
      visNetworkOutput('catgraph1'))
    ),
  includeHTML('text/cat_netvis.txt')
)


# hidden tab panel for two categories
twocatvis <- fluidRow(
  align = 'center',
  
  fluidRow(
    # column with first category graph
    column(
      width = 6,
      column(
        width = 11,
        visNetworkOutput('catgraph1')),
      column(width = 1)
    ),
    
    # column with second category graph
    column(
      width = 6,
      column(width = 1),
      column(
        width = 11,
        visNetworkOutput('catgraph2'))
    )), br(),
  
  fluidRow(
    includeHTML('text/cat_tablelabel.txt'), br(), br(),
    # column with first category table
    column(
      width = 6,
      column(
        width = 11,
        dataTableOutput('table1')),
      column(width = 1)
    ),
    
    # column with second category table
    column(
      width = 6,
      column(width = 1),
      column(
        width = 11,
        dataTableOutput('table2'))
    )),
  
  includeHTML('text/cat_netvis.txt')
  )