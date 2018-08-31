rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")

#-----------------------------------------------#
rm_fname<-"./xlsform/xls_download_fields_to_remove.xlsx"
rm_list<-as.data.frame(read_excel(rm_fname))
#
db_fname<-"./Data/03_Ready_for_recode/3107_PIN_MSNA-Data cleaning-Aug2018.xlsx"
#db<-as.data.frame(read_excel(db_fname,na='NA'))
db<-as.data.frame(read_excel(db_fname, col_types = "text"))

db<-remove_fields(db,rm_list)
openxlsx::write.xlsx(db,gsub(".xlsx","_fieldremoved.xlsx",db_fname), sheetName="data" ,row.names = FALSE)

