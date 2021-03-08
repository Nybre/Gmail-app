shinyUI(dashboardPage(title= "Gmail shiny app",  
                      
                      ## HEADERBAR 
                      
                      dashboardHeader(#title = span(img(src = "images/rsz_top1.png")),  
                        tags$li(class = "dropdown", 
                                popify( tags$a(img(height = "18px",  src = "images/refresh.png"),href = "javascript:history.go(0)"),
                                        title = "Refresh",  
                                        placement = "left")
                        )     
                      ),  
                      
                      ## SIDE NAVIGATION BAR 
                      
                      dashboardSidebar(
                        collapsed = T,
                        sidebarMenu(  
                          menuItem("Mailing App", tabName = "mallingapp", icon = icon("balance-scale")) 
                        )), 
                      
                      ## MAINBODY 
                      
                      dashboardBody(  
                        setShadow(class = "box"),
                        tags$head(
                          tags$link(rel = "icon", type = "image/png", href = "OISweb.png"), 
                          tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
                          tags$style(HTML(".main-sidebar { font-size: 13px; }")),
                          tags$style(HTML(".main-sidebar {  font-weight:bold; }")),
                          tags$style(HTML(".skin-blue .main-sidebar {background-color: #0d1919;} ")) 
                        ),
                        tabItems( 
                          tabItem(tabName = "mallingapp",
                                  verticalLayout(
                                    tabsetPanel(   
                                      tabPanel( "Send Email",value=1, 
                                                mailing_service_UI("mailing_service-module")
                                      ),
                                      tabPanel( "Mailing list",value=2, 
                                                mailing_list_UI("mailing_list-module")
                                      ), 
                                      tabPanel( "Historically sent mails",value=3, 
                                                historical_mails_UI("historical_mails-module")
                                      ),  
                                      id = "conditionedPanels"
                                    ))) 
                        )) 
                      
)) 