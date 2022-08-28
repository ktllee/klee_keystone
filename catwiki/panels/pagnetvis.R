# panels for tabs about page data

# tab panel for page networks
netvis <- fluidRow(
  align = 'center',
  includeHTML('text/pagenet_warning.txt'),
  
  # column with data table
  column(
    width = 5,
    actionButton('showfull', 'Load Full Graph'),
    actionButton('resetfull', 'Reset'), br(), br(),
    dataTableOutput('tablep')),
  
  # column with network graph
  column(
    width = 7,
    visNetworkOutput('pagegraph'))
)


# tab panel for page data
datvis <- fluidRow(
  align = 'center', 
  br(), br(),
  dataTableOutput('pagedata'))