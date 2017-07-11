#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'

#load libraries
library(httr)
library(jsonlite)
library(lubridate)


#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#kobo data API
kobohr <- "https://kc.humanitarianresponse.info/api/v1/data"
#kobohr_forms <- "https://kc.kobotoolbox.org/api/v1/formlist"
#Source = Json.Document(Web.Contents("https://kc.humanitarianresponse.info/api/v1/data/80978"))

#call function kobohr_forms from the utils file
# example -
#  kobohr_getforms("https://kc.humanitarianresponse.info/api/v1/data","username","password")
d_forminfo<-kobohr_getforms(kobohr,kobo_user,Kobo_pw)
print(d_forminfo$url)

#loop through each form
for (i in 1:nrow(d_forminfo)){
  print(d_forminfo$url[i])
}






