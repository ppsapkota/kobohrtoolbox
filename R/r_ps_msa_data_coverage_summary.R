'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
************************************
#-----Merge multiple CSV files


----'

#--------Merge multiple CSV files---------------------------
csv_path<-paste0("./data/data_export_csv_coverage")
d_merged<- multi_files_merge_csv(csv_path)
write_csv(d_merged,paste0(csv_path,"/data_merged.csv"))






#--------check neighbourhood pcode for major cities-------
xlsx_neigh_file<-paste0("./data/neigh_chk_pcode.xlsx")
d_neigh_comlist<-read_excel(xlsx_neigh_file)

d_merged <- left_join(d_merged,d_neigh_comlist,by=c("Q_M_Q_M4"="admin4Pcode"))
#filter list with problematic community names
d_neigh_pcode_missing<-filter(d_merged,admin4Name_en!="")
write.xlsx2(d_neigh_pcode_missing,paste0(csv_path,"/data_merged_missing_neigh_pcode_list.xlsx"))

#----------count number of submissions by organisations---------
d_merged_group<- d_merged %>% 
                 group_by(Q_E_Q_E6)

d_merged_summary<-count(d_merged_group,Q_E_Q_E6)
write_csv(d_merged_summary,paste0(csv_path,"/data_merged_summary.csv"))
#number of questionnaire per community
d_merged_com_q<-d_merged %>% 
                group_by(Q_M_Q_M4)
d_merged_com_qcount<-count(d_merged_com_q,Q_M_Q_M4)
write_csv(d_merged_com_qcount,paste0(csv_path,"/data_merged_qcount.csv"))

#------generate maps------------
shpfile_path <- "./data/shapefile"
admin4_layer <-"Communities"
#POINT LAYER
shpfile_adm4<-tbl_df(readOGR(shpfile_path, "syr_pplp_adm4"))
shpfile_adm4$id<-shpfile_adm4["PCODE"]

#load subdistrict POLYGON layer
shpfile_adm3<-readOGR(shpfile_path, "syr_admin3")
shpfile_adm3_df<-fortify(shpfile_adm3) #required for polygon shapefile

#join map point shapefile with the count of questionnaire data
map_com_qcount<-left_join(shpfile_adm4,d_merged_com_qcount,by=c("PCODE" = "Q_M_Q_M4"))
#View(map_com_qcount)
#plot map
map<-ggplot() +
  geom_polygon(data=shpfile_adm3_df,aes(x=long,y=lat,group=group),color="white",fill="gray")+
  geom_point(data=map_com_qcount,aes(x=LONGITUDE,y=LATITUDE,group=n,color=n),size=1) +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank()
        )
print(map)
#plot(shpfile)
