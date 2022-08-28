# server
function(input, output, session) {
  
  # title button
  observeEvent(input$title, {
    updateNavbarPage(session, 'catwiki', 'Category')
  })
  
  ##### inputs and setup
  n <- reactive({
    if (is.null(input$cats)) {0}
    else {length(input$cats)}})
  
  # initialize reactives
  cats <- reactiveValues()
  
  # names
  observe({
    cats$one <- if (n() == 0) {'Fishing'} else {input$cats[1]}
    cats$two <- if (n() == 2) {input$cats[2]} else {cats$one}
  })
  
  # data
  seed_dat1 <- reactive({
    datam[[namekey$seed[which(namekey$title == cats$one)]]]})
  seed_dat2 <- reactive({
    datam[[namekey$seed[which(namekey$title == cats$two)]]]})
  
  # cluster comparison choices
  compare_method1 <- reactive({input$compind1})
  compare_method2 <- reactive({input$compind2})
  
  # cluster method choices
  cluster_method1 <- reactive({input$cluster1})
  cluster_method2 <- reactive({input$cluster2})
  
  # update choices for page cluster lists
  observeEvent(c(input$cats, input$cattabs), {
    updateSelectizeInput(
      session = session, inputId = 'page1',
      choices = seed_dat1()$pagnode[['title']],
      server = TRUE)
    updateSelectizeInput(
      session = session, inputId = 'page2',
      choices = seed_dat2()$pagnode[['title']],
      server = TRUE)})
  
  # page cluster choices
  page_choice1 <- reactive({input$page1})
  page_choice2 <- reactive({input$page2})
  
  # page network category choice
  seed_datp <- reactive({
    datam[[namekey$seed[which(namekey$title == input$pagcats)]]]})
  
  
  ##### outputs
  # table of names
  output$name_table <- 
    renderDataTable({datatable(select(namekey, -seed), rownames = F)})
  
  # names (for both comparison matrices and cluster lists)
  output$name1m <- renderText({cats$one})
  output$name2m <- renderText({cats$two})
  output$name1n <- renderText({cats$one})
  output$name2n <- renderText({cats$two})
  
  # tables of categories
  output$table1 <- renderDataTable({
    datatable(subcatdf(seed_dat1()), rownames = F,
              options = list(ordering = F))})
  output$table2 <- renderDataTable({
    datatable(subcatdf(seed_dat2()), rownames = F,
              options = list(ordering = F))})
  
  # category graphs
  output$catgraph1 <- renderVisNetwork({subcatnet(seed_dat1())})
  output$catgraph2 <- renderVisNetwork({subcatnet(seed_dat1())})
  # changes with selections
  observe({
    req(input$table1_rows_selected)
    output$catgraph1 <- 
      renderVisNetwork({subcatnet(seed_dat1(), input$table1_rows_selected)})})
  observe({
    req(input$table2_rows_selected)
    output$catgraph1 <- 
      renderVisNetwork({subcatnet(seed_dat1(), input$table2_rows_selected)})})
  
  # cluster comparison matrices
  output$matrix1 <- renderPlot(plot_cluster(seed_dat1(), compare_method1()))
  output$matrix2 <- renderPlot(plot_cluster(seed_dat2(), compare_method2()))
  
  # list of pages in group
  output$group1 <- renderPrint({
    print(findsibs(seed_dat1(), cluster_method1(), page_choice1()))})
  output$group2 <- renderPrint({
    print(findsibs(seed_dat2(), cluster_method2(), page_choice2()))})
  
  # page table and proxy
  output$tablep <- renderDataTable({
    datatable(pagedatdf(seed_datp()), rownames = F,
              options = list(ordering = F))})
  dfproxy <- dataTableProxy('tablep')
  
  # page network
  output$pagegraph <- renderVisNetwork({NULL})
  # changes with selections
  observe({
    req(input$tablep_rows_selected)
    output$pagegraph <- 
      renderVisNetwork({pagenetdisplay(seed_datp(),
                                       input$tablep_rows_selected)})})
  observeEvent(input$resetfull, {
    output$pagegraph <- renderVisNetwork({NULL})
    selectRows(dfproxy, NULL)
  })
  observeEvent(input$showfull, {
    output$pagegraph <- renderVisNetwork({pagenetdisplay(seed_datp())})
    selectRows(dfproxy, NULL)
  })
  
  # page data table
  output$pagedata <- renderDataTable({datatable(clean_node(seed_datp()))})
  
  
  ##### ui changes
  # for category network graphs
  output$catnetvis <- renderUI({
    if (n() == 0) {nocatvis}
    else if (n() == 1) {onecatvis}
    else {twocatvis}})
  
  # for cluster comparison matrices
  output$clustermat <- renderUI({
    if (n() == 0) {nocatvis}
    else {twomat}})
  
  # for cluster list comparisons
  output$clusternames <- renderUI({
    if (n() == 0) {nocatvis}
    else {twolist}})
  
}