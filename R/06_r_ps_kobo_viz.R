'----
Developed by: Punya Prasad Sapkota
Last modified: 9 August 2018
----'
rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")
#------------DEFINE Aggregation level----------------
##-----data preparation---------
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1455hrs_all_corrected_v2.xlsx"
data_fname<-"./Data/100_Aggregation/MSNA2018_data_merged.xlsx"
nameodk<-"./xlsform/ochaMSNA2018v9_master_agg_method.xlsx"
##
save_path<-"./Data/00_Coverage/Viz/"

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
      data<-read_excel(data_fname,col_types ="text",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
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
                summarize(n_value=n()) %>% 
                arrange(desc(n_value)) %>% 
                ungroup()
        
        names(d_viz)[1]<-"variables"
        
        ##Alternate method
        #f_count <- table(d_viz)
        x_i<-"variables"
        y_i<-"n_value"
        title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
        #--plot--
        p<-ggplot(data=d_viz, aes_string(x=x_i, y=y_i, fill=y_i))+
           geom_bar(stat="identity", position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda", width = 0.5)
        
        bar_chart<-p+
          theme(legend.position = "none",
                axis.title.y=element_blank(),
                axis.ticks.y=element_blank(),
                axis.text.x=element_blank(),
                axis.ticks.x=element_blank(),
                plot.background = element_rect(fill =NA,colour = NA),
                panel.border = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank()
                )+
          #geom_text(aes_string(y="n_value",label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
          geom_text(aes_string(y=0,label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
          scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
          coord_flip()+
          labs(title=title_i, y="number of records")
        
        bar_chart
        #save the viz
        i_viz_save_name<-paste0(save_path,"num_records_sector_partner","_",i,".png")
        ggsave(i_viz_save_name,plot=bar_chart,dpi=300, scale=1)#width=11.69, height=8.9, units="in",
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
  pdf(paste0(save_path,"bar_charts_select_multiple_questions1",".pdf"))
  s1_headers<-survey %>% filter(aggmethod=="SEL_ALL"|aggmethod=="SEL_3")
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
              filter(value>0) %>% 
              group_by_at(vars("key")) %>% 
              summarize(n_value=n()) %>%
              ungroup() %>% 
              arrange(desc(n_value)) 
            
      names(d_viz)[1]<-"variables"
      ###print only of it has records
      if (nrow(d_viz)>0){
              ##Alternate method
              #f_count <- table(d_viz)
              x_i<-"variables"
              y_i<-"n_value"
              title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
              #--plot--
              p<-ggplot(data=d_viz, aes_string(x=x_i, y=y_i, fill=y_i))+
                geom_bar(stat="identity", position='dodge',fill="#9ebcda",colour="#9ebcda", width = 0.8)
              
              bar_chart<-p+
                theme(legend.position = "none",
                      axis.title.y=element_blank(),
                      axis.ticks.y=element_blank(),
                      axis.text.x=element_blank(),
                      axis.ticks.x=element_blank(),
                      plot.background = element_rect(fill =NA,colour = NA),
                      panel.border = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank()
                )+
                #geom_text(aes_string(y="n_value",label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
                geom_text(aes_string(y=0,label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
                scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
                coord_flip()+
                labs(title=title_i, y="number of records")
              
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
  
  
  