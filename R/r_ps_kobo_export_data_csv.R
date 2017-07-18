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
library(ggplot2)
library(rgdal)

source("./R/r_kobo_utils.R")
source("./R/r_ps_kobo_authenticate.R")
#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")
#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--EXPORT data to individual csv files
d_formlist_csv <-read_excel("./data/formlist_csv.xlsx",sheet=1)
for (i in 1:nrow(d_formlist_csv)){
  #i=39
  print(d_formlist_csv$url[i])
  #URL format
  #check the submission first
  d_count_subm<-0
  stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',d_formlist_csv$id[i],'?group=a')
  d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)
  #download data only if submission
  if (!is.null(d_count_subm)){
      #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
      d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
      #write to csv
      #save file name
      savefile <- paste0("./data/data_export_csv/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
      write_csv(d_rawi,savefile)
  }
}

#***-----RUN THIS BLOCK------
#--EXPORT selected fields----------
#------This is used for coverage mapping purpose only-------

for (i in 1:nrow(d_formlist_csv)){
  #i=10
  print(d_formlist_csv$url[i])
  #URL format
  #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
  
  #count submission first
  d_count_subm<-0
  stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',d_formlist_csv$id[i],'?group=a')
  d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)
  # download data only if submission is greater than 0
  if (!is.null(d_count_subm)){
    d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
    names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
    #write to csv
    #d_select<-select(d_rawi,c("Q_E_Q_E6","Q_M_Q_M1","Q_M_Q_M2","Q_M_Q_M3","Q_M_Q_M4","Q_M_Q_M5"))
    d_select<- d_rawi[,c("Q_E_Q_E6","Q_M_Q_M1","Q_M_Q_M2","Q_M_Q_M3","Q_M_Q_M4","Q_M_Q_M5")]
    #savefile
    savefile <- paste0("./data/data_export_csv_coverage/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
    write_csv(d_select,savefile)
  }
}

#--------Merge multiple CSV files---------------------------
csv_path<-paste0("./data/data_export_csv_coverage")
d_merged<- multi_files_merge_csv(csv_path)
write_csv(d_merged,paste0(csv_path,"/data_merged.csv"))
#----------count number of submissions by organisations---------
d_merged_group<- d_merged %>% 
                 group_by(Q_E_Q_E6)

d_merged_summary<-count(d_merged_group,Q_E_Q_E6)
write_csv(d_merged_summary,paste0(csv_path,"/data_merged_summary.csv"))
#number of questionnaire per community
d_merged_com_q<-d_merged %>% 
                group_by(Q_M_Q_M4)
d_merged_com_qcount<-count(d_merged_com_q,Q_M_Q_M4)
write_csv(d_merged_com_qcount,paste0(csv_path,"/data_merged_qcount.csv"))

#------generate maps------------
shpfile_path <- "./data/shapefile"
admin4_layer <-"Communities"

shpfile_adm4<-tbl_df(readOGR(shpfile_path, "syr_pplp_adm4"))
shpfile_adm4$id<-shpfile_adm4["PCODE"]
#shpfile_df<-fortify(shpfile_adm4,region="PCODE") #required for polygon shapefile

#join map point shapefile with the count of questionnaire data
map_com_qcount<-left_join(shpfile_adm4,d_merged_com_qcount,by=c("PCODE" = "Q_M_Q_M4"))
View(map_com_qcount)
#plot map
map<-ggplot() +
  geom_point(data=map_com_qcount,aes(x=LONGITUDE,y=LATITUDE,color=n),size=2)
print(map)
#plot(shpfile)

#***-----RUN ABOVE BLOCK------




