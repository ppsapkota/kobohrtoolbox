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
  
    #Some clean up label
    #ind<-which(names(dico)=="label")
    #dico[,ind]<-str_replace_all(dico[,ind],c('\\.'='_','\\*'='','\\:'='','/'=' ','\\?'=''))
    
      #read data
      # kobo_data_fname<-"./data/data_export_csv/syria_msna_2018_1705_centre_145455_data.csv"
      # data<-read_csv(kobo_data_fname,na="n/a")
      # data<-sapply(data,as.character)
      # data<-tbl_df(data)
      # data_label<-kobo_encode(data,dico)
      
      #recode all the files in the folder
      csv_path<-"./Data/01_Download_CSV/"
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
      write_csv(merged_files,paste0(csv_path,"multisector_assessment_raw_data_all.csv"))
      

      
      
      
      
      # Load workbook (create if not existing)
      wb <- loadWorkbook(demoExcelFile, create = TRUE)
      
      # Create a worksheet called 'Dummy'
      createSheet(wb, name = "Dummy")
      
      # Write large data.frame to worksheet 'Dummy' created above
      writeWorksheet(wb, dfLarge, sheet = "Dummy")
      
      # Save workbook (this actually writes the file to disk)
      saveWorkbook(wb)
      
      
      
      
      
      
      
      
      
      
      
      
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
  d_rawi<-kobohr_getdata("https://kc.humanitarianresponse.info/api/v1/data/145468",kobo_user,Kobo_pw)
  #replace "/" in the field header
  names(d_rawi)<-str_replace_all(names(d_rawi),"/","_")
  #select few fields that are relevant for coverage mapping
  d_select<-select(d_raw,group_metadata_partnercode,group_metadata_govlist,distrlist,comlist)
  #write.csv(d_rawi,paste0("data/",d_formlist$id[i],".csv"))
  write.csv(d_select,paste0("data/",d_formlist$id[i],".csv"))
  #----------PLAYGROUND BLOCK------------
  
  #curl -X GET 'https://kc.humanitarianresponse.info/api/v1/data/22845?query={"kind": "monthly"}'
  
  #extract only selected data fields
  url<-'https://kc.humanitarianresponse.info/api/v1/data/145468.csv' #works
  d_rawi<-kobohr_getdata_csv(url,kobo_user,Kobo_pw)
  
  
  
  
  url<-paste0("https://kc.humanitarianresponse.info/api/v1/data/145533.csv?fields=[" , '"Q_M_Q_M1","Q_M_Q_M3"', "]") # does not work
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content_csv <-read_csv(content(rawdata,"raw",encoding = "UTF-8"))
  
  #try XLSX download
  url<-"https://kc.humanitarianresponse.info/api/v1/data/145533.xlsx" # does not work
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content_csv <-read_excel(content(rawdata,"raw",encoding = "UTF-8"))
  write.xlsx2(rawdata,"a.xlsx")
  
  
  
  
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
      
      
      
#write big xlsx
      csv_path<-"./data/data_final/"
      fname<-"multisector_assessment_raw_data_all_recode_AGG_Step06_FINAL.csv"
      a_db<-read.csv(paste0(csv_path,fname),na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      
      save_fname<-paste0(csv_path,gsub(".csv",".xlsx",fname))
      
      write_big.xlsx2(a_db,save_fname,"data")
      Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")
      openxlsx::write.xlsx(a_db,save_fname,"dat")
      



#upload KoBo form
#curl -X POST -F xls_file=@/path/to/form.xls https://kobo.humanitarianresponse.info/api/v1/forms
#POST(url, body = upload_file("mypath.txt"))
#kobohr_upload_xls_form <-function(url,kobo_xls_form,u,pw){
kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
url <- "https://kc.humanitarianresponse.info/api/v1/forms"
#url <- "https://kobo.humanitarianresponse.info/imports/"

# result<-httr::POST (url,
#             body=list(
#               xls_file=upload_file(path=kobo_form_xlsx, type="xls")),
#             authenticate(kobo_user,Kobo_pw))

result<-kobohr_upload_xls_form(url,kobo_form_xlsx,kobo_user,Kobo_pw)

status_code <- result$status_code
##----------------------
if (status_code==201){
  d_content <- rawToChar(result$content)
  d_content <- fromJSON(d_content)
  #---------------------#
  form_url <- d_content$url
  form_id <- d_content$formid
  form_uuid <- d_content$uuid
  #-----------------------#
  kb_url_import <- "https://kobo.humanitarianresponse.info/imports/"
  kb_url_import <- paste0(kb_url_import,form_uuid,"/")
  #-----------------------
  kb_url_asset <- "https://kobo.humanitarianresponse.info/assets/"
  kb_url_asset <- paste0(kb_url_asset,form_uuid,"/")
  
  #---------------
  kb_url_json <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/form.json")
  kb_url_share <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/share")
  
}
###---------CREATE Projects----------
prj_owner <- list(name="project punya", owner="https://kc.humanitarianresponse.info/api/v1/users/punya")
prj_url <-"https://kc.humanitarianresponse.info/api/v1/projects"

result<-httr::POST (prj_url,
                    body=prj_owner,
                    authenticate(kobo_user,Kobo_pw))

d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)

#-------------GET LIST OF the PROJECT----------
url<-"https://kc.humanitarianresponse.info/api/v1/projects"
result<-GET(url,authenticate(kobo_user,Kobo_pw),progress())
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)

#------------ASSIGN A FORM TO PROJECT---------------------
#curl -X POST -d '{"formid": 28058}' https://kc.kobotoolbox.org/api/v1/projects/1/forms -H "Content-Type: application/json"
prj_id <-d_content$projectid[2]
prj_url <- paste0("https://kc.humanitarianresponse.info/api/v1/projects/",prj_id,"/forms")
form_id<-list(formid=225299)
result<-httr::POST (prj_url,
                    body=form_id,
                    authenticate(kobo_user,Kobo_pw))

d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)



###----------CLONE A PROJECT---------------
#curl -X GET https://kobo.humanitarianresponse.info/api/v1/forms/123/clone -d username=alice
#https://kc.humanitarianresponse.info/api/v1/data/21697.csv
form_id <- 225299

url <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/clone")
d <- list(user="https://kobo.humanitarianresponse.info/users/punya/")
result<-httr::GET (url, 
                   body=d, 
                   authenticate(kobo_user,Kobo_pw),
                   progress()
                   )
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)

####------------------ASSETS IMPORT------------
kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
kb_url_import <- "https://kobo.humanitarianresponse.info/imports/"
d <- list(filename=upload_file(path=kobo_form_xlsx, type="xls"))
result<-httr::POST (kb_url_import,
                    d,
                    authenticate(kobo_user,Kobo_pw)
                    )
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)




###-----------ASSETS DEPLOYMENT WORKING-----------
url <-paste0("https://kobo.humanitarianresponse.info/assets/aVJ3qxffPCPttQ79stbdNL/","deployment/")
d <- list(owner='https://kobo.humanitarianresponse.info/users/punya/')
result<-httr::POST (url,
                    body=d,
                    authenticate(kobo_user,Kobo_pw))

d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)









###------------Upload a XLS form to a project
#curl -X POST -F xls_file=@/path/to/form.xls https://kc.kobotoolbox.org/api/v1/projects/1/forms


#"https://kc.humanitarianresponse.info/api/v1/forms/225265"
####Get form assests
#GET https://kobo.humanitarianresponse.info/api/v1/forms/28058/form.json
#https://kc.humanitarianresponse.info/api/v1/forms/225265/form.json
rawdata<-GET(kb_url_json,authenticate(kobo_user,Kobo_pw),progress())
d_form_json <- rawToChar(rawdata$content)
#  curl -X POST -d '{"id": "[form ID]", "submission": [the JSON]} http://localhost:8000/api/v1/submissions -u user:pass -H "Content-Type: application/json"
kb_json_data <-list(id=form_id,submission=d_form_json)
kb_url_submission <- "https://kc.humanitarianresponse.info/api/v1/submissions"
result<-httr::POST (kb_url_submission,
                    body=kb_json_data,
                    authenticate(kobo_user,Kobo_pw),content_type_json())


##---------SHARE FORM--WORKING-------------------------##
#POST -d '{"username": "ochaturkey", "role": "readonly"}' https://kobo.humanitarianresponse.info/api/v1/forms/123.json
kb_user_share <- '{"username": "ochaturkey", "role": "readonly"}'
kb_user_share <-list(username="ochaturkey",role="editor")

result<-httr::POST (kb_url_share,
                    body=kb_user_share,
                    authenticate(kobo_user,Kobo_pw))

r1 <- rawToChar(result$content)
r2 <- fromJSON(r1)
#d_content <- fromJSON(d_form_json)

###---------------------------------###

result<-httr::POST (kb_url_import,
            body=list(
              xls_file=upload_file(path=kobo_form_xlsx, type="xls")),
            authenticate(kobo_user,Kobo_pw))



# POST(url="https://xxx.YYYY/upload",
#      body = list(file=upload_file(
#        path =  outfilename,
#        type = 'text/txt')
#      ),
#      verbose(),
#      add_headers(Authorization=paste0("Bearer XXXX-XXXX-XXXX-XXXX"))
# )

# https://kc.humanitarianresponse.info/punya/api-token
# 1c29aab330b5feb0448d2733cd762669e15f164a
      
#---DELETE FROM
#curl -X DELETE https://kobo.humanitarianresponse.info/api/v1/forms/28058
url<-"https://kc.humanitarianresponse.info/api/v1/forms/225262"
result<-httr::DELETE (form_url,authenticate(kobo_user,Kobo_pw))



#--UPLOAD DATA-----
#-post form data
#curl -X POST https://kobo.humanitarianresponse.info/api/v1/forms/123/csv_import -F csv_file=@/path/to/csv_import.csv
url <- "https://kc.humanitarianresponse.info/api/v1/forms/196534/csv_import"
file_path<-"./Data/01_Download_CSV/"
data_file_csv <- paste0(file_path,"syria_msna_2018_1702_NW.csv")
#url<-"https://kc.humanitarianresponse.info/api/v1/forms/196520.csv"
httr::POST (url,
                    body=list(
                      csv_file=upload_file(path=data_file_csv)),
                    authenticate(kobo_user,Kobo_pw), verbose())    
 

#curl -X POST -d '{"id": "[form ID]", "submission": [the JSON]} http://localhost:8000/api/v1/submissions -u user:pass -H "Content-Type: application/json"

d<-list(id=form_id,submission=)

#curl -X POST -F xls_file=@/path/to/form.xls https://kobo.humanitarianresponse.info/api/v1/projects/1/forms

url<-"https://kc.humanitarianresponse.info/api/v1/projects?owner=syriaregional3"
rawdata<-GET(url,authenticate(kobo_user,Kobo_pw),progress())
d_content <- rawToChar(rawdata$content)
d_content <- fromJSON(d_content)

#Enketo edit instance
#curl -X GET https://kobo.humanitarianresponse.info/api/v1/data/28058/20/enketo?return_url=url

url<-"https://kc.humanitarianresponse.info/api/v1/data/154150/11574689/enketo?return_url=www.google.com"
rawdata<-GET(url,authenticate(kobo_user,Kobo_pw),progress())
d_content <- rawToChar(rawdata$content)
d_content <- fromJSON(d_content)

##----------EDIT LINK----------------------------##
#https://kc.humanitarianresponse.info/syriaregional3/forms/syria_msna_2018_1702_NW_New/edit-data/11574689

d_formid<-"154150"
d_formname<-"syria_msna_2018_1702_NW_New"
d_url<-"https://kc.humanitarianresponse.info/syriaregional3/forms"

url<-paste0("https://kc.humanitarianresponse.info/api/v1/data/",d_formid)
rawdata<-GET(url,authenticate(kobo_user,Kobo_pw),progress())
d_content <- rawToChar(rawdata$content)
d_content <- fromJSON(d_content)
d_id<-d_content[,c("_id","_uuid")]
d_id$edit_url<-paste0(d_url,"/",d_formname,"/edit-data","/",d_id$`_id`)
openxlsx::write.xlsx(x=d_id, file=paste0("./Data/01_Download_CSV/",d_formname,"_",d_formid,"_edit_data",".xlsx"))




      
