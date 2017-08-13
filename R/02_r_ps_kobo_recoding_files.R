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
      csv_path<-"./Data/04_Ready_for_recode/"
      #listfiles<-list.files(csv_path,".csv") #change here
      listfiles<-list.files(csv_path,".xlsx")
      
      for (i in 1:length(listfiles)){
        fname<-listfiles[i]
        save_fname<-gsub("\\.xlsx", "_recode.xlsx",paste0(csv_path,fname))
        #save_fname<-gsub("\\.csv", "_recode.xlsx",paste0(csv_path,fname)) #change here
        
        #data<-read.csv(paste0(csv_path,fname),na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE) #change here
        #optional for XLSX reading
        data=as.data.frame(read_excel(paste0(csv_path,fname),na="n/a",col_types ="text"))
        
        #--do not include admin columns in recoding
        #data<-rename(data,"admin1pcode"="Q_M/Q_M1","admin2pcode"="Q_M/Q_M2","admin3pcode"="Q_M/Q_M3","admin4pcode"="Q_M/Q_M4","neighpcode"="Q_M/Q_M5")
        admin1pcode <-data[,c("Q_M/Q_M1")]
        admin2pcode <-data[,c("Q_M/Q_M2")]
        admin3pcode <-data[,c("Q_M/Q_M3")]
        admin4pcode <-data[,c("Q_M/Q_M4")]
        neighpcode <-data[,c("Q_M/Q_M5")]
        
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
        #print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
        
        write.xlsx2(data_label,save_fname, row.names = FALSE)
        
        
        #print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
      } 
      
     
      
      
      
      
      
      
      
      
      
      
      
      
 

