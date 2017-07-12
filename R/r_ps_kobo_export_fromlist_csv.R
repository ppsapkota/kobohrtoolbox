#----export KoBo form list-----------
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

#-----------export formlist in CSV format----------------
csv_link <- "https://kc.humanitarianresponse.info/api/v1/data.csv"
save_fname <- paste0("./data/","formlist_csv.csv")
d_formlist_csv<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
write_csv(d_formlist_csv,save_fname)



