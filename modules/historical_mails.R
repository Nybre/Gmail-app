historical_mails_UI <- function(id) {
  ns <- NS(id)
  tagList(  
    fluidRow(
      column(width = 3,  
             box( title = strong("Control Menu"),status="warning",
                  solidHeader = FALSE,collapsible = F,width = NULL,collapsed = T,
                  textInput(ns("ftfrom_3"), "filter mailing table from:", 1,width = "100%"),  
                  textInput(ns("ftto_4"), "filter mailing table to:", 3,width = "100%") 
             )
      ),  
      column(width = 9, 
             box(title = strong("Mailing History"),status="info",
                 solidHeader = T,collapsible = F,width = 12,collapsed = F, height="80vh", 
                 rHandsontableOutput(ns('tabletest') , height = "75vh" ) 
             ))) 
  )
}

historical_mails <- function(input, output, session, pool) {
  #source reactive input data
  input_from<-reactive({input$ftfrom_3})
  input_to<-reactive({input$ftto_4})
  
  p1<-reactive({  
    results = read.csv("www/historical-composed-emails.csv")
    return(results)
  })      
  
  output$tabletest<-renderRHandsontable({  
    #rename columns (replaces . tween column words)
    DF<-p1()
    DF<-DF[as.numeric(as.character(input_from())):as.numeric(as.character(input_to())),]
    
    colnames(DF) <- c("Key","Mail recepient","Email subject","Email content") 
    rhandsontable(DF  ,search = TRUE)%>%
      hot_cols(columnSorting = TRUE,manualColumnResize = T) %>%
      hot_table(highlightCol = TRUE, highlightRow = TRUE)%>%
      hot_cols(fixedColumnsLeft = 1) %>%
      hot_context_menu(allowRowEdit = TRUE, allowColEdit = FALSE)%>%
      hot_cell(1, 1, "")%>% 
      
      hot_context_menu(
        customOpts = list(
          search = list(name = "Search",
                        callback = htmlwidgets::JS(
                          "function (key, options) {
              var srch = prompt('Search criteria'); 
              this.search.query(srch);
              this.render();
              }")))) %>%
      hot_cell(1, 3, "")
  }) 
} 