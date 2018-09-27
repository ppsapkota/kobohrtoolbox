
'----
**********************************
Developed by: Punya Prasad Sapkota
Last modified: 18 July 2018
**********************************
#----Exporting data to external CSV file
----'
source("./R/91_r_ps_kobo_library_init.R")
main_dir<-getwd()

#library("googlesheets")
t_stamp <- format(Sys.time(),"%Y%m%d_%H%M")
#hub<-"NES"
hub<-"TurkeyXB"
xlsx_path<-"./Data/10_Viz/"
save_path<-"./Data/10_Viz/Summary/"
parter_list_f<-"./Data/MSNA2018_TurkeyXB_coverage_summary_govpcode.xlsx"
admin_fname<-"./Data/Admin/syr_admin_20180701.xlsx"

###----------run below-----------------------------------------------------
#d_merged<- as.data.frame(files_merge_xlsx(xlsx_path))

d_merged<-read_excel("./Data/10_Viz/MSNA2018_RAW_data_merged_20180831_1900hrs_FINAL_ALL_SECTORS.xlsx", col_types = "text", sheet=)

d_merged[is.na(d_merged)] <- 'NA'
###--partner name--
partner_list<-read_excel(parter_list_f, col_types = "text")
partner_list<-select(partner_list,organization_code,Organisations)

d_merged<-left_join(d_merged,partner_list,by=c("Q_E/Q_E6"="organization_code"))

###-------read admin list
d_admin4<-read_excel(admin_fname,sheet="admin4",col_types = "text")
d_admin4<-select(d_admin4, admin1Name_en,admin2Name_en,admin3Name_en,admin4Name_en,admin4Pcode)
##read neighbourhoods list
d_admin5<-read_excel(admin_fname,sheet="city_neighbourhoods",col_types = "text")
d_admin5<-select(d_admin5, admin4Name_en,admin4Pcode) %>% distinct()
#

#d_merged<-left_join(d_merged,d_admin4, by=c("Q_M/admin4"="admin4Pcode"))
#openxlsx::write.xlsx(d_merged,paste0(save_path,"msna2018_data_raw_merged","_",t_stamp,".xlsx"),sheetName="msna2018_data_raw",row.names=FALSE)

####-----------Coverage map------------------------------------
wb<-openxlsx::createWorkbook()
addWorksheet(wb,"data")
addWorksheet(wb, "coverage_summary")

d_coverage_comm<-d_merged %>% 
                 select("admin1pcode","admin2pcode","admin3pcode","admin4pcode","neighpcode",`Q_M/admin1`,`Q_M/admin2`,`Q_M/admin3`,`Q_M/admin4`,`Q_M/neighborho`, `Q_E/Q_E6`,Organisations)
names(d_coverage_comm)<-str_replace_all(names(d_coverage_comm),"/","_")

d_coverage_comm_summary<-d_coverage_comm %>% 
                         #distinct() %>% 
                         group_by(admin1pcode,`Q_M_admin1`,admin4pcode) %>% 
                         summarise(n_records=n()) %>% 
                         ungroup()

writeData(wb,sheet="data",x=d_coverage_comm)
writeData(wb, sheet="coverage_summary",x=d_coverage_comm_summary)
saveWorkbook(wb, file=paste0(save_path,"msna2018_data_coverage",".xlsx"),overwrite = TRUE)

###--------get the summary-------
data<-d_merged
#Enumerators
admin_fields<-c("Q_E/Q_E4","admin1pcode","admin2pcode","admin3pcode","admin4pcode","neighpcode","Q_E/Q_E5","Q_E/Q_E6","Q_M/admin1","Q_M/admin2","Q_M/admin3","Q_M/admin4","Q_M/neighborho")
rename_fields<-c(admin_fields,c("cfp_gender","cfp_age","modality" ,"sector"))
#intersector
sector_fields<-c("I_S_Q/Q_K1/Q_K1_A","I_S_Q/Q_K1/Q_K1_B","I_S_Q/Q_K1/Q_K1_C")
data_ki_is<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="intersector")
names(data_ki_is)<-rename_fields
##cccm
sector_fields<-c("ccm_group/cfp_ccm_gr/cpf_ccm_ge","ccm_group/cfp_ccm_gr/cpf_ccm_ag", "ccm_group/cfp_ccm_gr/cpf_ccm_mo")
data_ki_cccm<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="cccm")
names(data_ki_cccm)<-rename_fields
#cccm_ki_gender<-data$`ccm_group/cfp_ccm_gr/cpf_ccm_ge`
#cccm_ki_age<-data$`ccm_group/cfp_ccm_gr/cpf_ccm_ag`

#edu
sector_fields<-c("educationg/edu_cfp_me/edu_interinf/cpf_edu_ge","educationg/edu_cfp_me/edu_interinf/cpf_edu_ag","educationg/edu_cfp_me/edu_interv/q3_1modali")
data_ki_edu<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="education")
names(data_ki_edu)<-rename_fields
#edu_ki_gender<-data$`educationg/edu_cfp_me/edu_interinf/cpf_edu_ge`
#edu_ki_age<-data$`educationg/edu_cfp_me/edu_interinf/cpf_edu_ag`

#nfi
sector_fields<-c("nfi_group/nfi_cfp_gr/nfi_cfp_ge","nfi_group/nfi_cfp_gr/nfi_cfp_ag", "nfi_group/nfi_cfp_gr/nfi_cfp_mo")
data_ki_nfishelter<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="nfishelter")
names(data_ki_nfishelter)<-rename_fields
#nfishelter_ki_gender<-data$`nfi_group/nfi_cfp_gr/nfi_cfp_ge`
#nfishelter_ki_age<-data$`nfi_group/nfi_cfp_gr/nfi_cfp_ag`

#fss
sector_fields<-c("q5food_sec/food51_com/k_5_1gende","q5food_sec/food51_com/k_5_2age_o", "q5food_sec/food51_com/k_5_3modal")
data_ki_fss<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="fss")
names(data_ki_fss)<-rename_fields
#fss_ki_gender<-data$`q5food_sec/food51_com/k_5_1gende`
#fss_ki_age<-data$`q5food_sec/food51_com/k_5_2age_o`

#health medical professional
sector_fields<-c("q6health_s/qcomm_h_p/k_6_1gende","q6health_s/qcomm_h_p/k_6_2age_o","q6health_s/qcomm_h_p/k_6_3modal")
data_ki_health_mf<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="health (medical professional)")
names(data_ki_health_mf)<-rename_fields
#health_mf_ki_gender<-data$`q6health_s/qcomm_h_p/k_6_1gende`
#health_mf_ki_age<-data$`q6health_s/qcomm_h_p/k_6_2age_o`

#health non medical professional
sector_fields<-c("q6health_s/qcomm_h_np/k_6_1_1gen","q6health_s/qcomm_h_np/k_6_2_1age", "q6health_s/qcomm_h_np/k_6_3_1mod")
data_ki_health_nonmf<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="health (non medical professional)")
names(data_ki_health_nonmf)<-rename_fields
#health_nonmf_ki_gender<-data$`q6health_s/qcomm_h_np/k_6_1_1gen`
#health_nonmf_ki_age<-data$`q6health_s/qcomm_h_np/k_6_2_1age`

#erl
sector_fields<-c("q7early_re/qcommunity_fp2/k_7_1gende","q7early_re/qcommunity_fp2/k_7_2age_o", "q7early_re/qcommunity_fp2/k_7_3modal")
data_ki_erl<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="erl")
names(data_ki_erl)<-rename_fields
#erl_ki_gender<-data$`q7early_re/qcommunity_fp2/k_7_1gende`
#erl_ki_age<-data$`q7early_re/qcommunity_fp2/k_7_2age_o`

#protection
sector_fields<-c("q8protecti/qcommunity_fp3/k_8_1gende","q8protecti/qcommunity_fp3/k_8_2age_o","q8protecti/qcommunity_fp3/k_8_3modal")
data_ki_protection<-data %>% select(admin_fields,sector_fields) %>% mutate(sector="protection")
names(data_ki_protection)<-rename_fields
#protection_ki_gender<-data$`q8protecti/qcommunity_fp3/k_8_1gende`
#protection_ki_age<-data$`q8protecti/qcommunity_fp3/k_8_2age_o`

#--------data--------------------------
data_ki<-rbind(data_ki_is,
               data_ki_cccm,
               data_ki_edu,
               data_ki_nfishelter,
               data_ki_fss,
               data_ki_health_mf,
               data_ki_health_nonmf,
               data_ki_erl,
               data_ki_protection
        )
           
#data_ki<-rename(data_ki,"ki_gender"="is_ki_gender","ki_age"="is_ki_age")

#############----------------------Partner Name-----------------------------------------------
partner_list<-read_excel(parter_list_f, col_types = "text")
partner_list<-select(partner_list,organization_code,Organisations)
data_ki<-full_join(partner_list,data_ki, by=c("organization_code"="Q_E/Q_E6"))
#
data_ki[data_ki[,]=="NA"]<-NA
data_ki<-rename(data_ki,"admin1"="Q_M/admin1")
data_ki<-rename(data_ki,"admin2"="Q_M/admin2")
data_ki<-rename(data_ki,"admin3"="Q_M/admin3")
data_ki<-rename(data_ki,"admin4"="Q_M/admin4")
data_ki<-rename(data_ki,"admin5"="Q_M/neighborho")

#data_ki<-left_join(data_ki,d_admin4,by=c("admin4"="admin4Pcode"))
### Save data KI
openxlsx::write.xlsx(data_ki,paste0(save_path,"msna2018_data_cfp_info","_",t_stamp,".xlsx"),sheetName="msna2018_data_cfp_info",row.names=FALSE)

####---------PUSH to Google Sheet------------
# #gs_auth()
# d_gs_sheets<-gs_ls()
# gs_title("MSNA_KI_Info")
# gs_object <- gs_key("1ArVHZZp7nX292DI7LkLJnVmW3XDn4QVrDBKcXQcdQF0")
# #The first command sets the header names (anchored at cell A1). 
# #The second command uploads the data itself. We recommend setting trim=TRUE so
# #the sheet only uses the minimum number of rows and columns needed.
# gs_edit_cells(gs_object, ws='msna2018_data_ki_info', input=colnames(data_ki), byrow=TRUE, anchor="A1")
# gs_edit_cells(gs_object, ws='msna2018_data_ki_info', input = data_ki, anchor="A2", col_names=FALSE, trim=TRUE)


##------------SUMMARY---------------------------------------------
d_num_records_partners<-data_ki %>%
                        select(organization_code, Organisations,"admin1pcode","admin2pcode","admin3pcode","admin4pcode","neighpcode",admin1,admin4,admin5,`Q_E/Q_E4`)%>%
                        filter(!is.na(`Q_E/Q_E4`) | !is.na(admin4)) %>% 
                        distinct()%>% 
                        group_by(organization_code) %>% 
                        summarise(n_communities=n()) %>% 
                        ungroup()

d_num_records_partners<-full_join(select(partner_list,organization_code,Organisations),d_num_records_partners,by=c("organization_code"))
# d_num_records_partners<-d_num_records_partners %>%
#                         mutate(Total_Communities_Planned=as.numeric(Total_Communities_Planned)) %>% 
#                         mutate(gap=Total_Communities_Planned-n_communities)

openxlsx::write.xlsx(d_num_records_partners,paste0(save_path,"msna2018_data_coverage","_",t_stamp,".xlsx"),sheetName="msna2018_data_coverage",row.names=FALSE)

# 
# ###---Completeness check------------
# d_num_records_sector_partner<-data_ki %>% 
#                     filter(!is.na(ki_gender)) %>% 
#                     group_by(organization_code, Organisations,sector) %>% 
#                     summarise(n_records=n()) %>% 
#                     ungroup()
# #
# heatmap_num_records_sector_partner_savename<-paste0(save_path,"num_records_sector_partner","_",t_stamp,".pdf")
# p<-draw_heatmap(d_num_records_sector_partner,"sector","Organisations","n_records","# of records per sector")
# ggsave(heatmap_num_records_sector_partner_savename,plot=p,dpi=300, width=11.69, height=8.9, units="in", scale=1)
# ####----------------------------------------------------------------------------#####
# d_ki_gender_sector<-data_ki %>% 
#                           filter(!is.na(admin4)) %>% 
#                           group_by(sector,ki_gender) %>% 
#                           summarise(n_records=n()) %>%
#                           mutate(ki_gender=ifelse(is.na(ki_gender),"NA",ki_gender)) %>% 
#                           ungroup()
# #heatmap_ki_gender_sector_savename<-paste0("./Data/00_Coverage/heatmap_ki_gender_sector","_",t_stamp,".pdf")
# #draw_heatmap(d_ki_gender_sector,"ki_gender","sector","n_records",heatmap_ki_gender_sector_savename)
# 
# barchart_ki_gender_sector_savename<-paste0(save_path,"barchart_ki_gender_sector","_",t_stamp,".pdf")
# p<-draw_barchart_stacked(d_ki_gender_sector,"sector","n_records","ki_gender","# of KIs per sector")
# ggsave(barchart_ki_gender_sector_savename,plot=p,dpi=300, width=11.69, height=8.9, units="in", scale=1)
# ##---------------------------------------------------
# d_ki_gender_partner<-data_ki %>% 
#                     filter(!is.na(admin4)) %>% 
#                     group_by(organization_code, Organisations,ki_gender) %>% 
#                     summarise(n_records=n()) %>% 
#                     ungroup()
# #heatmap_ki_gender_savename<-paste0("./Data/00_Coverage/heatmap_ki_gender","_",t_stamp,".pdf")
# #p<-draw_heatmap(d_ki_gender_partner,"ki_gender","Organisations","n_records","# of KIs per partner")
# #p
# #ggsave(heatmap_ki_gender_savename,plot=p,dpi=300, width=11.69, height=8.9, units="in", scale=1)
# 
# barchart_ki_gender_savename<-paste0(save_path,"barchart_ki_gender","_",t_stamp,".pdf")
# p<-draw_barchart_stacked(d_ki_gender_partner,"Organisations","n_records","ki_gender","# of KIs per partner")
# ggsave(barchart_ki_gender_savename,plot=p,dpi=300, width=11.69, height=8.9, units="in", scale=1)
# 
# ##---------------------------------------------------
# d_ki_gender_partner_sector<-data_ki %>% 
#                       filter(!is.na(admin4)) %>% 
#                       group_by(organization_code,Organisations,sector,ki_gender) %>% 
#                       summarise(n_records=n()) %>% 
#                       ungroup()
# 
# 
# #heatmap_ki_gender_savename<-paste0("./Data/00_Coverage/heatmap_ki_gender","_",t_stamp,".pdf")
# #draw_heatmap(d_ki_gender_partner,"ki_gender","Organisations","n_records",heatmap_ki_gender_savename)

###------SOME DAtA CHECKS-----------------------------------------

##check neighbourhood pcode for d_admin5 list
chk_neighbourhood_pcode<-d_admin5 %>% 
                         inner_join(select_at(data,vars("Q_E/Q_E6","Q_M/admin4","Q_M/neighborho")),by=c("admin4Pcode"="Q_M/admin4")) %>% 
                         filter(is.na(`Q_M/neighborho`) | `Q_M/neighborho`=='NA')


openxlsx::write.xlsx(chk_neighbourhood_pcode,paste0(save_path,"neighbourhood_pcode_missing","_",t_stamp,".xlsx"),sheetName="neighbourhood_pcode_check",row.names=FALSE)






