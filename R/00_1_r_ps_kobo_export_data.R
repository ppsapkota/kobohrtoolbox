'----
***********************************
Developed by: Punya Prasad Sapkota
Last modified: 15 July 2018
***********************************
#---USAGE
#-----Exporting CSV data to external XLSX file
#-----Exports data from the multiple forms in the account
----'
#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--EXPORT data to individual csv files
#d_formlist_csv <-read_excel("./Data/ochaturkey1_formlist.xlsx",sheet=1) #TUR
#d_formlist_csv <-read_excel("./Data/syriaregional1_formlist.xlsx",sheet=1) #JOR
#d_formlist_csv <-read_excel("./Data/syriaregional2_formlist.xlsx",sheet=1) #DAM
d_formlist <-read_excel("./Data/syriaregional3_formlist.xlsx",sheet=1) #TurkeyXB MSNA2018

####---download only marked as download=YES
d_formlist<-filter(d_formlist,str_to_lower(download)=="yes")

for (i in 1:nrow(d_formlist)){
  #i=39
  print(d_formlist$url[i])
  #URL format
  #check the submission first
  d_count_subm<-0
  stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',d_formlist$id[i],'?group=a')
  d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)
  #download data only if submission
  if (!is.null(d_count_subm)){
      d_rawi<-NULL
      #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
      d_rawi<-kobohr_getdata_csv(d_formlist$url[i],kobo_user,Kobo_pw)
      d_rawi<-as.data.frame(d_rawi)
      d_rawi<-lapply(d_rawi,as.character)
      d_rawi<-as.data.frame(d_rawi,stringsAsFactors=FALSE,check.names=FALSE)
      
      #Recode 'n/a' to 'NA'
       for (kl in 1:ncol(d_rawi)){
         d_rawi[,kl]<-ifelse(d_rawi[,kl]=="n/a",NA,d_rawi[,kl])
       }
      #write to csv
      #save file name
      #savefile <- paste0("./Data/01_Download_CSV/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
      #write_csv(d_rawi,savefile)
      #save as xlsx
      d_rawi[is.na(d_rawi)] <- 'NA'
      #make filename that can be recognised - remove arabic texts
      title<-d_formlist$title[i]
      title<-str_replace_all(title," ","_")
      title<-iconv(title,"UTF-8","ASCII",sub="")
      title<-str_replace_all(title,"__","")
      #
      savefile_xlsx <- paste0("./Data/01_Download_CSV/",title,"_",d_formlist$id_string[i],"_", d_formlist$id[i],"_data.xlsx")
      #write.xlsx2(as.data.frame(d_rawi),savefile_xlsx,sheetName = "data",row.names = FALSE)
      openxlsx::write.xlsx(d_rawi,savefile_xlsx,sheetName="data",row.names=FALSE)
  }
}




