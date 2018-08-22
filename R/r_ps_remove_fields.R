rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")

#-----------------------------------------------#
rm_fname<-"./xlsform/xls_download_fields_to_remove.xlsx"
rm_list<-as.data.frame(read_excel(rm_fname))
#
db_fname<-"./Data/data_export_csv/syria_msna_2018_1728_NE_145512.xlsx"
#db<-as.data.frame(read_excel(db_fname,na='NA'))
db<-as.data.frame(read_excel(db_fname))

db<-remove_fields(db,rm_list)
openxlsx::write.xlsx(db,gsub(".xlsx","_fieldremoved.xlsx",db_fname),row.names = FALSE)

