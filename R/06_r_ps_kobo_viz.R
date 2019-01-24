'----
Developed by: Punya Prasad Sapkota
Last modified: 9 August 2018
----'
source("./R/91_r_ps_kobo_library_init.R")
source("./R/r_func_viz_utils.R")
#install.packages("ReporteRs")
#library(ReporteRs)
library(officer)
#library(shiny)
#library(shinydashboard)
#------------DEFINE Aggregation level----------------
##-----data preparation---------
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1455hrs_all_corrected_v2.xlsx"
#data_fname<-"./Data/10_Viz/MSNA2018_data_merged_DEMO_STIMA_AGG_Step07_FINAL_all.xlsx"
data_fname<-"./Data/10_Viz/MSNA2018_Aggregated_data_20180831_1900hrs_FINAL_ALL_SECTORS_AGG_Step07_FINAL.xlsx"
#data_fname<-"./Data/10_Viz/CFP_Gender_Based_Aggregation/MSNA2018_Aggregated_Data_20180831_1900hrs_AGG_Step07_FINAL_intersector_CFP_Gender.xlsx"
#-------------------------------------#
nameodk<-"./xlsform/ochaMSNA2018v9_master_agg_method.xlsx"

#hub<-"NES"
hub<-"TurkeyXB"

if (hub=="TurkeyXB"){
  #####STEP 2--Merge data---
  t_stamp <- format(Sys.time(),"%Y%m%d_%H%M")
  #
  xlsx_path<-"./Data/10_Viz/"
  save_path<-"./Data/10_Viz/"
}else if (hub=="NES"){
  #####STEP 2--Merge data---
  t_stamp <- format(Sys.time(),"%Y%m%d_%H%M")
  #
  xlsx_path<-"./Data/01_Download_CSV/NES/"
  save_path<-"./Data/00_Coverage/Viz/NES/"
}
##
#---Save document
docx_charts<-paste0(save_path,"msna_report_summary_graphics_NWS_AGG",".docx")

#---save table
save_fname_agg_tbl<-paste0(save_path,"msna_report_summary_tbl_NWS_AGG",".xlsx")
wb<-createWorkbook()
addWorksheet(wb,"summary")
i_startrow=5
#
# writeData(wb,sheet="summary",x="Number of projects by cluster and partner type",startRow = i_startrow-1)
# writeDataTable(wb,sheet="summary",x=project_cluster_org_type,tableName ="project_cluster_org_type",startRow = i_startrow)
# i_startrow<-i_startrow+nrow(project_cluster_org_type)+5

#start the clock
#ptm_start<-proc.time()
start_time <- as.numeric(as.numeric(Sys.time())*1000, digits=10) # place at start
##agg geographic level or geographic plus another variable
flag_agg_level<-"GEO"
#flag_agg_level<-"GEO_PLUS_VARS" #FACET
#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
      print(paste0("Reading data file - ", Sys.time())) 
      #data<-read_excel(data_fname,col_types ="text", sheet="data",na='NA')
      data<-read_excel(data_fname,col_types ="text", sheet="MSNA2018_data_aggregated",na='NA')
      
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      
      ###----------merge data-----------------------------------------------------
      #data<- files_merge_xlsx(xlsx_path)
      data<-as.data.frame(data)
      
      #FILTER DATA FOR Demilitarized zone
      #data<-data %>% 
      #      filter(DMZ_20181017=="DMZ_20181017_v3")
      
      data<-data %>% 
            filter(Access_Pockets != "NA")
      
      #read data file to recode
      #read ODK file choices and survey sheet
      survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
      dico<-read_excel(nameodk,sheet="choices",col_types ="text")
     
      #--key
      #key<-row.names(data)
      #data<-cbind(key, data)
      #some cleanup of the data
      for (kl in 1:ncol(data)){
        data[,kl]<-ifelse(data[,kl]=="NA" | data[,kl]=="" | data[,kl]=="NULL" | is.nan(data[,kl]),NA,data[,kl])
      }
      
    ####-------THIS BLOCK------------------------
      ###unit of data collection
      data_geo_level<-"agg_pcode"
      ###aggregation level -> FACET Level
      agg_geo_level<-c("admin1pcode","Q_M/admin1")
      #facet_col_name<-c("cfp_gender_intersector")
      facet_col_name<-c("Access_Pockets")
      #agg_level_colnames<-c(agg_geo_level, "ki_gender") #ki_gender is not in the data - need to add before proceeding
      #agg_level_colnames<-agg_geo_level
      #db_all$ki_gender<-NA
      ## aggregation is done at admin pcode level
      agg_level_colnames<-c(agg_geo_level, facet_col_name)
        
      ##assign data for aggregation
      db<-data
      db_heading<-names(db) 
        #
      agg_level_colind<-which(names(db) %in% agg_level_colnames)
      
      #agg_level_colind<-which(str_detect(names(db), agg_level_colnames))  
  ### if sector of the current variable is not 'current sector' or metadata information
      ##set i_aggmethod<-"DROP" #drop the data column from the output
        
####---------SELECT ONE--------BAR_CHART  
  #from survey - select select one
  #start pdf
  #pdf(paste0(save_path,"bar_charts_select_one_questions",".pdf"))
  #docs_barchart <- tempfile(fileext = ".docx")
  
  ##add barchart to the file
  doc<-read_docx() %>% 
       body_add_par("MSNA 2018 - Select One questions", style = "Normal")
  
  #dev.off()
  
  #loop through headers
  s1_headers<-survey %>% filter(aggmethod!="NA" & !is.na(aggmethod))
  for (i in 1:nrow(s1_headers)){
    vn_qtype<-s1_headers$qtype[i]
    vn_aggmethod<-s1_headers$aggmethod[i]
    vn_gname<-s1_headers$gname[i]
    vn_title<-s1_headers$label[i]
    vn_title_full<-s1_headers$gname_label[i]
    vn_qrankgroup<-s1_headers$qrankgroup[i]
    #
    print (paste0("processing - ", i, " - method: ",vn_aggmethod, " - ", vn_gname))
    col_ind<-0
    ####------------------####
    if (vn_qtype=="select_multiple"){
      vn_gname<-paste0(vn_gname,"/")
      col_ind<-which(str_detect(names(db), vn_gname))  
    }
    
    if (vn_qtype=="select_one"){
      col_ind<-which(names(db)==vn_gname)
    }
    
    if (vn_aggmethod=="RANK3"){
      vn_gname<-paste0(vn_qrankgroup,"/","RANK3_SCORE/")
      col_ind<-which(str_detect(names(db), vn_gname))
    }
### SELECT_ONE
##check if variable is in the data or not
    if (length(col_ind)>0 && (vn_aggmethod=="SEL_1" | vn_aggmethod=="ORD_1_RUP" | vn_aggmethod=="ORD_1")){
        ##get the data
        #call function
      if (flag_agg_level=="GEO"){  
        agg_data_select_one(db,data_geo_level,agg_geo_level,vn_gname)
      }
        #agg_data_facet<-function(db,data_geo_level,agg_geo_level,facet_col_name, vn_gname)
      
        #RUN ONLY IF FACET is DEFINED
       if (flag_agg_level=="GEO_PLUS_VARS"){
        agg_data_facet_select_one(db,data_geo_level, agg_geo_level,facet_col_name,vn_gname)
       }
    }
  
####---------SELECT MULTIPLE--------BAR_CHART  
    ##check if variable is in the data or not
    if (length(col_ind)>0 && (vn_qtype=="select_multiple")){
      ##prepare data, generate summary tables and charts
      if (flag_agg_level=="GEO"){  
          agg_data_select_multiple(db,data_geo_level,agg_geo_level,vn_gname)
      }
      #FACETED
      if (flag_agg_level=="GEO_PLUS_VARS"){
          agg_data_facet_select_multiple(db,data_geo_level,agg_geo_level,facet_col_name,vn_gname)
      }
      
    }
  ####--------RANK3-------------------------------------------
    if (length(col_ind)>0 && (vn_qtype=="select_one") && (vn_aggmethod=="RANK3")){
      
      #Total
      if (flag_agg_level=="GEO"){  
          agg_data_select_one_rank(db,data_geo_level,agg_geo_level, vn_gname)
      }
      ##FACETED
      if (flag_agg_level=="GEO_PLUS_VARS"){
          agg_data_facet_select_one_rank (db,data_geo_level,agg_geo_level,facet_col_name, vn_gname)
      }
      
    }
    
  #-----------------------------------#
} #for headers 
  #end pdf
  #dev.off()
  #invisible(NULL)
  print(doc,target = docx_charts)
  
  #save file                     
  saveWorkbook(wb,save_fname_agg_tbl,overwrite = TRUE)
  
  ####-----------------------DONE------------------------------------------------------------      
  
  
  