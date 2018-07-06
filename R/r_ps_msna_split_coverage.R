rm(list = ls())

source("./R/91_r_ps_kobo_library_init.R")

f_coverage_fname<-"C:\\Dropbox (OCHA)\\D-IM and Assessment\\HNO\\HNO_2019\\MSNA 2018\\Turkey partners coverage\\WoS_Consolidated\\MSNA2018_PartnerCoverage_TurkeyXB_and_WoS_20180627_Coverage assigned_DRAFT.xlsx"
f_admin4<-"./Data/Admin/syr_admin_180627.xlsx"
f_save_location <- "C:\\Dropbox (OCHA)\\D-IM and Assessment\\HNO\\HNO_2019\\MSNA 2018\\Turkey partners coverage\\WoS_Consolidated\\Coverage_all_partners_individual\\\\"

#read sheets
data_admin4<-read_excel(f_admin4,sheet="admin4")
data_coverage<-read_excel(f_coverage_fname,sheet="WoS_ConsolidatedData")
data_coverage<- rename(data_coverage,"Initially_Proposed_Coverage"="Coverd")
#read file for the list of organisation and kobo user name
data_org_list <- data_coverage %>% 
                 filter (Hub=="Turkey XB") %>% 
                 distinct(Org)


for (i in 1:nrow(data_org_list))
{
  #i<-1
  org_name <-data_org_list$Org[i]
  
  #prepare file name
  f_savename <- paste0(f_save_location,org_name,"_TRXB_","MSNA_Assigned_Coverage.xlsx")
  
  #get coverage information for selected partner
  data_coverage_org <- data_coverage %>% 
                       filter(Hub =="Turkey XB" & Org == org_name) %>% 
                       select (admin4Pcode,Type, Org, Tools, Hub,Assigned_for_MSNA)
  
  #Join coverage to the master Adminlist
  data_coverage_org<-data_admin4 %>% 
                     full_join(data_coverage_org, by=c("admin4Pcode"="admin4Pcode")) %>% 
                     select(-c(admin0Name_ar,admin0Name_en,admin0Pcode,LastUpdateDate)) %>% 
                     arrange(admin1Name_en,admin2Name_en,admin3Name_en,admin4Name_en)
  #NOW save file
  wb<-createWorkbook()
  sheetname_i<-"MSNA_Assigned_Coverage"
  addWorksheet(wb,sheetname_i)
  #
  writeDataTable (wb,sheet=sheetname_i,x=data_coverage_org)
  #
  saveWorkbook(wb,f_savename,overwrite = TRUE)
}
 




