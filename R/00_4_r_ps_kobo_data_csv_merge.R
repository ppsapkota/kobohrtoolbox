'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
************************************
#-----Merge multiple CSV files


----'

#--------Merge multiple CSV files---------------------------
csv_path<-paste0("./data/data_export_csv")
d_merged<- as.data.frame(multi_files_merge_csv(csv_path))
write_csv(d_merged,paste0(csv_path,"/data_merged.csv"))

