'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
************************************
#-----Merge multiple CSV files


----'

#--------Merge multiple CSV files---------------------------
csv_path<-paste0("./Data/01_Download_CSV")
d_merged<- as.data.frame(files_merge_csv(csv_path))
write_csv(d_merged,paste0(csv_path,"/data_merged.csv"))



