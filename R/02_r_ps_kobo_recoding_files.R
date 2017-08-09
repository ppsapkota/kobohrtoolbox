#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'

#2----------START ENCODING ALL FILES IN FOLDER----------------------------------
  nameodk_recode<-"./xlsform/kobo_master_v7_agg_method.xlsx"
  nameodk<-nameodk_recode
  
  #read ODK file choices and survey sheet
  odk_survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
  dico<-read_excel(nameodk,sheet="choices",col_types ="text")
  key<-row.names(dico)
  dico<-cbind(key,dico)
  dico<-data.frame(dico,stringsAsFactors = FALSE,check.names = FALSE)
  
    # #Some clean up label
    # ind<-which(names(dico)=="label")
    # dico[,ind]<-str_replace_all(dico[,ind],c('\\.'='_','\\*'='','\\:'='','/'='_','\\?'=''))
    # 
      #read data
      # kobo_data_fname<-"./data/data_export_csv/syria_msna_2018_1705_centre_145455_data.csv"
      # data<-read_csv(kobo_data_fname,na="n/a")
      # data<-sapply(data,as.character)
      # data<-tbl_df(data)
      # data_label<-kobo_encode(data,dico)
      
      #recode all the files in the folder
      csv_path<-"./data/data_final/"
      listfiles<-list.files(csv_path,".csv")
      
      for (i in 1:length(listfiles)){
        fname<-listfiles[i]
        data<-read.csv(paste0(csv_path,fname),na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
        #--do not include admin columns in recoding
        #rename fields
        #"Q_M/Q_M1"                                                                             
        #"Q_M/Q_M2"                                                                             
        #"Q_M/Q_M3"                                                                             
        #"Q_M/Q_M4"                                                                             
        #"Q_M/Q_M5"         #
        #data<-rename(data,"admin1pcode"="Q_M/Q_M1","admin2pcode"="Q_M/Q_M2","admin3pcode"="Q_M/Q_M3","admin4pcode"="Q_M/Q_M4","neighpcode"="Q_M/Q_M5")
        admin1pcode <-data[,c("Q_M/Q_M1")]
        admin2pcode <-data[,c("Q_M/Q_M2")]
        admin3pcode <-data[,c("Q_M/Q_M3")]
        admin4pcode <-data[,c("Q_M/Q_M4")]
        neighpcode <-data[,c("Q_M/Q_M5")]
        #
        #
        #
        data<-cbind(
              admin1pcode,
              admin2pcode,
              admin3pcode,
              admin4pcode,
              neighpcode,
              data
              )
        print(paste0("Start Encoding file - ", fname, ' - Start time =', Sys.time()))
        data_label<-kobo_encode(data,dico)
        print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
        write.xlsx2(data_label,gsub("\\.csv", "_recode.xlsx",paste0(csv_path,fname)), row.names = FALSE)
        print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
      } 
#3-----------------MERGE ALL FILES IN THE FOLDER-----------------------------------------------------------------------
      csv_path<-"./data/data_export_csv/"
      merged_files<-multi_files_merge_csv(csv_path)
      write.xlsx2(merged_files,paste0(csv_path,"multisector_assessment_raw_data_all.xlsx"), row.names = FALSE)
      

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
 

