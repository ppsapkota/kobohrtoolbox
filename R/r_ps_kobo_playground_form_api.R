
source ("./R/91_r_ps_kobo_library_init.R")
source ("./R/r_ps_kobo_authenticate.R") ###--not uploaded in Githib - instead set Kobo_user and kobo_pw
source ("./R/r_func_ps_kobo_utils.R")

## SET KoBO user name and password
kobo_user<- ""
Kobo_pw<-""

####---------A PLAY GROUND---------------#####
####----DO NOT USE--------------####
####____________MAY NOT BE FINAL____________#####

#upload KoBo form
#curl -X POST -F xls_file=@/path/to/form.xls https://kobo.humanitarianresponse.info/api/v1/forms
#POST(url, body = upload_file("mypath.txt"))
#kobohr_upload_xls_form <-function(url,kobo_xls_form,u,pw){
kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
url <- "https://kc.humanitarianresponse.info/api/v1/forms"
url_kpi <- "https://kobo.humanitarianresponse.info/imports/"

# result<-httr::POST (url,
#             body=list(
#               xls_file=upload_file(path=kobo_form_xlsx, type="xls")),
#             authenticate(kobo_user,Kobo_pw))
#---Uploads form to the KC (legacy interface)
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
  
  #-------------------------------
  kb_url_json <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/form.json")
  kb_url_share <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/share")
  
}
###---------CREATE Projects----WORKING------
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

#------------ASSIGN A FORM TO THE PROJECT---------------------
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

url <- paste0("https://kc.humanitarianresponse.info/api/v1/forms/",form_id,"/clone/")
d <- list(username="punya")
result<-httr::GET (url, 
                   username="punya", 
                   authenticate(kobo_user,Kobo_pw),
                   progress()
)
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)



###################---KPI--------#########################################
####------------------ASSETS IMPORT------------
kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
kb_url <- "https://kobo.humanitarianresponse.info/imports/"
result<-httr::POST (kb_url,
                    body=list(
                      xls_file=upload_file(path=kobo_form_xlsx)),
                    authenticate(kobo_user,Kobo_pw)
)
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)


result<-kobohr_upload_xls_form(url_kpi,kobo_form_xlsx,kobo_user,Kobo_pw)
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

###-------------------------GET ASSETS JSON--------------------------------------####
url <-("https://kobo.humanitarianresponse.info/assets/aVJ3qxffPCPttQ79stbdNL/")
d <- list(owner='https://kobo.humanitarianresponse.info/users/punya/')
result<-httr::GET (url,
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
#kb_user_share <- '{"username": "ochaturkey", "role": "readonly"}'
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


