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
#data_fname<-"./Data/10_Viz/MSNA2018_Aggregated_data_20180831_1900hrs_FINAL_ALL_SECTORS_AGG_Step07_FINAL.xlsx"
data_fname<-"./Data/10_Viz/CFP_Gender_Based_Aggregation/MSNA2018_Aggregated_Data_20180831_1900hrs_AGG_Step07_FINAL_protection_CFP_Gender.xlsx"
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
docx_charts<-paste0(save_path,"msna_report_summary_graphics_protection",".docx")
#start the clock
#ptm_start<-proc.time()
start_time <- as.numeric(as.numeric(Sys.time())*1000, digits=10) # place at start
##agg geographic level or geographic plus another variable
flag_agg_level<-"GEO"
#flag_agg_level<-"GEO_PLUS_VARS"
#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
      print(paste0("Reading data file - ", Sys.time())) 
      data<-read_excel(data_fname,col_types ="text", sheet="data",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      
      ###----------merge data-----------------------------------------------------
      #data<- files_merge_xlsx(xlsx_path)
      data<-as.data.frame(data)
      
      #FILTER DATA FOR Demilitarized zone
      #data<-data %>% 
      #      filter(DMZ_20181017=="DMZ_20181017_v3")
      
      
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
      facet_col_name<-c("cfp_gender_protection")
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
        #agg_data_facet<-function(db,data_geo_level,agg_geo_level,facet_col_name, vn_gname)
        agg_data_facet_select_one(db,data_geo_level, agg_geo_level,facet_col_name,vn_gname)
      
        # d_viz_so<-db %>% select_at(vars(data_geo_level,agg_level_colnames,vn_gname))
        # #d_viz<-db %>% select(col_ind)
        # 
        # #
        # d_viz<- d_viz_so %>% 
        #         na.omit() %>% 
        #         group_by_at(vars(agg_level_colnames,vn_gname)) %>% 
        #         summarize(freq_count=n()) %>% 
        #         mutate(freq_percentage=round(freq_count/sum(freq_count)*100)) %>% 
        #         arrange(desc(freq_count)) %>% 
        #         ungroup() 
        # 
        # i_colind<-which(names(d_viz)==vn_gname)
        # 
        # names(d_viz)[i_colind]<-"variables"
        # ##Alternate method
        # total_responses<-d_viz_so %>%
        #                  select_at(vars(data_geo_level)) %>% 
        #                  distinct() %>% 
        #                  nrow()
        #                  
        # 
        # #total_responses<- sum(as.numeric(d_viz$freq_count))
        # ##total responses by agg_level_colnames
        # d_total_responses_agg_level<- d_viz %>% 
        #                               group_by_at(vars(agg_level_colnames)) %>% 
        #                               summarise(total_responses=sum(freq_count)) %>% 
        #                               ungroup() 
        # ###TABULAR Output
        # ###can I flip it for frequency count?
        # d_viz_freq_count<-d_viz %>% select(-freq_percentage) %>% spread(key=variables,value=c(freq_count),fill=0) %>% 
        #                     left_join(d_total_responses_agg_level,by=agg_geo_level)
        # #
        # d_viz_freq_percentage<-d_viz %>% select(-freq_count) %>% spread(key=variables,value=c(freq_percentage),fill=0)
        # d_viz_freq_percentage<-d_viz_freq_percentage %>% left_join(d_total_responses_agg_level,by=agg_geo_level)
        # #For total
        # d_viz_total<- d_viz_so %>% 
        #   na.omit() %>% 
        #   group_by_at(vars(vn_gname)) %>% 
        #   summarize(freq_count=n()) %>% 
        #   mutate(freq_percentage=round(freq_count/sum(freq_count)*100)) %>% 
        #   arrange(desc(freq_count)) %>% 
        #   ungroup()
        # 
        # i_colind<-which(names(d_viz_total)==vn_gname)
        # names(d_viz_total)[i_colind]<-"variables"
        # #
        # #For Facet total
        # d_viz_facet_total<- d_viz_so %>% 
        #                     na.omit() %>% 
        #                     group_by_at(vars(facet_col_name, vn_gname)) %>% 
        #                     summarize(freq_count=n()) %>% 
        #                     mutate(freq_percentage=round(freq_count/sum(freq_count)*100)) %>% 
        #                     arrange(desc(freq_count)) %>% 
        #                     ungroup()
        # 
        # i_colind<-which(names(d_viz_facet_total)==vn_gname)
        # names(d_viz_facet_total)[i_colind]<-"variables"
        # 
        # 
        # 
        # #
        # #a<-as.data.frame(table(d_viz_so[,2], d_viz_so[,c(vn_gname)]))
        # #b<-as.data.frame(prop.table(d_viz_so[,2], d_viz_so[,c(vn_gname)]))
        # x_i<-"variables" #column name
        # y_i<-"freq_percentage" #column name
        # fill_i<-"freq_percentage"
        # #title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
        # title_i<- paste0(str_wrap(vn_title, width=50))
        # #d_i<-d_viz
        # #--plot--
        # bar_chart<-draw_barchart_percentage(d_viz_total,x_i,y_i,fill_i =y_i, title_i)
        # bar_chart
        # #save the viz
        # #i_viz_save_name<-paste0(save_path,gsub("/","_",vn_gname),"_",i,".png")
        # #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
        # #
        # doc<-body_add_gg(doc,value=bar_chart,style = "Normal")
        # doc<-body_add_par(doc,paste0("# of records: ",total_responses), style = "Normal")
        # #draw_barchart_facet
        # #--plot--
        # bar_chart_facet<-draw_barchart_facet_percentage(d_viz_facet_total,x_i,y_i,fill_i=y_i, title_i,facet_i = facet_col_name)
        # bar_chart_facet
        # #
        # doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
        # doc<-body_add_table(doc,d_total_responses_agg_level, style = "table_template")
        # ##print in the file
    }
  #} 
  
  #end pdf
  #dev.off()
  #invisible(NULL)
####-----------------------DONE------------------------------------------------------------      
        
####---------SELECT MULTIPLE--------BAR_CHART  
  #start pdf
  #pdf(paste0(save_path,"bar_charts_select_multiple_questions",".pdf"))
  #s1_headers<-survey %>% filter(qtype=="select_multiple")
  #for (i in 1:nrow(s1_headers)){
  #  vn_dcol<-s1_headers$gname[i]
  #  vn_title<-s1_headers$label[i]
  #  
  #  ##variable to check for select multiple
  #  vn_dcol<-paste0(vn_dcol,"/")
  #  col_ind<-which(str_detect(names(db), vn_dcol))
    ##check if variable is in the data or not
    if (length(col_ind)>0 && (vn_qtype=="select_multiple")){
      ##frequency
      agg_data_facet_select_multiple(db,data_geo_level,agg_geo_level,facet_col_name,vn_gname)
      # f<-c(data_geo_level,agg_level_colnames)
      # col_ind_f<-which(names(db) %in% f)
      # #
      # col_ind_i<-which(str_detect(names(db),vn_gname))
      # 
      # d_viz_sm<-db %>% select(col_ind_f, col_ind_i)
      # #
      # d_viz<-d_viz_sm %>% gather(key="key",value="value",(length(col_ind_f)+1):ncol(d_viz_sm))
      # d_viz$key<-str_remove_all(d_viz$key,vn_gname)
      # d_viz$key<-gsub("_","/",d_viz$key)
      # 
      # ###calculate number of responses
      # total_responses<- d_viz %>% 
      #                   na.omit() %>%
      #                   filter(value>0|str_to_lower(value)=="true"|value=="1") %>%  
      #                   select_at(vars(data_geo_level)) %>% 
      #                   distinct() %>% 
      #                   nrow()
      # 
      # f<-c(data_geo_level,agg_geo_colnames)
      # d_total_responses_agg_level<- d_viz %>% 
      #                             na.omit() %>% 
      #                             filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
      #                             select_at(vars(f)) %>%
      #                             distinct() %>% 
      #                             group_by_at(vars(f)) %>%
      #                             summarize(total_responses_agg=n()) %>%
      #                             #mutate(freq_percentage=round(freq_count/total_responses,2)*100) %>% 
      #                             ungroup() %>% 
      #                             arrange(desc(total_responses_agg))
      # 
      # f<-c(agg_level_colnames)
      # ##BY AGGREGATION LEVEL
      # d_viz_agg<- d_viz %>% 
      #           na.omit() %>% 
      #           filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
      #           group_by_at(vars(f,"key")) %>% 
      #           summarize(freq_count=n()) %>% 
      #           left_join(d_total_responses_agg_level,by=f) %>% 
      #           mutate(freq_percentage=round(freq_count/total_responses_agg,2)*100) %>% 
      #           ungroup() %>% 
      #           arrange(desc(freq_count)) 
      # 
      # 
      # d_viz_agg_freq_count<-d_viz_agg %>% select(-freq_percentage) %>% spread(key=key,value=c(freq_count),fill=0)
      # d_viz_agg_freq_count<-d_viz_agg_freq_count %>% left_join(d_total_responses_agg_level,by=f)
      # 
      # #
      # 
      # d_viz_agg_freq_percentage<-d_viz_agg %>% select(-freq_count) %>% spread(key=key,value=c(freq_percentage),fill=0)
      # d_viz_agg_freq_percentage<-d_viz_agg_freq_percentage %>% left_join(d_total_responses_agg_level,by=f)
      # 
      # ###FOR TOTAL
      # d_viz_total<- d_viz %>% 
      #               na.omit() %>% 
      #               filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
      #               group_by_at(vars("key")) %>% 
      #               summarize(freq_count=n()) %>%
      #               mutate(freq_percentage=round(freq_count/total_responses,2)*100) %>% 
      #               ungroup() %>% 
      #               arrange(desc(freq_count)) 
      #             
      # i_colind<-which(names(d_viz_total)=="key")
      # names(d_viz_total)[i_colind]<-"variables"
      # #
      # i_colind<-which(names(d_viz_agg)=="key")
      # names(d_viz_agg)[i_colind]<-"variables"
      # 
      # ###FOR FACET TOTAL
      # 
      # f<-c(facet_col_name)
      # ##BY AGGREGATION LEVEL
      # d_viz_agg_facet<- d_viz %>% 
      #                   na.omit() %>% 
      #                   filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
      #                   group_by_at(vars(f,"key")) %>% 
      #                   summarize(freq_count=n()) %>% 
      #                   left_join(d_total_responses_agg_level,by=f) %>% 
      #                   mutate(freq_percentage=round(freq_count/total_responses_agg,2)*100) %>% 
      #                   ungroup() %>% 
      #                   arrange(desc(freq_count)) 
      # 
      # 
      # 
      # i_colind<-which(names(d_viz_facet_total)=="key")
      # names(d_viz_facet_total)[i_colind]<-"variables"
      # 
      # 
      # ###print only of it has records
      # if (nrow(d_viz_total)>0){
      #         ##Alternate method
      #         #f_count <- table(d_viz)
      #         x_i<-"variables" #column name
      #         y_i<-"freq_percentage" #column name
      #         fill_i<-"freq_percentage"
      #         title_i<- paste0(str_wrap(vn_title, width=35))
      #         facet_i<-facet_col_name
      #         #--plot--
      #         #--plot--
      #         bar_chart<-draw_barchart_percentage(d_viz_total,x_i,y_i,fill_i=y_i, title_i)
      #         
      #         bar_chart
      #         #save the viz
      #         #i_viz_save_name<-paste0(save_path,"num_records_sector_partner","_",i,".png")
      #         #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
      #         i_viz_save_name<-paste0(save_path,gsub("/","_",vn_gname),"_",i,".png")
      #         #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
      #         ##print in the file
      #         #print(bar_chart)
      #         ##print in the file
      #         doc<-body_add_gg(doc,value=bar_chart,style = "Normal")
      #         doc<-body_add_par(doc,paste0("# of records: ",total_responses), style = "Normal")
      #         
      #         ###FACETED
      #         bar_chart_facet<-draw_barchart_facet_percentage(d_viz_facet_total,x_i,y_i,fill_i=y_i, title_i,facet_i)
      #         bar_chart_facet
      #         #
      #         doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
      #         doc<-body_add_table(doc,d_total_responses_agg_level, style = "table_template")
      # }
    }
  ####--------RANK3-------------------------------------------
    if (length(col_ind)>0 && (vn_qtype=="select_one") && (vn_aggmethod=="RANK3")){
      
      agg_data_facet_select_one_rank (db,data_geo_level,agg_geo_level,facet_col_name, vn_gname)
      
      # ##frequency
      # f<-c(data_geo_level,agg_level_colnames)
      # col_ind_f<-which(names(db) %in% f)
      # #
      # col_ind_i<-which(str_detect(names(db),vn_gname))
      # 
      # d_viz_sm<-db %>% select(col_ind_f, col_ind_i)
      # #
      # d_viz<-d_viz_sm %>% gather(key="key",value="value",(length(col_ind_f)+1):ncol(d_viz_sm))
      # d_viz$key<-str_remove_all(d_viz$key,vn_gname)
      # d_viz$key<-gsub("_","/",d_viz$key)
      # 
      # ##RANK to SCORE
      # d_viz<- d_viz %>% 
      #         mutate(value=as.numeric(value)) %>% 
      #         mutate(value_score=(max(value, na.rm = TRUE)-value+1))
      #   
      # #
      # ###calculate number of responses
      # total_responses<- d_viz %>% 
      #                   na.omit() %>%
      #                   select_at(vars(data_geo_level)) %>% 
      #                   distinct() %>% 
      #                   nrow()
      # #TOTAL BY agg LEVEL
      # d_total_responses_agg_level<- d_viz %>% 
      #                               na.omit() %>% 
      #                               select_at(vars(f)) %>%
      #                               distinct() %>% 
      #                               group_by_at(vars(agg_level_colnames)) %>%
      #                               summarize(total_responses_agg=n()) %>%
      #                               #mutate(freq_percentage=round(freq_count/total_responses,2)*100) %>% 
      #                               ungroup() %>% 
      #                               arrange(desc(total_responses_agg))
      # f<-c(agg_level_colnames)
      # 
      # ###make data ready for bar chart
      # 
      # 
      # d_viz_agg<- d_viz %>% 
      #             na.omit() %>% 
      #             group_by_at(vars(f,"key")) %>% 
      #             summarize(value_score=sum(value_score)) %>% 
      #             left_join(d_total_responses_agg_level,by=f) %>% 
      #             mutate(avg_value=round(value_score/total_responses_agg,1)) %>%
      #             ungroup() %>% 
      #             arrange(desc(avg_value)) 
      # 
      # d_viz_agg_avg_score<-d_viz_agg %>% select(-value_score,total_responses_agg) %>% spread(key=key,value=c(avg_value),fill=0)
      # #
      # 
      # 
      # ###make data ready for bar chart
      # d_viz_total<- d_viz %>% 
      #               na.omit() %>% 
      #               #filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
      #               group_by_at(vars("key")) %>% 
      #               summarize(value_score=sum(value_score)) %>%
      #               mutate(avg_value=round(value_score/total_responses,1)) %>% 
      #               ungroup() %>% 
      #               arrange(desc(avg_value)) 
      # 
      # 
      # i_colind<-which(names(d_viz_total)=="key")
      # names(d_viz_total)[i_colind]<-"variables"
      # #
      # i_colind<-which(names(d_viz_agg)=="key")
      # names(d_viz_agg)[i_colind]<-"variables"
      # 
      # ###print only of it has records
      # if (nrow(d_viz_total)>0){
      #   ##Alternate method
      #   #f_count <- table(d_viz)
      #   x_i<-"variables" #column name
      #   y_i<-"avg_value" #column name
      #   fill_i<-"avg_value"
      #   title_i<- paste0(str_wrap(vn_title_full, width=50))
      #   facet_i<-facet_col_name
      #   #--plot--
      #   #--plot--
      #   bar_chart<-draw_barchart_value(d_viz_total,x_i,y_i,fill_i=y_i, title_i)
      #   
      #   bar_chart
      #   #save the viz
      #   #i_viz_save_name<-paste0(save_path,"num_records_sector_partner","_",i,".png")
      #   #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
      #   i_viz_save_name<-paste0(save_path,gsub("/","_",vn_gname),"_",i,".png")
      #   #ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
      #   ##print in the file
      #   #print(bar_chart)
      #   ##print in the file
      #   doc<-body_add_gg(doc,value=bar_chart,style = "Normal")
      #   doc<-body_add_par(doc,paste0("# of records: ",total_responses), style = "Normal")
      #   ###FACETED
      #   bar_chart_facet<-draw_barchart_facet_value(d_viz_agg,x_i,y_i,fill_i=y_i, title_i,facet_i)
      #   bar_chart_facet
      #   #
      #   doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
      #   doc<-body_add_table(doc,d_total_responses_agg_level, style = "table_template")
      #   #output the average rank responses
      #   doc<-body_add_table(doc,d_viz_agg_avg_score, style = "table_template")
      # }
    }
    
  #-----------------------------------#
} #for headers 
  #end pdf
  #dev.off()
  #invisible(NULL)
  print(doc,target = docx_charts)
  
  ####-----------------------DONE------------------------------------------------------------      
  
  
  