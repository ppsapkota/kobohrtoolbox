'----
***********************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
***********************************
#---USAGE
#-----Exporting data to external CSV file
#-----Exports data from the multiple forms in the account


----'




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
      d_rawi<-NULL
      #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
      d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
      #write to csv
      #save file name
      savefile <- paste0("./data/data_export_csv/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
      write_csv(d_rawi,savefile)
  }
}




