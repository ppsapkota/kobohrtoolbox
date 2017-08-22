'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
************************************
#-----Merge multiple CSV files


----'
#--------Merge multiple xlsx files---------------------------
xlsx_path<-paste0("./Data/07_Final_ready_to_merge")
d_merged<- as.data.frame(files_merge_xlsx(xlsx_path))
d_merged[is.na(d_merged)] <- 'NA'
openxlsx::write.xlsx(d_merged,paste0(xlsx_path,"/data_merged.xlsx"),sheetName="data",row.names=FALSE)
