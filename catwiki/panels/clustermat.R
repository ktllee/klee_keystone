# panels for cluster comparison matrices

# hidden tab panel for one category
twomat <- tabPanelBody(
  'mats1',
  
  fluidRow(
    # category with first index
    column(
      width = 6,
      column(
        width = 11,
        textOutput('name1m'),
        selectInput(
          inputId = 'compind1',
          label = 'Comparison Index',
          choices = index_type,
          width = '100%'),
        fluidRow(plotOutput('matrix1'))),
      column(width = 1)
    ),
    
    # category with second index
    column(
      width = 6,
      column(width = 1),
      column(
        width = 11,
        textOutput('name2m'),
        selectInput(
          inputId = 'compind2',
          label = 'Comparison Index',
          choices = index_type,
          width = '100%'),
        fluidRow(plotOutput('matrix2')))
    )), br(),
    
  includeHTML('text/cat_clustermat.txt')
)