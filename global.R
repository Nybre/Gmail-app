options(shiny.trace = F)  

library(shiny)
library(shinydashboard)  
library(rhandsontable)   
library(pool)  
library(shinyjs)   
library(shinyEffects)
library(shinyBS)
library(dplyr) 
library(googleAuthR)
library(gmailr)
#deprecated
library(googleID)
#read more: https://github.com/MarkEdmondson1234/googleID
library(purrr)
#--------- 

setShadow <- shinyEffects::setShadow 
#scripts
source("modules/mailing_list.R",local=TRUE) 
source("modules/mailing_service.R",local=TRUE) 
source("modules/historical_mails.R",local=TRUE) 


#set source client ID, secret from google cloud console
#activate gmail api, google people api and add credentials (I used Desktop (before was called: other)) 
#if you use web, ensure to have the app port static and added to redirect urls
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.email",
                                        "https://www.googleapis.com/auth/userinfo.profile"))
options("googleAuthR.webapp.client_id" = "640151592731-le6kvdfe3et9jfmf84m84v1mdnmudmoc.apps.googleusercontent.com")
options("googleAuthR.webapp.client_secret" = "g3OGPRFo1l6SLE_3gkhRiMa6")

#gmailR source JSON file from google cloud console
#note this works well with other
gm_auth_configure(key = "640151592731-le6kvdfe3et9jfmf84m84v1mdnmudmoc.apps.googleusercontent.com",secret = "g3OGPRFo1l6SLE_3gkhRiMa6",
                  path= here::here("client_secret_640151592731-le6kvdfe3et9jfmf84m84v1mdnmudmoc.apps.googleusercontent.com.json")) 
gm_auth(email = "g11m1065trader@gmail.com")

#running the app of a specific port (sticky port)
#shiny::runApp("/home/brian/Dropbox/Gmail-app", launch.browser=T, port=1410)
#OR
#options(shiny.port = xxxx)
#options(googleAuthR.redict = "http://localhost:8788)
