# kobohrtoolbox
This toolbox contains R-script functions developed to manage KoBo forms, download data, aggregate records and visualize results.  

The form upload to KoBo and data download was performed using API available for https://kobo.humanitarianresponse.info/. It supports both older and newer versions of API.

KoBo API related functions defined in the file  
https://github.com/ppsapkota/kobohr_apitoolbox/blob/master/R/r_func_ps_kobo_utils.R  

## Loading KoBo API utilities  
```r
library(devtools)
source_url("https://raw.githubusercontent.com/ppsapkota/kobohr_apitoolbox/master/R/r_func_ps_kobo_utils.R")
```  
After loading the file, all functions will be available for you to use.  

## Download form/project list  
```r
url <-"https://kc.humanitarianresponse.info/api/v1/data.csv"
d_formlist_csv <- kobohr_getforms_csv (url,kobo_user, kobo_pw)
d_formlist_csv <- as.data.frame(d_formlist_csv)
```

**usage:**  
kobo_user <- kobo user account name as string (example "nnkbuser")  
kobo_pw <- password for kobo user account as string (example "nnkbpassword")  

## Download data in CSV format  
```r
url<-https://kc.humanitarianresponse.info/api/v1/data/form_id.csv
d_raw <- kobohr_getdata_csv(url,kobo_user,kobo_pw)  
data <- as.data.frame(d_raw)
```
**usage:**  
form_id <- id of the deployed project (for example 112233)  
For the project or form ID, you can download the list of forms available in your account using __kobohr_getforms_csv__ function.  

## Check submission count for the project  
```r
stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',form_id,'?group=a')    
d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)  
``` 
returns number of records submitted for a project  
**usage:**  
form_id <- id of the deployed project (for example 112233)   
```r
#you can check the number of records submitted before downloading the data
if (d_count_subm>0){
      #Example "https://kc.humanitarianresponse.info/api/v1/data/334455.csv"
      d_raw<-kobohr_getdata_csv(url,kobo_user,Kobo_pw)
      data<-as.data.frame(d_raw)
      #do more here, for example save the data as a xls file.
}
```
## Upload xlsform using new KoBo API (KPI) and deploy as a project  
### STEP 1: import xlsx form  
```r
  kpi_url <- "https://kobo.humanitarianresponse.info/imports/"
  kobo_form_xlsx <- "abc.xlsx"
  d_content<-kobohr_kpi_upload_xlsform(kpi_url,kobo_form_xlsx,kobo_user,Kobo_pw)
  import_url<-d_content$url
```
### STEP2: get the resulting asset UID  
```r
##Multiple attempts may be required until the server indicates "status": "complete" in the response.
d_content<-kobohr_kpi_get_asset_uid(import_url,kobo_user,Kobo_pw)
asset_uid <- d_content$messages$created$uid
```
### STEP3: Deploy an asset  
```r
  d_content<-kobohr_kpi_deploy_asset(asset_uid, kobo_user, Kobo_pw)
```

## Share Asset to other user  
```r
### share and assign multiple permission
permission_list <- c("add_submissions","change_submissions","validate_submissions")
content_object_i <- paste0("/assets/", asset_uid,"/")
user_i <- "externalusername" #kobo user account to share the asset         
for (permission_i in permission_list){
    d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
}
# ASSIGNABLE_PERMISSIONS = (
#   'view_asset',
#   'change_asset',
#   'add_submissions',
#   'view_submissions',
#   'change_submissions',
#   'validate_submissions',
# )
```
---
## Additional utility functions
### Loading KoBo API utilities  
```r
library(devtools)
source_url("https://raw.githubusercontent.com/ppsapkota/kobohrtoolbox/master/R/r_func_ps_utils.R")
```  

### Merge multiple xlsx files in a folder
```r
xlsx_path<-"folder path where xlsx files are saved"
d_merged<- as.data.frame(files_merge_xlsx(xlsx_path))
```
### Convert ALL CSV files in a folder to XLSX
```r
d_path = "path of csv file"
##-----------covert files to csv------------------
filenames=list.files(path=d_path, full.names=TRUE, pattern = "*.csv")
db <- lapply(filenames, function(x){readCSVwriteXLSX(x)})
```
---
## Create KoBo XLSform dictionary  
Add additional fields in 'survey' sheet.  

<table>
<tr><td>additional field name</td><td>description</td><td>Data Value</td></tr>
<tr><td>recodevar</td><td>Recode variable or not</td><td>YES, NO</td></tr>
<tr><td>aggmethod</td><td>Aggregation method</td><td>NA, CONCAT, SUM, RANK3</td></tr>
<tr><td>qrankscore</td><td>Rank order and score for weighting</td><td>1=third rank, 2, 3=first rank</td></tr>
<tr><td>qrankgroup</td><td>Group identifier for the ranking variables</td><td> </td></tr>
<tr><td>sector</td><td>Sector name</td><td> </td></tr>
<tr><td>group</td><td>Group name to identify list of field names in the data which belongs together</td><td> </td></tr>
</table>
Add following additional fields in 'choices' sheet.  
<table>
<tr><td>additional field name</td><td>description</td><td>Data values</td></tr>
<tr><td>vtype</td><td>Variable type</td><td>cat, ord</td></tr>
<tr><td>vscore</td><td>Variable Score for weighting</td><td>numbers and NA</td></tr>
<tr><td>vweight</td><td>Variable weight</td><td>specially for Do not know and No answer - low weight is assigned so that it does not affect the aggregation incase of mixed responses. Weight for 'No answer' is higher than half of 'Do not know'.</td></tr>
<tr><td>rename_label</td><td>new variable name for renaming</td><td></td></tr>
</table>
---

## Create KoBo XLSForm dictionary for recoding and aggregation later in the process  
```r
xlsform_name<-"./xlsform/ochaMSNA2018v9_master.xlsx"
form_file_name <- xlsform_name
#create dictionary from the ODK/XLSFORM design form
kobo_dico(xlsform_name)
#saves file with the same name (suffix added) in the same folder
```
The output XLSForm file with _agg_method is used in subsequent processing.  
## Recoding data
Use __kobo_encode__ finction to recode select_one and select_multiple questions to label. This is down in KoBo data file downloaded as XML values (CSV or XLSX format with "/" separated group header included in the field names).

```r
#use the xlsform file saved after calling function kobo_dico.
nameodk<-"./xlsform/myxlsform_agg_method.xlsx"
#read ODK file choices and survey sheet
dico<-read_excel(nameodk,sheet="choices",col_types ="text")
dico<-data.frame(dico,stringsAsFactors = FALSE,check.names = FALSE)
#recode an excel file and save it in the folder
csv_path<-"./Data/03_Ready_for_recode/"
fname<-"./Data/03_Ready_for_recode/XXXX.xlsx"
save_fname<-gsub("\\.xlsx", "_recode.xlsx",paste0(csv_path,fname))
data=as.data.frame(read_excel(paste0(csv_path,fname),na="NA",col_types ="text"))
print(paste0("Start Encoding file - ", fname, ' - Start time =', Sys.time()))
#Call recode function
#fuction defined in file
# https://github.com/ppsapkota/kobohrtoolbox/blob/master/R/r_func_ps_recode_from_odk.R
data_label<-kobo_encode(data,dico)
#save recoded file
openxlsx::write.xlsx(data_label,save_fname,sheetName="data", row.names = FALSE)
```
