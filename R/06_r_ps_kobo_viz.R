'----
Developed by: Punya Prasad Sapkota
Last modified: 9 August 2018
----'
rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")

library(shiny)
library(shinydashboard)
#------------DEFINE Aggregation level----------------
##-----data preparation---------
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1455hrs_all_corrected_v2.xlsx"
data_fname<-"./Data/10_Viz/TurkeyXB_MSNA2018_data_merged_8files_2104_2112_2126_1600hrsV1.xlsx"
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

#start the clock
#ptm_start<-proc.time()
start_time <- as.numeric(as.numeric(Sys.time())*1000, digits=10) # place at start
##agg geographic level or geographic plus another variable
flag_agg_level<-"GEO"
#flag_agg_level<-"GEO_PLUS_VARS"

#List of Do not know and No answer list - collected from choices sheet
dnk_no_ans_label_list<-c("No answer","no answer", "Dont know","Do not know",
                         "Don’t know", "don't know", "dont know/no answer",
                         "Don’t know/Unsure", "Dont know / Unsure", "Dont know / Unsure",
                         "Do not know/ Unsure", "Do not know / unsure", "Dont Know / Unsure",
                         "do not know  / unsure", "Do not know/Unsure", "DO NOT KNOW",
                         "Unsure / no answer","Unsure","Not sure/do not know","Not sure/do not know",
                         "not sure / do not know", "Not sure / do not know")
#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
#
      print(paste0("Reading data file - ", Sys.time())) 
      #data<-read_excel(data_fname,col_types ="text",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      
      ###----------merge data-----------------------------------------------------
      data<- files_merge_xlsx(xlsx_path)
      data<-as.data.frame(data)
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
      agg_geo_level<-c("agg_pcode")
      #agg_level_colnames<-c(agg_geo_level, "ki_gender") #ki_gender is not in the data - need to add before proceeding
      #agg_level_colnames<-agg_geo_level
      #db_all$ki_gender<-NA
    
        ## aggregation is done at admin pcode level
        agg_level_colnames<-c(agg_geo_level)
        ##assign data for aggregation
        db<-data
        db_heading<-names(db) 
  ### if sector of the current variable is not 'current sector' or metadata information
       ##set i_aggmethod<-"DROP" #drop the data column from the output
        
####---------SELECT ONE--------BAR_CHART  
  #from survey - select select one
  #start pdf
  pdf(paste0(save_path,"bar_charts_select_one_questions",".pdf"))
  dev.off()
  s1_headers<-survey %>% filter(aggmethod=="SEL_1")
  for (i in 1:nrow(s1_headers)){
    vn_dcol<-s1_headers$gname[i]
    vn_title<-s1_headers$label[i]
    col_ind<-which(names(db)==vn_dcol)
    ##check if variable is in the data or not
    if (length(col_ind)>0){
        ##frequency
        d_viz<-db %>% select_at(vars(vn_dcol))
        d_viz<- d_viz %>% 
                na.omit() %>% 
                group_by_at(vars(vn_dcol)) %>% 
                summarize(freq_count=n()) %>% 
                mutate(freq_percentage=round(freq_count/sum(freq_count)*100)) %>% 
                arrange(desc(freq_count)) %>% 
                ungroup()
        
        names(d_viz)[1]<-"variables"
        ##Alternate method
        #f_count <- as.data.frame(table(d_viz))
        x_i<-"variables" #column name
        y_i<-"freq_percentage" #column name
        fill_i<-"freq_percentage"
        title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
        #d_i<-d_viz
        #--plot--
        bar_chart<-draw_barchart(d_viz,x_i,y_i,fill_i =y_i, title_i)
        bar_chart
        #save the viz
        i_viz_save_name<-paste0(save_path,"num_records_sector_partner","_",i,".png")
        #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
        ##print in the file
        print(bar_chart)
    }
  } 
  #end pdf
  dev.off()
  invisible(NULL)
####-----------------------DONE------------------------------------------------------------      
        
  ####---------SELECT MULTIPLE--------BAR_CHART  
  #start pdf
  pdf(paste0(save_path,"bar_charts_select_multiple_questions",".pdf"))
  s1_headers<-survey %>% filter(qtype=="select_multiple")
  for (i in 1:nrow(s1_headers)){
    vn_dcol<-s1_headers$gname[i]
    vn_title<-s1_headers$label[i]
    
    ##variable to check for select multiple
    vn_dcol<-paste0(vn_dcol,"/")
    
    col_ind<-which(str_detect(names(db), vn_dcol))
    ##check if variable is in the data or not
    if (length(col_ind)>0){
      ##frequency
      d_viz_sm<-db %>% select(col_ind)
      
      d_viz<-d_viz_sm %>% gather(key="key",value="value")
      
      
      d_viz<- d_viz %>% 
              na.omit() %>% 
              filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
              group_by_at(vars("key")) %>% 
              summarize(freq_count=n()) %>%
              mutate(freq_percentage=round(freq_count/sum(freq_count)*100)) %>% 
              ungroup() %>% 
              arrange(desc(freq_count)) 
            
      names(d_viz)[1]<-"variables"
      ###print only of it has records
      if (nrow(d_viz)>0){
              ##Alternate method
              #f_count <- table(d_viz)
              x_i<-"variables" #column name
              y_i<-"freq_percentage" #column name
              fill_i<-"freq_percentage"
              title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
              #--plot--
              #--plot--
              bar_chart<-draw_barchart(d_viz,x_i,y_i,fill_i=y_i, title_i)
              
              bar_chart
              #save the viz
              #i_viz_save_name<-paste0(save_path,"num_records_sector_partner","_",i,".png")
              #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
              ##print in the file
              print(bar_chart)
      }
    }
    
  } 
  #end pdf
  dev.off()
  invisible(NULL)
  ####-----------------------DONE------------------------------------------------------------      
  
  
  