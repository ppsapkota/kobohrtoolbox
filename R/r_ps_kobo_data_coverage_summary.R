'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 12 July 2017
************************************
#-----Coverage mapping

----'

#--------Merge multiple CSV files---------------------------
source("./R/91_r_ps_kobo_library_init.R")
source("./R/00_1_r_ps_kobo_export_data.R")

d_org_code <- read_excel("./data/500_Afrin_Coverage/Partners coverage consolidated_20180427.xlsx", sheet="partner",col_type="text")
d_org_coverage <- read_excel("./data/500_Afrin_Coverage/Partners coverage consolidated_20180427.xlsx", sheet="map",col_type="text")


xlsx_path<-paste0("./data/01_Download_CSV")
d_merged<- files_merge_xlsx(xlsx_path)


d_merged<-d_merged %>% 
          mutate(`group_metadata/X4`=as.character(`group_metadata/X4`))

#----------create workbook to save results--------
wb<-openxlsx::createWorkbook()
addWorksheet(wb,"summary")
addWorksheet(wb, "check")


#-------bring org name for the code-------------
d_merged <- d_merged %>% 
            left_join(d_org_code, by=c("group_metadata/X4"="org_code"))


openxlsx::write.xlsx(d_merged,paste0("./data/00_Coverage","/afrin_rna_data_merged.xlsx"))

#---number of records assigned to a partner-------
t_nrecord_org_assigned <- d_org_coverage %>% 
  select(admin4Pcode,Partner) %>%
  group_by(Partner) %>% 
  summarise(ncommunity_assigned = n())


#----------count number of submissions by organisations---------
t_nrecord_org<- d_merged %>% 
                group_by(`group_metadata/X4`, org_name) %>%
                summarise (ncommunity = n()) %>% 
                left_join(t_nrecord_org_assigned, by=c("org_name"="Partner")) %>% 
                mutate(community_not_covered = ncommunity_assigned-ncommunity)

#----------Check Duplicate communities---------
t_nrecord_community<- d_merged %>% 
                      group_by(`group_metadata/X6/governorate`,`group_metadata/X6/subdistrict`,`group_metadata/X6/community`) %>%
                      summarise (nCommunity = n()) %>% 
                      filter(nCommunity>1)


####--------check here if there is problem-------------
if(nrow(t_nrecord_community>0)){
  
  t_nrecord_community <- t_nrecord_community %>% 
                         left_join(select(d_merged,`group_metadata/X6/community`,org_name),by=c("group_metadata/X6/community"))
}



#---------coverage validation---------
t_coverage <- d_merged %>% 
              select(`group_metadata/X4`,org_name,`group_metadata/X6/governorate`,`group_metadata/X6/subdistrict`,`group_metadata/X6/community`) %>% 
              full_join(select(d_org_coverage,admin4Pcode,Partner),by=c("group_metadata/X6/community"="admin4Pcode")) 


openxlsx::write.xlsx(t_coverage,paste0("./data/00_Coverage","/afrin_rna_data_coverage.xlsx"),sheetName="rna_coverage")

t_coverage_validation <- t_coverage %>% 
                         filter(org_name != Partner)


#----------------WRITE TO FILE----------
writeData(wb, sheet="summary",x=t_nrecord_org)
i_startrow <- 1
#
writeData(wb, sheet="check", x=t_nrecord_community, startRow = i_startrow)
i_startrow<-i_startrow + nrow(t_nrecord_community)+5
#
writeData(wb, sheet="check", x=t_coverage_validation, startRow = i_startrow)
i_startrow<-i_startrow+nrow(t_coverage_validation)+5

#-----------SAVE FILE---------------
openxlsx::saveWorkbook(wb, paste0("./data/00_Coverage","/afrin_rna_data_coverage_check.xlsx"), overwrite = TRUE)

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
map_com_qcount<- shpfile_adm4 %>% 
                 filter(ADM2_PCODE=="SY0203") %>%   
                 left_join(t_nrecord_community,by=c("PCODE" = "group_metadata/X6/community"))
#View(map_com_qcount)
#plot map
map<-ggplot() +
  geom_polygon(data=shpfile_adm3_df,aes(x=long,y=lat,group=group),color="white",fill="gray")+
  geom_point(data=map_com_qcount,aes(x=LONGITUDE,y=LATITUDE,group=nCommunity,color=nCommunity),size=1) +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.line = element_blank(),
        axis.text = element_blank()
        )
print(map)
#plot(shpfile)
