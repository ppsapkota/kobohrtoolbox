#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'

#1---------------------CREATE DICTIONARY---------------------
#####--ONE TIME RUN---------
xlsform_name<-"./xlsform/kobo_master_v7.xlsx"
form_file_name <- xlsform_name
#create dictionary from the ODK/XLSFORM design form
kobo_dico(xlsform_name)

#2----------START ENCODING ALL FILES IN FOLDER----------------------------------
  nameodk_recode<-"./xlsform/kobo_master_v7_agg_method.xlsx"
  nameodk<-nameodk_recode
  
  #read ODK file choices and survey sheet
  odk_survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
  dico<-read_excel(nameodk,sheet="choices",col_types ="text")
  key<-row.names(dico)
  dico<-cbind(key,dico)
  dico<-data.frame(dico,stringsAsFactors = FALSE,check.names = FALSE)
  
    #Some clean up label
    ind<-which(names(dico)=="label")
    dico[,ind]<-str_replace_all(dico[,ind],c('\\.'='_','\\*'='','\\:'='','/'=' ','\\?'=''))
    
      #read data
      # kobo_data_fname<-"./data/data_export_csv/syria_msna_2018_1705_centre_145455_data.csv"
      # data<-read_csv(kobo_data_fname,na="n/a")
      # data<-sapply(data,as.character)
      # data<-tbl_df(data)
      # data_label<-kobo_encode(data,dico)
      
      #recode all the files in the folder
      csv_path<-"./data/data_export_csv/"
      listfiles<-list.files(csv_path,".csv")
      
      for (i in 1:length(listfiles)){
        fname<-listfiles[i]
        data<-read.csv(paste0(csv_path,fname),na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
        # data<-apply(data,2,as.character)
        # data<-data.frame(data,stringsAsFactors = FALSE,check.names = FALSE)
        print(paste0("Start Encoding file - ", fname, ' - Start time =', Sys.time()))
        data_label<-kobo_encode(data,dico)
        print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
        write.xlsx2(data_label,gsub("\\.csv", "_recode.xlsx",paste0(csv_path,fname)), row.names = FALSE)
        print(paste0("Finished Encoding file - ", fname, ' - End time =', Sys.time()))
      } 
#3-----------------MERGE ALL FILES IN THE FOLDER-----------------------------------------------------------------------
      csv_path<-"./data/data_export_csv/"
      merged_files<-multi_files_merge_csv(csv_path)
      write.xlsx2(merged_files,paste0(csv_path,"_hno_kobo_raw_merged.xlsx"), row.names = FALSE)


#4-----------------AGGREGATION STARTS HERE-------------------------------------------------------------

      
      
      
      
      
      
      
#--------------------------------------------------------------------------------------------------------

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
  i=1
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












###-------PLAYGROUND BLOCK-----------
  d_rawi<-kobohr_getdata("https://kc.humanitarianresponse.info/api/v1/data/81471",kobo_user,Kobo_pw)
  #replace "/" in the field header
  names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
  #select few fields that are relevant for coverage mapping
  d_select<-select(d_raw,group_metadata_partnercode,group_metadata_govlist,distrlist,comlist)
  #write.csv(d_rawi,paste0("data/",d_formlist$id[i],".csv"))
  write.csv(d_select,paste0("data/",d_formlist$id[i],".csv"))
  #----------PLAYGROUND BLOCK------------
  
  #curl -X GET 'https://kc.humanitarianresponse.info/api/v1/data/22845?query={"kind": "monthly"}'
  
  #extract only selected data fields
  url<-'https://kc.humanitarianresponse.info/api/v1/data/79489.csv' #works
  d<-kobohr_getdata_csv(url,kobo_user,Kobo_pw)
  
  url<-paste0("https://kc.humanitarianresponse.info/api/v1/data/145533.csv?fields=[" , '"Q_M_Q_M1","Q_M_Q_M3"', "]") # does not work
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content_csv <-read_csv(content(rawdata,"raw",encoding = "UTF-8"))
  
  
  ##--------outputs the list of stats for each form--------
    url<-'https://kc.humanitarianresponse.info/api/v1/stats/submissions/145533?group=a'
    rawdata<-GET(url,authenticate(u,pw),progress())
    d_content <- rawToChar(rawdata$content)
    d_subm_count<- d_content$count
    
      ## get the stats for individual form
      url<-paste0("https://kc.kobotoolbox.org/api/v1/data/145533?fields=[" , '"Q_M_Q_M1","Q_M_Q_M3"', "]") # does not work
      rawdata<-GET(url,authenticate(u,pw),progress())
      d_content <- rawToChar(rawdata$content)
      d_content <- fromJSON(d_content)
      
      #-------
      url= "https://kc.humanitarianresponse.info/api/v1/forms/80978/form.csv"
      rawdata<-GET(url,authenticate(u,pw),progress())
      d_content_csv <-read_csv(content(rawdata,"raw",encoding = "UTF-8"))
      #--export data to CSV - kc.humanitarianresponse.info/api/v1/forms/80978.csv
      #- kc.humanitarianresponse.info/api/v1/forms/80978.xls export XLSX file
      
  ##--------extract XLS file-------------
      url<-'https://kc.humanitarianresponse.info/api/v1/forms.csv'
      rawdata<-GET(url,authenticate(u,pw),progress())
      d_content <- rawToChar(rawdata$content)
      d_content <- fromJSON(d_content)
      
      
      
      

