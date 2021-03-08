shinyServer(function(input, output,session) {
  
  
  callModule(mailing_list, "mailing_list-module", pool) 
  callModule(mailing_service, "mailing_service-module", pool)
  callModule(historical_mails, "historical_mails-module", pool)
  
})


