#----Exporting data to external CSV file-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
----'
#load libraries
library(httr)
library(jsonlite)
library(lubridate)
library(tidyverse)
library(stringr)
library(readxl) #read excel file
library(dplyr)
#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")
#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--export data to individual csv files
d_formlist_csv <-read_excel("./data/formlist_csv.xlsx",sheet=1)
for (i in 1:nrow(d_formlist_csv)){
  #i=5
  print(d_formlist_csv$url[i])
  #URL format
  #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
  d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
  #check if data is empty or not
  #write to csv
  write_csv(d_rawi,paste0("./data/",d_formlist_csv$id[i],"_data.csv"))
}

#--------Export selected fields----------
# developed for coverage mapping purpose only
for (i in 1:nrow(d_formlist_csv)){
  #i=5
  print(d_formlist_csv$url[i])
  #URL format
  #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
  d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
  #check if data is empty or not
  if (length(d_rawi)>1){
    #replace "/" in the field header
    names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
    
  } else {
    #create empty record
    empty_header <- c("group_metadata_partnercode",	"group_metadata_govlist",	"distrlist",	"comlist")
    d_rawi<-data.frame(matrix(ncol=4,nrow=0))
    colnames(d_rawi) <- empty_header
  }
  #write to csv
  d_select<-select(d_rawi,c("group_metadata_partnercode","group_metadata_govlist","distrlist","comlist"))
  write_csv(d_select,paste0("./data/",d_formlist_csv$id[i],"_data_sel.csv"))
}

#--------Merge multiple CSV files---------------------------
csv_path<-paste0("./data/coverage")
d_merged<- multi_files_merge_csv(csv_path)
write_csv(d_merged,paste0(csv_path,"/data_merged.csv"))
#----------count number of submissions by organisations---------
d_merged_group<- tbl_df(d_merged) %>% 
                    group_by("group_metadata_partnercode")

d_merged_summary<-count(d_merged_group,"group_metadata_partnercode")
write_csv(d_merged_summary,paste0(csv_path,"/data_merged_summary.csv"))
