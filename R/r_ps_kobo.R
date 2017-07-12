#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'

#load libraries
library(httr)
library(jsonlite)
library(lubridate)
library(tidyverse)
library(stringr)
library(readxl) #read excel file
#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")
Sys.setlocale("LC_CTYPE","arabic")

#kobo data API
kobohr <- "https://kc.humanitarianresponse.info/api/v1/data"
#kobohr_forms <- "https://kc.kobotoolbox.org/api/v1/formlist"
#Source = Json.Document(Web.Contents("https://kc.humanitarianresponse.info/api/v1/data/80978"))

##call function kobohr_forms from the utils file
# example -
#  kobohr_getforms("https://kc.humanitarianresponse.info/api/v1/data","username","password")
d_formlist<-kobohr_getforms(kobohr,kobo_user,Kobo_pw)
print(d_formlist$url)
write_csv(d_formlist,"./data/formlist.csv")


#fetch data from specific formid
#https://kc.humanitarianresponse.info/api/v1/data/82062
#example to fetch raw data from one form
#link from powerbi - https://kc.humanitarianresponse.info/api/v1/data/80978
formid_link <- "https://kc.humanitarianresponse.info/api/v1/data/82062"
d_raw<-kobohr_getdata(formid_link,kobo_user,Kobo_pw)
#checking the output
#write_csv(d_raw,paste0("data/","82062.csv"),fileEncoding = "UTF-8")

##loop through each form and fetch data
#read list of forms
d_formlist <-read_excel("./data/formlist.xlsx",sheet=1)
for (i in 1:nrow(d_formlist)){
  #i=4
  print(d_formlist$url[i])
  d_rawi<-kobohr_getdata(d_formlist$url[i],kobo_user,Kobo_pw)
  #check if data is empty or not
  if (length(d_rawi)!=0){
    #replace "/" in the field header
    names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
    #select few fields that are relevant for coverage mapping
    #write.csv(d_rawi,paste0("./data/",d_formlist$id[i],".csv"))
  } else {
    #create empty record
    empty_header <- c("group_metadata_partnercode",	"group_metadata_govlist",	"distrlist",	"comlist")
    d_rawi<-data.frame(matrix(ncol=4,nrow=0))
    colnames(d_rawi) <- empty_header
  }
  #write to csv
  d_select<-select(d_rawi,"group_metadata_partnercode","group_metadata_govlist","distrlist","comlist")
  write_csv(d_select,paste0("./data/",d_formlist$id[i],".csv"))
}

#the function to be extended with NULL list check
#d_data_fetch<-sapply(d_formlist$url,function(x){kobohr_getdata(x,kobo_user,Kobo_pw)})
#d_data_all<-Reduce(rbind.fill,d_data_fetch)

#-----------formlist in CSV format----------------
csv_link <- "https://kc.humanitarianresponse.info/api/v1/data.csv"
d_formlist_csv<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
write_csv(d_formlist_csv,paste0("./data/","formlist_csv.csv"))








#-------PLAYGROUND BLOCK-----------
d_rawi<-kobohr_getdata("https://kc.humanitarianresponse.info/api/v1/data/81471",kobo_user,Kobo_pw)
#replace "/" in the field header
names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
#select few fields that are relevant for coverage mapping
d_select<-select(d_raw,group_metadata_partnercode,group_metadata_govlist,distrlist,comlist)
#write.csv(d_rawi,paste0("data/",d_formlist$id[i],".csv"))
write.csv(d_select,paste0("data/",d_formlist$id[i],".csv"))
#----------PLAYGROUND BLOCK------------

#curl -X GET 'https://kc.humanitarianresponse.info/api/v1/data/22845?query={"kind": "monthly"}'



