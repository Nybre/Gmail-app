mailing_service_UI <- function(id) {
  ns <- NS(id)
  tagList(  
    fluidRow(
      column(width = 3,  
             box( title = strong("Control Menu"),status="warning",
                  solidHeader = FALSE,collapsible = TRUE,width = NULL,collapsed = F,
                  useShinyjs(), 
                  googleAuthUI(ns("gauth_login")),
                  br(),
                  textOutput(ns("display_username")),
                  br(),  
                  actionButton(ns("goButton"),label = "Send Mail",icon = icon("far fa-envelope"),
                               style="background-color:#b3fe73"),
                  br(),
                  textInput(ns("ftfrom"), "filter mailing table from:", 1,width = "100%"),  
                  textInput(ns("ftto"), "filter mailing table to:", 1,width = "100%")
                  
             )), 
      
      
      column(width = 9, 
             
             box(title = strong("Mailing Service"),status="info",
                 solidHeader = T,collapsible = F,width = 12,collapsed = F, height="80vh",
                 
                 textInput(ns("emailfrom"), "Email From:", "",placeholder = "type in your email.."),
                 textInput(ns("subject"), "Email Subject:", "",placeholder = "type in th mail subject..."),
                 #ensure the %s is there in the mail content as its aligned to the server
                 textAreaInput(ns("body"), "Email Body:", "",height = "15vh" ,
                               placeholder = "Hi, %s. Type the mail content here :)"),
                 
                 #create a mailing preview
                 helpText(strong("A preview of email receipients to receive the composed mail")),
                 rHandsontableOutput(ns('preview') , height = "25vh" ) 
                 
             ) 
      ) 
    )  
  )
}

mailing_service <- function(input, output, session, pool) {
  #source reactive input values
  mail_receiver<-reactive({input$emailto})  
  mail_sender<-reactive({input$emailfrom}) 
  mail_subject<-reactive({input$subject})
  mail_body<-reactive({input$body})
  input_from<-reactive({input$ftfrom})
  input_to<-reactive({input$ftto})
  
  
  #source mailing list database
  p1<-reactive({  
    results = read.csv("www/mailing_list.csv")
    return(results)
  })    
  
  #-------------------------------------------------------------
  #section deprecated, check https://github.com/MarkEdmondson1234/googleID
  #for alternatives
  ## Global variables needed throughout the app
  rv <- reactiveValues(
    login = FALSE
  )
  
  ## Authentication
  accessToken <- callModule(googleAuth, "gauth_login",
                            login_class = "btn btn-primary",
                            logout_class = "btn btn-primary")
  userDetails <- reactive({
    validate(
      need(accessToken(), "not logged in")
    )
    rv$login <- TRUE
    with_shiny(get_user_info, shiny_access_token = accessToken())
  })
  
  ## Display user's Google display name after successful login
  output$display_username <- renderText({
    validate(
      need(userDetails(), "getting user details")
    )
    userDetails()$displayName
  })
  #-------------------------------------------------------------
  
  
  ## Workaround to avoid shinyaps.io URL problems
  observe({
    if (rv$login) {
      shinyjs::onclick("gauth_login-googleAuthUi",
                       shinyjs::runjs("window.location.href = 'https://yourdomain.shinyapps.io/appName';"))
    }
  })
  
  #send email upon press of the act\on button
  observeEvent(  
    input$goButton,{  
      
      d_table = p1()
      this_hw <- mail_subject()
      #must do replace with reactive logged in email from user
      email_sender <- mail_sender()
      body <- mail_body()
      
      edat <- d_table %>%
        mutate(
          #dateF = Sys.time(), ideal to add a date mail sent for easy filtering
          To = sprintf('%s <%s>', first.name, email),
          From = email_sender,
          Subject = sprintf('Mail for %s', this_hw),
          body = sprintf(body, first.name)) %>%
        select( To, Subject, body)
      edat
      #you can add date here for easy sorting
      write.csv(edat, "www/historical-composed-emails.csv")
      
      emails <- edat %>%
        pmap(mime)
      safe_send_message <- safely(send_message)
      sent_mail <- emails %>%
        map(safe_send_message)
      
      saveRDS(sent_mail,
              paste(gsub("\\s+", "_", this_hw), "sent-emails.rds", sep = "_"))
      
      errors <- sent_mail %>%
        transpose() %>%
        .$error %>%
        map_lgl(Negate(is.null))
      sent_mail[errors]
      
    })
  
  #preview database
  output$preview<-renderRHandsontable({  
    #rename columns (replaces . tween column words)
    DF<-p1()
    DF<-DF[as.numeric(as.character(input_from())):as.numeric(as.character(input_to())),]
    colnames(DF) <- c("Key","first name","last name","email") 
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
 