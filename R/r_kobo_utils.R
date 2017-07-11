#------------HR.info----KoBo data Access-------
'----------------------------------------------
Developed by: Punya Prasad Sapkota
Last Modified: 11 July 2017
-----------------------------------------------'
#supply url
#user names and password to be loaded from external authenticate file - this approach to be checked
kobohr_getforms <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
}

