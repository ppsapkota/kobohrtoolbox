#----export KoBo form list-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 18 July 2018
----'

#load libraries and additional functions from r_ps_kobo_library_init.R
source("./R/91_r_ps_kobo_library_init.R")
#-----------export formlist in CSV format----------------
url_asset <- paste0(kobo_server_url,"assets/")
# d_content<-kobohr_kpi_getassets_csv(url_asset,kobo_user,Kobo_pw)
# d_content<-as.data.frame(d_content)
# d_content$download<-"YES"
# #write_csv(d_formlist_csv,save_fname)
# #export filename as XLSX
# save_fname_xlsx<-paste0("./Data/",kobo_user,"_assets_formlist.xlsx")
# openxlsx::write.xlsx(d_content,save_fname_xlsx,sheetName = "formlist",row.names = FALSE)
# 
# 
