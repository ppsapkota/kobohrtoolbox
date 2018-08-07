'----
************************************
Developed by: Punya Prasad Sapkota
Last modified: 4 July 2018
************************************
#-----Partner Coverage mapping

----'

#--------Merge multiple CSV files---------------------------
rm(list = ls())
source("./R/91_r_ps_kobo_library_init.R")

#read Admin daa
admin4<-read_excel("./Data/Admin/syr_admin_180627.xlsx", sheet="admin4", col_types = "text")
admin4_pop<-read_excel("./Data/Admin/admin4_pop_access.xlsx", col_types = "text")
admin4_pop<-admin4_pop %>% 
            select(Admin4Pcode, AOI_Jun_2018 ,Population_Class,numRequired_Partners)
#merge files
xlsx_path<-paste0("./Data/00_Coverage/MSNA2018_coverage_partners")
d_merged<- files_merge_xlsx(xlsx_path)

d_merged<-d_merged %>% 
        #  mutate(`group_metadata/X4`=as.character(`group_metadata/X4`))
          drop_na(Org) %>% 
          mutate(Org=gsub(" ","",Org))

#----------create workbook to save results--------
wb<-openxlsx::createWorkbook()
addWorksheet(wb,"msna_coverage_detail")
addWorksheet(wb,"msna_coverage_summary")


#-------bring org name for the code-------------
d_admin4_npartner<- d_merged %>% 
                    select(admin4Pcode, Org, Assigned_for_MSNA) %>% 
                    filter(Assigned_for_MSNA=="Assigned for data collection") %>% 
                    distinct() %>% 
                    group_by(admin4Pcode) %>% 
                    summarize (numPartner=n()) %>% 
                    ungroup()

#Summary
d_partner_num_communities<- d_merged %>% 
                        select(admin1Name_en,admin4Pcode, Org, Assigned_for_MSNA) %>% 
                        filter(Assigned_for_MSNA=="Assigned for data collection") %>% 
                        distinct() %>% 
                        group_by(admin1Name_en, Org) %>% 
                        summarize (numCommunities=n()) %>% 
                        spread(key=admin1Name_en, val=numCommunities) %>% 
                        ungroup()

#Summary
d_gov_num_communities<- d_merged %>% 
                        select(admin1Name_en,admin4Pcode, Assigned_for_MSNA) %>% 
                        filter(Assigned_for_MSNA=="Assigned for data collection") %>% 
                        distinct() %>% 
                        group_by(admin1Name_en) %>% 
                        summarize (numCommunities=n()) %>%
                        ungroup()


#Summary
d_govpcode_num_communities<- d_merged %>% 
                             select(admin1Pcode,admin4Pcode, Org, Assigned_for_MSNA) %>% 
                              filter(Assigned_for_MSNA=="Assigned for data collection") %>% 
                              distinct() %>% 
                              group_by(admin1Pcode, Org) %>% 
                              summarize (numPartner=n()) %>%
                              spread(key=admin1Pcode, val=numPartner) %>%
                              ungroup()

#in partner table - bring population class and required partners
d_admin4_npartner<-left_join(admin4_pop,d_admin4_npartner,by=c("Admin4Pcode"="admin4Pcode"))
#Coverage_gap
d_admin4_npartner$coverage_gap<-as.numeric(d_admin4_npartner$numPartner) - as.numeric(d_admin4_npartner$numRequired_Partners)


d_admin4_partners<- d_merged %>% 
                    select(admin4Pcode, Org, Assigned_for_MSNA) %>% 
                    #filter(Assigned_for_MSNA=="Assigned for data collection") %>% 
                    distinct() %>% 
                    group_by(admin4Pcode, Org,Assigned_for_MSNA) %>% 
                    #summarize (numPartner=n()) %>% 
                    spread(key=Org,value=Assigned_for_MSNA) %>% 
                    ungroup()

#merge with Admin4
d_admin4_partners_coverage<-left_join(admin4,d_admin4_npartner,by=c("admin4Pcode"="Admin4Pcode")) %>% 
                            left_join(d_admin4_partners,by=c("admin4Pcode"="admin4Pcode"))
#replace NA by 0
d_admin4_partners_coverage<-d_admin4_partners_coverage %>% 
                            mutate(numPartner= replace_na(numPartner,0))

#export
openxlsx::write.xlsx(d_merged,paste0("./data/00_Coverage","/MSNA2018_TurkeyXB_coverage_merged.xlsx"),keepNA=FALSE,sheetName="data")
openxlsx::write.xlsx(d_admin4_partners_coverage,paste0("./data/00_Coverage","/MSNA2018_TurkeyXB_coverage_gap.xlsx"),keepNA=FALSE,sheetName="data")
openxlsx::write.xlsx(d_partner_num_communities,paste0("./data/00_Coverage","/MSNA2018_TurkeyXB_coverage_summary.xlsx"),keepNA=FALSE,sheetName="data")
openxlsx::write.xlsx(d_gov_num_communities,paste0("./data/00_Coverage","/MSNA2018_TurkeyXB_coverage_summary_gov.xlsx"),keepNA=FALSE,sheetName="data")
openxlsx::write.xlsx(d_govpcode_num_communities,paste0("./data/00_Coverage","/MSNA2018_TurkeyXB_coverage_summary_govpcode.xlsx"),keepNA=FALSE,sheetName="data")



