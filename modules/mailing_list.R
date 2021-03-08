mailing_list_UI <- function(id) {
  ns <- NS(id)
  tagList(  
    fluidRow(
      column(width = 3,  
             box( title = strong("Control Menu"),status="warning",
                  solidHeader = FALSE,collapsible = F,width = NULL,collapsed = T,
                  textInput(ns("ftfrom_1"), "filter mailing table from:", 1,width = "100%"),  
                  textInput(ns("ftto_2"), "filter mailing table to:", 1,width = "100%")
                  
             )
      ), 
      column(width = 9, 
             box(title = strong("Mailing Table"),status="info",
                 solidHeader = T,collapsible = F,width = 12,collapsed = F, height="80vh", 
                 rHandsontableOutput(ns('tabletest') , height = "75vh" ) 
             )  ))
    
  )
}

mailing_list <- function(input, output, session, pool) {
  #source reactive input data
  input_from<-reactive({input$ftfrom_1})
  input_to<-reactive({input$ftto_2})
  
  p1<-reactive({  
    results = read.csv("www/mailing_list.csv")
    return(results)
  })      
  
  
  output$tabletest<-renderRHandsontable({   
    
    DF<-p1()
    DF<-DF[as.numeric(as.character(input_from())):as.numeric(as.character(input_to())),]
    
    colnames(DF) <- c("Key","First name","Last name","Email") 
    
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