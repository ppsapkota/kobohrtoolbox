
source("./R/91_r_ps_kobo_library_init.R")

d_path = "./data/200_Displacement_Tracking"
f_file = "Displacement_Reporting_2018-04-09-09-01-30.xlsx"
s_file = gsub(".xlsx","_for_analysis.xlsx",f_file)
d_filename = paste0(d_path,"/",f_file) 
s_filename = paste0(d_path,"/",s_file)

###------SET FILTER DATE---------
### All data entered after this date (inclusive)
###  will be retained.
start_date_filter <- as.Date("2018-03-01","%Y-%m-%d")
#
pcode_fname<-"./data/200_Displacement_Tracking/admin/syr_admin_180131.xlsx"
#--Read PCODE file--
admin_pcode<-read_excel(pcode_fname,sheet="admin4")
##-----------read sheets------------------
d_main <- read_excel(d_filename,sheet="Displacement Reporting")
d_new_idp_B1<-read_excel(d_filename,sheet="B1")
d_returnees_B2<-read_excel(d_filename,sheet="B2")
d_departure_B3<-read_excel(d_filename,sheet="B3")

###-------Convert today field to DATE---
d_main$today <-as.Date(d_main$today, "%Y-%m-%d")
###-------filter data from the main sheet---
d_main <- d_main %>% 
  mutate_at(.funs=funs(as.Date(.,format="%Y-%m-%d")),.vars=vars(today)) %>%
  rename("t_today"="today") %>% 
  filter(as.Date(t_today, "%Y-%m-%d") >= as.Date(start_date_filter, "%Y-%m-%d")) %>% 
  rename("today"="t_today")

#---------Admin names--------------
#join with the admin names
admin1<-distinct(admin_pcode[,c("admin1Pcode","admin1Name_en")])
admin2<-distinct(admin_pcode[,c("admin2Pcode","admin2Name_en")])
admin3<-distinct(admin_pcode[,c("admin3Pcode","admin3Name_en")])
admin4<-distinct(admin_pcode[,c("admin4Pcode","admin4Name_en")])
#Join with the location table one by one
d_main<-left_join(d_main,admin1,by=c("location/adm1"="admin1Pcode"))
d_main<-left_join(d_main,admin2,by=c("location/adm2"="admin2Pcode"))
d_main<-left_join(d_main,admin3,by=c("location/adm3"="admin3Pcode"))
d_main<-left_join(d_main,admin4,by=c("location/adm4"="admin4Pcode"))

#----PREPARE TABLES with ADMIN NAMES----------------------------
d_new_idp_B1<-left_join(d_new_idp_B1,admin1,by=c("new_idp/B1/B1_11"="admin1Pcode"))
d_new_idp_B1<-left_join(d_new_idp_B1,admin2,by=c("new_idp/B1/B1_12"="admin2Pcode"))
d_new_idp_B1<-left_join(d_new_idp_B1,admin3,by=c("new_idp/B1/B1_13"="admin3Pcode"))
d_new_idp_B1<-left_join(d_new_idp_B1,admin4,by=c("new_idp/B1/B1_14"="admin4Pcode"))

d_new_idp_B1<-rename(d_new_idp_B1,"admin1Name_from"="admin1Name_en",
                                  "admin2Name_from"="admin2Name_en",
                                  "admin3Name_from"="admin3Name_en",
                                  "admin4Name_from"="admin4Name_en")

#
d_returnees_B2<-left_join(d_returnees_B2,admin1,by=c("returnees/B2/B2_11"="admin1Pcode"))
d_returnees_B2<-left_join(d_returnees_B2,admin2,by=c("returnees/B2/B2_12"="admin2Pcode"))
d_returnees_B2<-left_join(d_returnees_B2,admin3,by=c("returnees/B2/B2_13"="admin3Pcode"))
d_returnees_B2<-left_join(d_returnees_B2,admin4,by=c("returnees/B2/B2_14"="admin4Pcode"))

d_returnees_B2<-rename(d_returnees_B2,"admin1Name_returned_from"="admin1Name_en",
                       "admin2Name_returned_from"="admin2Name_en",
                       "admin3Name_returned_from"="admin3Name_en",
                       "admin4Name_returned_from"="admin4Name_en")

#
d_departure_B3<-left_join(d_departure_B3,admin1,by=c("departure/B3/B3_11"="admin1Pcode"))
d_departure_B3<-left_join(d_departure_B3,admin2,by=c("departure/B3/B3_12"="admin2Pcode"))
d_departure_B3<-left_join(d_departure_B3,admin3,by=c("departure/B3/B3_13"="admin3Pcode"))
d_departure_B3<-left_join(d_departure_B3,admin4,by=c("departure/B3/B3_14"="admin4Pcode"))

d_departure_B3<-rename(d_departure_B3,"admin1Name_departed_to"="admin1Name_en",
                     "admin2Name_departed_to"="admin2Name_en",
                     "admin3Name_departed_to"="admin3Name_en",
                     "admin4Name_departed_to"="admin4Name_en")

##--GET field index for rearranging--------
d_main_i <- d_main %>% 
            select(1:13,admin1Name_en:admin4Name_en,`rep_period/A2`:`rep_period/A2_2`, "_index")
#d_main_i<-d_main[,c(1:13,admin1Name_en_ind:admin4Name_en_ind,14:22,67)]
#
d_main_i<-rename(d_main_i,"_parent_index"="_index")

#new IDP
d_new_idp_B1<-d_main_i %>% 
              left_join(d_new_idp_B1,by=c("_parent_index"="_parent_index")) %>% 
              drop_na_("_index")
##returnees
d_returnees_B2 <- d_main_i %>% 
                  left_join(d_returnees_B2,by=c("_parent_index"="_parent_index")) %>% 
                  drop_na_("_index")
##departures
d_departure_B3<-d_main_i %>% 
                left_join(d_departure_B3,by=c("_parent_index"="_parent_index")) %>% 
                drop_na_("_index")

#---------------QUALITY CHECK----------------
#CHECK 1 - If a community has both monthly data and data reported over a priod
df_data_period<-data.frame(rep_period_code=c(1,2),rep_period_label=c("monthly", "specified_period"))
chk_d_new_idp_B1<-d_new_idp_B1
chk_d_new_idp_B1 <- chk_d_new_idp_B1 %>% 
                    mutate_at(.funs=funs(as.integer),.vars=vars(`rep_period/A2`)) %>% 
                    left_join(df_data_period, by= c("rep_period/A2"="rep_period_code"))


d_chk_data_period <- chk_d_new_idp_B1 %>%
                     unite("unite",rep_period_label,`rep_period/A2_2`) %>% 
                     group_by(`location/adm4` ,unite, `rep_period/A2`,`new_idp/B1/B1_11`,`new_idp/B1/B1_12`,`new_idp/B1/B1_13`,`new_idp/B1/B1_14`) %>%
                     summarise(nDuplicate = n()) %>% 
                     spread (unite,nDuplicate)
ncol_e <-ncol(d_chk_data_period)
d_chk_data_period$chk_record_if_more_than_1 <- rowSums(d_chk_data_period[7:ncol_e], na.rm=TRUE)
View(d_chk_data_period)

#CHECK 2 - If a community has more than one record for the same community of origin
d_chk_data_dupRecords <- chk_d_new_idp_B1 %>%
                     group_by(`location/adm4` ,`rep_period/A2_2`, `new_idp/B1/B1_11`,`new_idp/B1/B1_12`,`new_idp/B1/B1_13`,`new_idp/B1/B1_14`) %>%
                     summarise(nDuplicate = n()) %>% 
                     spread(`rep_period/A2_2`,nDuplicate)
ncol_e <-ncol(d_chk_data_dupRecords)
d_chk_data_dupRecords$chk_record_if_more_than_1 <- rowSums(d_chk_data_dupRecords[6:ncol_e], na.rm=TRUE)

View(d_chk_data_dupRecords)

#CHECK 3 - If more than one enumerator entered data or not for the same community
d_chk_data_dupEnum <- chk_d_new_idp_B1 %>%
                      group_by(`location/adm4`,`metadata/X2`,`new_idp/B1/B1_11`,`new_idp/B1/B1_12`,`new_idp/B1/B1_13`,`new_idp/B1/B1_14`) %>%
                      summarise(nDuplicate = n()) %>% 
                      spread(`metadata/X2`,nDuplicate)
ncol_e <-ncol(d_chk_data_dupEnum)
d_chk_data_dupEnum$chk_record_if_more_than_1 <- rowSums(d_chk_data_dupEnum[6:ncol_e], na.rm=TRUE)
View(d_chk_data_dupEnum)

#CHECK 4 - If more than one record for the same location of origin to the same destination community
d_chk_nRecords_perDestination <-chk_d_new_idp_B1 %>%
                                group_by(`location/adm4`) %>% 
                                summarise(nRecords = n())

d_chk_data_dupOrigin <- chk_d_new_idp_B1 %>%
                        group_by(`location/adm4`,`new_idp/B1/B1_11`,`new_idp/B1/B1_12`,`new_idp/B1/B1_13`,`new_idp/B1/B1_14`) %>% 
                        summarise(nDuplicate = n()) %>% 
                        left_join(d_chk_nRecords_perDestination,by=c("location/adm4"))
View(d_chk_data_dupOrigin)


#--------SAVE file----------
#---prepare save files---------------
wb<-openxlsx::createWorkbook()
addWorksheet(wb,"displacement_tracking")
addWorksheet(wb,"new_idp_B1")
addWorksheet(wb,"returnees_B2")
addWorksheet(wb,"departure_B3")
#
writeDataTable(wb,sheet="displacement_tracking",x=d_main,tableName ="tbl_displacement_tracking")
writeDataTable(wb,sheet="new_idp_B1",x=d_new_idp_B1,tableName ="tbl_new_idp_B1")
writeDataTable(wb,sheet="returnees_B2",x=d_returnees_B2,tableName ="tbl_returnees_B2")
writeDataTable(wb,sheet="departure_B3",x=d_departure_B3,tableName ="tbl_departure_B3")
openxlsx::saveWorkbook(wb,s_filename,overwrite = TRUE)

print("----DONE----")

