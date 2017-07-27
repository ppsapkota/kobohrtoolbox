'----
**********************************
Developed by: Punya Prasad Sapkota
Last modified: 18 July 2017
**********************************
#----Exporting data to external CSV file
----'
#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--EXPORT data to individual csv files
d_formlist_csv <-read_excel("./data/syriaregional3_formlist.xlsx",sheet=1)
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

