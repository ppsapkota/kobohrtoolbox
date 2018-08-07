'----
Developed by: Punya Prasad Sapkota
Reference: Tool developed by Olivier/REACH
Last modified: 22 July 2018
----'
rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")
#------------DEFINE Aggregation level----------------
#start the clock
#ptm_start<-proc.time()
start_time <- as.numeric(as.numeric(Sys.time())*1000, digits=10) # place at start

flag_agg_level<-"geo"
#flag_agg_level<-"GEO_PLUS_VARS"

#List of Do not know and No answer list
dnk_no_ans_label_list<-c("No answer", "Dont know","Do not know",
                         "Don’t know", "don't know", "dont know/no answer",
                         "Don’t know/Unsure", "Dont know / Unsure", "Dont know / Unsure",
                         "Do not know/ Unsure", "Do not know / unsure", "Dont Know / Unsure",
                         "do not know  / unsure", "Do not know/Unsure")
#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
##-----data preparation---------
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1455hrs_all_corrected_v2.xlsx"
data_fname<-"./Data/100_Aggregation/MSNA2018_data_merged.xlsx"
nameodk<-"./xlsform/ochaMSNA2018v9_master_agg_method.xlsx"
#
      print(paste0("Reading data file - ", Sys.time())) 
      data<-read_excel(data_fname,col_types ="text",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      data<-as.data.frame(data)
      
      #read data file to recode
      #read ODK file choices and survey sheet
      survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
      dico<-read_excel(nameodk,sheet="choices",col_types ="text")
     
      ### create sector list
      #### depending on sector
      sector_list<-dico %>% select(sector) %>% distinct() %>% na.omit
      ### SOME preparation for aggregation
      # create sector_list table with confidence level, ki gender fields
      sector_list$f_cf_level<-paste0("cf_level_",sector_list$sector)
      sector_list$f_ki_gender<-paste0("ki_gender_",sector_list$sector)
      
      #--key
      #key<-row.names(data)
      #data<-cbind(key, data)
      #some cleanup of the data
      for (kl in 1:ncol(data)){
        data[,kl]<-ifelse(data[,kl]=="NA" | data[,kl]=="" | data[,kl]=="NULL" | is.nan(data[,kl]),NA,data[,kl])
      }
      #--
      # for (kl in 1:ncol(data)){
      #   data[,kl]<-ifelse(data[,kl]=="NULL",NA,data[,kl])
      # }
      
#############---------PROTECTION-------ALL-MEN-WOMEN##############
      # data<-protection_gender_all_transfer(data,survey)
      # write_csv(data,gsub(".xlsx","_S1_Step00_ALL_TRANSFER.csv",data_fname))
      # openxlsx::write.xlsx(data,gsub(".xlsx","_S1_Step00_ALL_TRANSFER.xlsx",data_fname),sheetName="data",row.names=FALSE)
      
###############--------SPLIT SELECT ONE TO MULTIPLE-(SEL_1_RALL--AVG_W_SEL_1_REL---------###################
      data<-split_select_one(data,dico)
      write_csv(data,gsub(".xlsx","_S1_Step01_SPLIT_SEL1.csv",data_fname),na='NA')      
      
###############--------SPLIT RANK SELECT ONE TO MULTIPLE------------###################
      ##small score (rank score / 100) is assigned to Do not know or No answers
      data<-split_select_one_rank(data,dico)
      write_csv(data,gsub(".xlsx","_S1_Step01_SPLIT_RANK.csv",data_fname),na='NA')
      
###############-------------PROTECTION-----------------------------------------###################      
      ## In the select one split variables----assign 1 to Men/Women/Boys/Girls if All is selected
      data<-split_select_one_all_transfer(data,dico)
      write_csv(data,gsub(".xlsx","_S1_Step01_SPLIT_ALL_TRANSFER.csv",data_fname),na='NA')
      
      ######---------Health----Transport Type and minutes required--------------
      ## In the select one split variables----assign value from the related column (travel minutes) for each mode.
      data<-split_select_one_related_q_value_transfer(data,dico)
      write_csv(data,gsub(".xlsx","_S1_Step01_SPLIT_ALL_RELATED_Q_VALUE_TRANSFER.csv",data_fname),na='NA')
      
  ##---------confidence level calculation---------
      #confidence level calculation
      #extract data collection method and KI type
      
      #-InterSector
       cf_fields<-c("I_S_Q/Q_K1/Q_K1_C","I_S_Q/Q_K1/Q_K1_D")
       cf_level_intersector<-calculate_confidence_level(data,cf_fields,dico) %>% 
                    rename_("cf_level_intersector"="cf_level")
       
       ki_gender_field<-c("I_S_Q/Q_K1/Q_K1_A")
       ki_gender_intersector<-select_at(data, vars(ki_gender_field))
       names(ki_gender_intersector)<-"ki_gender_intersector"
       
      #-CCCM
       cf_fields<-c("ccm_group/cfp_ccm_gr/cpf_ccm_mo","ccm_group/cfp_ccm_gr/cpf_ccm_ty")
       cf_level_cccm<-calculate_confidence_level(data,cf_fields,dico) %>% 
                      rename_("cf_level_cccm"="cf_level")
       
       ki_gender_field<-c("ccm_group/cfp_ccm_gr/cpf_ccm_ge")
       ki_gender_cccm<-select_at(data, vars(ki_gender_field))
       names(ki_gender_cccm)<-"ki_gender_cccm"
       
      #-Education
       cf_fields<-c("educationg/edu_cfp_me/edu_interv/q3_1modali", "educationg/edu_cfp_me/edu_interv/q3_2type_o")
       cf_level_edu<-calculate_confidence_level(data,cf_fields,dico) %>% 
                     rename_("cf_level_edu"="cf_level")
       
       ki_gender_field<-c("educationg/edu_cfp_me/edu_interinf/cpf_edu_ge")
       ki_gender_edu<-select_at(data, vars(ki_gender_field))
       names(ki_gender_edu)<-"ki_gender_edu"
       
       
       #-NFI-Shelter
       cf_fields<-c("nfi_group/nfi_cfp_gr/nfi_cfp_mo", "nfi_group/nfi_cfp_gr/nfi_cfp_ty")
       cf_level_nfishelter<-calculate_confidence_level(data,cf_fields,dico) %>% 
                            rename_("cf_level_nfishelter"="cf_level")
       
       ki_gender_field<-c("nfi_group/nfi_cfp_gr/nfi_cfp_ge")
       ki_gender_nfishelter<-select_at(data, vars(ki_gender_field))
       names(ki_gender_nfishelter)<-"ki_gender_nfishelter"
       
       #-FSS
       cf_fields<-c("q5food_sec/food51_com/k_5_3modal", "q5food_sec/food51_com/k_5_4typec")
       cf_level_fss<-calculate_confidence_level(data,cf_fields,dico) %>% 
                     rename_("cf_level_fss"="cf_level")
        
       ki_gender_field<-c("q5food_sec/food51_com/k_5_1gende")
       ki_gender_fss<-select_at(data, vars(ki_gender_field))
       names(ki_gender_fss)<-"ki_gender_fss"
       
       
       #-Health (medical professional)
       cf_fields<-c("q6health_s/qcomm_h_p/k_6_3modal", "q6health_s/qcomm_h_p/k_6_4typec")
       cf_level_health_mf<-calculate_confidence_level(data,cf_fields,dico) %>% 
                           rename_("cf_level_health_mf"="cf_level")
       
       ki_gender_field<-c("q6health_s/qcomm_h_p/k_6_1gende")
       ki_gender_health_mf<-select_at(data, vars(ki_gender_field))
       names(ki_gender_health_mf)<-"ki_gender_health_mf"
       
       #
       #-Health (non-medical professional)
       cf_fields<-c("q6health_s/qcomm_h_np/k_6_3_1mod", "q6health_s/qcomm_h_np/k_6_4_1typ")
       cf_level_health_non_mf<-calculate_confidence_level(data,cf_fields,dico) %>% 
                               rename_("cf_level_health_non_mf"="cf_level")
       
       ki_gender_field<-c("q6health_s/qcomm_h_np/k_6_1_1gen")
       ki_gender_health_non_mf<-select_at(data, vars(ki_gender_field))
       names(ki_gender_health_non_mf)<-"ki_gender_health_non_mf"
       
       #
       #ERL
       cf_fields<-c("q7early_re/qcommunity_fp2/k_7_3modal", "q7early_re/qcommunity_fp2/k_7_4type")
       cf_level_erl<-calculate_confidence_level(data,cf_fields,dico) %>% 
                     rename_("cf_level_erl"="cf_level")
       
       ki_gender_field<-c("q7early_re/qcommunity_fp2/k_7_1gende")
       ki_gender_erl<-select_at(data, vars(ki_gender_field))
       names(ki_gender_erl)<-"ki_gender_erl"
        
      #Protection
       cf_fields<-c("q8protecti/qcommunity_fp3/k_8_3modal", "q8protecti/qcommunity_fp3/k_8_4type_")
       cf_level_protection<-calculate_confidence_level(data,cf_fields,dico) %>% 
                            rename_("cf_level_protection"="cf_level")
      
       ki_gender_field<-c("q8protecti/qcommunity_fp3/k_8_1gende")
       ki_gender_protection<-select_at(data, vars(ki_gender_field))
       names(ki_gender_protection)<-"ki_gender_protection"
       
      #Geographic level for aggregation
      #agg_pcode<-ifelse(is.na(data[,c("Q_M/Q_M5")]),data[,c("admin4pcode")],data[,c("neighpcode")])
      #data_level<-ifelse(is.na(data[,c("Q_M/Q_M5")]),"Community","Neighbourhood")
      
      ##---data-----
      data<-cbind(
            cf_level_intersector,
            cf_level_cccm,
            cf_level_edu,
            cf_level_nfishelter,
            cf_level_fss,
            cf_level_health_mf,
            cf_level_health_non_mf,
            cf_level_erl,
            cf_level_protection,
            #ki gender
            ki_gender_intersector,
            ki_gender_cccm,
            ki_gender_edu,
            ki_gender_nfishelter,
            ki_gender_fss,
            ki_gender_health_mf,
            ki_gender_health_non_mf,
            ki_gender_erl,
            ki_gender_protection,
            data
      )
      
      write_csv(data,gsub(".xlsx","_S1_Step02_CL.csv",data_fname),na='NA')
#--------AGGREGATION PREPARATION------------------#
      #ODK forms
      agg_method_all<-as.data.frame(filter(survey, type!="begin_group", type!="note",type!="end_group"))
      choices<-dico
      #data
      db_all<-data
      ###############--------RECODE ORDINAL TO SCORE------------###################
      db_all<-assign_ordinal_score_bylabel(db_all,choices)
      write_csv(db_all,gsub(".xlsx","_S1_Step04_ORD_RECODING.csv",data_fname),na='NA')
      
      #Recode 'NA' to NA 
      for (kl in 1:ncol(db_all)){
        db_all[,kl]<-ifelse(db_all[,kl]=="NA" | db_all[,kl]=="" | db_all[,kl]=="NULL" | is.nan(db_all[,kl]),NA,db_all[,kl])
      }
      write_csv(db_all,gsub(".xlsx","_S1_Step04_ORD_RECODING_NA2NA.csv",data_fname),na='NA')
      
      ##############--------RECODE -1/-5 in Double/Integer columns to NA--------##########
      db_all<-recode_numeric_question(db_all,choices)
      write_csv(db_all,gsub(".xlsx","_S1_Step05_NUMERIC_RECODING.csv",data_fname),na='NA')
      
      ###############------------------------------------###################
      ####AGGREGATION LEVEL - geographic level and any other strata
      #agg_level_colnames<-c("agg_pcode", "I_S_Q/Q_K1/Q_K1_A")
      #agg_level_colnames<-c("agg_pcode")
    ####-------THIS BLOCK------------------------
      agg_geo_level<-c("agg_pcode")
      #agg_level_colnames<-c(agg_geo_level, "ki_gender") #ki_gender is not in the data - need to add before proceeding
      #agg_level_colnames<-agg_geo_level
      #db_all$ki_gender<-NA
      
### SOME NOTES
  # depending on aggregation level selected (flag_agg_level)- assign the sector and loop through it
  # sector<-'all' is not the best representation of what is being done in this code.
  # all means <-aggregate for all sectors without considering Ki gender. one record per community
  # for each sector - ki gender is considered in aggregation
  
      ## geo_plus_vars = aggregation at admin level plus additional variable is included in group_by
      if (flag_agg_level=="GEO_PLUS_VARS"){
        d_agg_sectors<-sector_list #separate files are written as output for each sector
      }else{
        d_agg_sectors<-sector_list
        d_agg_sectors$sector<-"all"  # aggregate for all the sectors without considering ki gender. one file as output
        d_agg_sectors<-distinct(d_agg_sectors[,c("sector")])
      }
###LOOP through the list of sectors
      print(paste0("Aggregate data - Start: ",Sys.time()))
for (i_s in 1:nrow(d_agg_sectors)){
        agg_sector<-d_agg_sectors$sector[i_s]
        ###create list of variables to include in the aggregation frame
        ###group_by is done based on the variables selected here
        if (agg_sector=="all"){
          ###if for all sectors
          ## aggregation is done at admin pcode level
          agg_level_colnames<-c(agg_geo_level)
        }else{
          ##get the col name depending on selected sector
          ###for individual sector aggregation is done at 
          ##pcode and ki gender level
          agg_vars_colnames<-c(d_agg_sectors$f_ki_gender[i_s])
          agg_level_colnames<-c(agg_geo_level,agg_vars_colnames)
        }
        ##assign data for aggregation
        db<-db_all
        db_heading<-names(db) 
  ### if sector of the current variable is not 'current sector' or metadata information
       ##set i_aggmethod<-"DROP" #drop the data column from the output
  ### ALL CODE goes in
      #agg_level_frame<-db_all %>% select_at(vars(agg_level_colnames)) %>% distinct()
      agg_level_frame<-db %>% 
                       select_at(vars(agg_level_colnames)) %>% 
                       distinct() %>% 
                       na.omit() %>% 
                       arrange_(agg_geo_level)
      #names(agg_level_frame)[1] <- "agg_pcode"
      d_nr<-db %>%
        group_by_at(vars(one_of(agg_level_colnames))) %>% 
        summarise(num_record=n()) %>% 
        ungroup()
      
      #Prepare aggregation frame
      #in case of "ki_gender" is a one field from the data, no need to process for following few steps
      #add number of records per agg_geo_level
      #--AGGREGATION OUTPUT FRAME------------
      db_agg<-agg_level_frame
      ###NOW add MALE/FEMALE KIs
      db_agg<-left_join(db_agg,d_nr,by=agg_level_colnames)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step00_FRAME_",agg_sector,".csv"),data_fname),na='NA')
      #group_by_(.dots=c("mpg","hp","wt"))
      #db_all<-left_join(db_all,d_nr,by=agg_level_colnames) 
      #write_csv(db_all,gsub(".xlsx","_S1_Step03_COUNT_DUPLICATE.csv",data_fname))  
      
    # #********A step can be incorporated here******************
    # #separate db_dupl with duplicate records
    # #separate db_no_dupl
    # #db<-db_dupl and run the aggregation process for communities where more than one records are submitted
    #   db_dupl<-filter(db_all,num_record>1)
    #   db_no_dupl<-filter(db_all,num_record==1)  
    #   write_csv(db_dupl,gsub(".xlsx","_S1_Step03_1_DUPLICATE_RECORDS.csv",data_fname))  
    #   write_csv(db_no_dupl,gsub(".xlsx","_S1_Step03_2_NO_DUPLICATE_RECORDS.csv",data_fname))  
    # #merge data (db_agg and db_no_dupl) in later stage
    #   db<-db_dupl
    
    #Loop through each column of the main data
      #-identify question and aggregation type    
    j<-0 #exclude the first agg_pcode column
    
    while(j<ncol(db))
    #while(j<1500)
    {
      j<-j+1
      #j=21 for testing
      
    ##--AGG PREP BLOCK--
      #this block of code identifies the following for each columns
      # - agg_method (aggregation method)
      # - i_sector (sector for the data)
      # - depending on the sector, column for data weighting
      # - depending on the sector, column for 
      
      #initiate variables
      non_agg<-0 # flag to hold for aggregation or not
      indexagg<-0 #
      i_aggmethod<-"NA"
      ###-extract question columns  
      agg_heading<-db_heading[j]
      #check<-strsplit(agg_heading,split="/")[1] #for now don't split - check full
      check<-agg_heading
      
      #STEP 1 - identify aggregation method i_aggmethod
      #if ranking prepare check names
      if (str_detect(agg_heading,"/RANK3_SCORE") | str_detect(agg_heading,"/RANK4_SCORE")|str_detect(agg_heading,"/RANK1_SCORE")){
        #gather group name
        t_p<-str_locate(agg_heading,"/RANK")
        t_str<-substr(agg_heading,1,t_p-1)
        i_str<-which(agg_method_all$qrankgroup %in% t_str)
        #should detect more than one 
        check<-agg_method_all$gname[i_str][1]
      }
      
      ##check if the question is split var with related
      if (str_detect(agg_heading,"/SPLIT_VAR_SEL1_REL") | str_detect(agg_heading,"/SPLIT_VAR_SEL1_RALL")){
        #gather group name
        t_p<-str_locate(agg_heading,"/SPLIT_VAR")
        t_str<-substr(agg_heading,1,t_p-1)
        i_str<-which(agg_method_all$gname==t_str)
        #should detect more than one 
        if(length(i_str)>0){
          check<-agg_method_all$gname[i_str][1]  
        }
      }
      
      
      #check if question is multiple select
      split_heading<-strsplit(agg_heading,split="/")[[1]] 
      i_str<-which(agg_method_all$name %in% split_heading)
      if(length(i_str)>0){
        if (agg_method_all$aggmethod[i_str][1]=="SEL_ALL"|
            agg_method_all$aggmethod[i_str][1]=="SEL_3" |
            agg_method_all$aggmethod[i_str][1]=="SEL_4"){
            check<-agg_method_all$gname[i_str][1]
          }
      }
      
      ### find out the heading in the agg_method table from CHECK
      indexagg<-which(agg_method_all$gname%in%check)
      if(length(indexagg)==0){
          non_agg<-TRUE
          i_sector<-"NA" #sector of the data - individual column
          i_aggmethod<-"NA"
        }else{
          i_sector<-agg_method_all$sector[indexagg]
          i_aggmethod<-agg_method_all$aggmethod[indexagg]
          i_qrankgroup<-agg_method_all$qrankgroup[indexagg]
          i_gname<-agg_method_all$gname[indexagg]
        }
      
      ###sector of the data column
      if(length(i_sector)==0 | is.na(i_sector)){i_sector<-"NA"}
      
      ####-----DEFINE ADDITIONAL AGGREGATION METHOD-----------
      # when variables are not in the xlsx form. Some additional data columns are added
      # such as confidence level, key, number of records etc.
      
      #RUN additional checks here
      #1.aggregation method if variable is confidenec level
      if(substr(agg_heading,1,9)=="cf_level_"){
        i_aggmethod<-"AVG"
      }
      #2. aggregation method if variable is 'key'
      if(str_to_upper(agg_heading)=="KEY"){
        i_aggmethod<-"CONCAT"
      }
      #3. aggregation method if variable is admin name column
      if(
        agg_heading=="data_level"|
        agg_heading=="admin1pcode"|
        agg_heading=="admin2pcode"|
        agg_heading=="admin3pcode"|
        agg_heading=="admin4pcode"|
        agg_heading=="neighpcode"
      ){i_aggmethod<-"CONCAT_U"}
      
      #for all admin levels, return unique concatenated results
      if (i_aggmethod=="ADMIN"){i_aggmethod<-"CONCAT_U"}
      #if SCORE - that is for metadata mainly - return cancatenated results
      if (i_aggmethod=="SCORE"){i_aggmethod<-"CONCAT_U"} 
      #could be changed to average later/before running recoding is required.
      #keep it like this one as confidence level had been added in the output.
      
      #aggregation method for ki_gender
      if(substr(agg_heading,1,10)=="ki_gender_"){
        #drop the field from aggregation as it is already in the aggregation frame
        i_aggmethod<-"DROP"
      }
      
      #aggregation method for geographic level
      if (agg_heading=="agg_pcode" | agg_heading=="num_record"){
        i_aggmethod<-"DROP"
      }
      
      #STEP 2 - identify sector for confidence level and ki gender columns
      if(agg_heading=="cf_level_intersector" | agg_heading=="ki_gender_intersector"){
         i_sector<-"intersector"
      }else if (agg_heading=="cf_level_cccm" | agg_heading=="ki_gender_cccm"){
         i_sector<-"cccm"
      }else if (agg_heading=="cf_level_edu" | agg_heading=="ki_gender_edu"){
        i_sector<-"education"
      }else if (agg_heading=="cf_level_nfishelter" | agg_heading=="ki_gender_nfishelter"){
        i_sector<-"nfishelter"
      }else if (agg_heading=="cf_level_fss" | agg_heading=="ki_gender_fss"){
        i_sector<-"fss"
      }else if (agg_heading=="cf_level_health_mf" | agg_heading=="ki_gender_health_mf"){
        i_sector<-"health_mf"
      }else if (agg_heading=="cf_level_health_non_mf" | agg_heading=="ki_gender_health_non_mf"){
        i_sector<-"health_non_mf"
      }else if (agg_heading=="cf_level_erl" | agg_heading=="ki_gender_erl"){
        i_sector<-"erl"
      }else if (agg_heading=="cf_level_protection" | agg_heading=="ki_gender_protection"){
        i_sector<-"protection"
      }
      
      #Confidence level and aggregation columns
       if (i_sector=="intersector"){
          vn_cf_level<-"cf_level_intersector"
          cf_level<-db[["cf_level_intersector"]]
          vn_strata<-"ki_gender_intersector"
          
       }else if (i_sector=="cccm"){
         vn_cf_level<-"cf_level_cccm"
         cf_level<-db[["cf_level_cccm"]]
         vn_strata<-"ki_gender_cccm"
         
       }else if (i_sector=="education"){
         vn_cf_level<-"cf_level_edu"
         cf_level<-db[["cf_level_edu"]]
         vn_strata<-"ki_gender_edu"
         
       }else if (i_sector=="nfishelter"){
         vn_cf_level<-"cf_level_nfishelter"
         cf_level<-db[["cf_level_nfishelter"]]
         vn_strata<-"ki_gender_nfishelter"
         
       }else if (i_sector=="fss"){
         vn_cf_level<-"cf_level_fss"
         cf_level<-db[["cf_level_fss"]]
         vn_strata<-"ki_gender_fss"
         
       }else if (i_sector=="health_mf"){
         vn_cf_level<-"cf_level_health_mf"
         cf_level<-db[["cf_level_health_mf"]]
         vn_strata<-"ki_gender_health_mf"
         
       }else if (i_sector=="health_non_mf"){
         vn_cf_level<-"cf_level_health_non_mf"
         cf_level<-db[["cf_level_health_non_mf"]]
         vn_strata<-"ki_gender_health_non_mf"
         
       }else if (i_sector=="erl"){
         vn_cf_level<-"cf_level_erl"
         cf_level<-db[["cf_level_erl"]]
         vn_strata<-"ki_gender_erl"
         
       }else if (i_sector=="protection"){
         vn_cf_level<-"cf_level_protection"
         cf_level<-db[["cf_level_protection"]]
         vn_strata<-"ki_gender_protection"
         
       }else {cf_level<-rep(1,nrow(db))} 
      
      ##check for aggregation
      # incase it is for individual sectors (ki gender based aggregation)
      # where flag_agg_level=="GEO_PLUS_VARS", drop columns for all other sectors
      # i_sector != agg_sector
      if (flag_agg_level=="GEO_PLUS_VARS" && i_sector != agg_sector && i_sector!="NA"){
          i_aggmethod<-"DROP"
      }
      
####---THE AGGREGATION STARTS----------------------------------------------####      #
      print(paste0("Rows: ",nrow(db_agg)," - Running - ","Column: ",j," - ",agg_heading," - AGGREGATION - ",i_aggmethod))
        #Average (Confidence Level Weighted)
          if (i_aggmethod=="AVG_W"|i_aggmethod=="ORD_1"){
            d<-"a"
            vn_agg<-db_heading[j]
            ##col_index of vn_agg and weight
            #vn_col_i<-length(agg_level_colnames)+1#cf_level also
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_weight,vn_agg)
            ldt<-db %>% 
              select_at(vars(f)) %>%
              na.omit() %>% 
              mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
            #find the column index for the current aggregation variable
            vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
            vn_w_col_i<-which(names(ldt)==vn_weight)
            ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
            #multiply score with the weight
            ldt$result<-ldt[,vn_w_col_i]*ldt[,vn_col_i]
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            d<-ldt %>% 
               ungroup() %>% 
               group_by_at(.vars=vars(agg_level_colnames)) %>% 
               summarise_at(vars(vn_weight,vn_agg,result),funs(sum(.,na.rm=TRUE))) %>%
               ungroup()
            #divide weight by
            d[,vn_col_i]<-round2(d$result/d[,vn_w_col_i],0)
            #ldt<-na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],i_cf_level,conv_num(db[,j])))
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            #d<-round2(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum),0)
            #d<-data.frame(row.names(d),d)
            #d<-as.data.frame(d)
            
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            f<-c(agg_level_colnames,vn_agg)
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            #
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg","vn_col_i","vn_w_col_i","vn_cf_level","vn_weight"))
                
        #round up for ordinal question - done for protection questions
          }else if (i_aggmethod=="ORD_1_RUP"){
            d<-"a"
            vn_agg<-db_heading[j]
            ##col_index of vn_agg and weight
            #vn_col_i<-length(agg_level_colnames)+1#cf_level also
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_weight,vn_agg)
            ldt<-db %>% 
              select_at(vars(f)) %>%
              na.omit() %>% 
              mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
            #find the column index for the current aggregation variable
            vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
            vn_w_col_i<-which(names(ldt)==vn_weight)
            ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
            #multiply score with the weight
            ldt$result<-ldt[,vn_w_col_i]*ldt[,vn_col_i]
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            d<-ldt %>% 
              ungroup() %>% 
              group_by_at(.vars=vars(agg_level_colnames)) %>% 
              summarise_at(vars(vn_weight,vn_agg,result),funs(sum(.,na.rm=TRUE))) %>%
              ungroup()
            #divide result by weight
            d[,vn_col_i]<-round_up(d$result/d[,vn_w_col_i])
            #ldt<-na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],i_cf_level,conv_num(db[,j])))
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            #d<-round2(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum),0)
            #d<-data.frame(row.names(d),d)
            #d<-as.data.frame(d)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            f<-c(agg_level_colnames,vn_agg)
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            #select data to merge with aggregation frame
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg","vn_col_i","vn_w_col_i","vn_cf_level","vn_weight"))
            
            ###--old code block
              # #prepare confidence level
              # i_cf_level<-conv_num(cf_level)
              # #db[,j]<-recode(db[,j],'NA'=NA)
              # ldt<-na.omit(data.frame(db[,which(names(db)%in%agg_level_colnames)],i_cf_level,conv_num(db[,j])))
              # ldt$result<-apply(ldt[,2:3], 1, prod)
              # d<-round_up(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum))
              # #d<-tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum)
              # d<-data.frame(row.names(d),d)
              # d<-as.data.frame(d)	
              # #d[,2]<-round_up(d[,2])
              # i_heading<-c("agg_pcode",vn_agg)
              # #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
              # if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
              # #
              # names(d)<-i_heading
              # #join to the expanding aggregation data
              # db_agg<-left_join(db_agg,d,by=agg_level_colnames)
              # rm(list=c("ldt","d","i_heading","vn_agg"))
              # 
            
      #take the worst case scenario for the ordinal answers
          }else if (i_aggmethod=="ORD_1_WCASE"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_weight,vn_agg)
            ldt<-db %>% 
              select_at(vars(f)) %>%
              na.omit() %>% 
              mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
            #find the column index for the current aggregation variable
            vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
            vn_w_col_i<-which(names(ldt)==vn_weight)
            ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
            #For worst case, the result column contains the main ordinal data value
            #ldt$result<-ldt[,vn_col_i] #does not actually require -adding it to make a similar flow with another code block
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            d<-ldt %>% 
              ungroup() %>% 
              group_by_at(.vars=vars(agg_level_colnames)) %>% 
              summarise_at(vars(vn_agg),funs(max(.,na.rm=TRUE))) %>%
              ungroup()
            #divide result by weight - not required - max is taken
            #d[,vn_col_i]<-round_up(d$result/d[,vn_w_col_i])
            #ldt<-na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],i_cf_level,conv_num(db[,j])))
            #ldt$result<-apply(ldt[,2:3], 1, prod)
            #d<-round2(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum),0)
            #d<-data.frame(row.names(d),d)
            #d<-as.data.frame(d)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            
            #select data to merge with aggregation frame
            f<-c(agg_level_colnames,vn_agg)
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg","vn_col_i","vn_w_col_i","vn_cf_level","vn_weight"))
            
            ##---------OLD code block-------------
            # d<-"a"
            # vn_agg<-db_heading[j]
            # #prepare confidence level
            # i_cf_level<-conv_num(cf_level)
            # #db[,j]<-recode(db[,j],'NA'=NA)
            # ldt<-na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],i_cf_level,conv_num(db[,j])))
            # ldt$result<-ldt[,3]
            # d<-tapply(ldt$result,ldt[,1],max,na.rm=TRUE)
            # #d<-tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum)
            # d<-data.frame(row.names(d),d)
            # d<-as.data.frame(d)	
            # i_heading<-c("agg_pcode",vn_agg)
            # #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            # if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            # #
            # names(d)<-i_heading
            # #join to the expanding aggregation data
            # db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            # rm(list=c("ldt","d","i_heading","vn_agg"))
            
        #Average/Mean (no Weighting applied) - for example age of KI or Confidene level score
          }else if (i_aggmethod=="AVG"){
            vn_agg<-db_heading[j]
            vn_col_i<-length(agg_level_colnames)+1
            #
            f<-c(agg_level_colnames,vn_agg)
            ldt<-db %>% 
                 select_at(vars(f)) %>%
                 na.omit() %>% 
                 mutate_at(.vars=vars(vn_agg),.funs=funs(as.numeric(as.character(.))))
            
            #ldt<-data.frame(db[,which(names(db)%in%agg_level_colnames)],conv_num(db[,j]))
            #ldt<-na.omit(ldt)
            #
            ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
            #
            d<-ldt %>% 
               ungroup() %>% 
               group_by_at(.vars=vars(agg_level_colnames)) %>% 
               summarise_at(vars(vn_agg),funs(mean(.,na.rm=TRUE))) %>% 
               ungroup()
            
            #C4071
            #c_i_agg<-which(names(ldt)%in%agg_level_colnames)
            #d<-tapply(ldt[,c_i_vn],list(ldt[,1],ldt[,2]),mean,na.rm=TRUE)
            #
            #d<-data.frame(row.names(d),d)
            #d<-as.data.frame(d)	
            f<-c(agg_level_colnames,vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg","vn_col_i"))
              
        #Concatenate responses  
          }else if (i_aggmethod=="CONCAT"){    
            d<-"a"
            vn_agg<-names(db)[j]
            #prepare confidence level for weight
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_agg)
            ldt<-db %>% select_at(vars(f)) %>% na.omit() 
            ##concat function
            d<-ldt %>% 
               ungroup() %>% 
               group_by_at(.vars=vars(agg_level_colnames)) %>% 
               summarise_at(vars(vn_agg),funs(paste0(.,collapse = " | "))) %>% 
              ungroup()
            
            #dummy dataframe if there is no records
            f<-c(agg_level_colnames,vn_agg)
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            ##select data to merge with aggregation frame
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg"))
            
            #ldt<-as.data.table(ldt)
            #d<-ldt[,lapply(.SD, function(x) toString(x)), by = agg_level_colnames] #data.table function
            
        #Admin list
          }else if (i_aggmethod=="CONCAT_U") {  
            d<-"a"
            vn_agg<-names(db)[j]
            #prepare confidence level for weight
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_agg)
            ldt<-db %>% select_at(vars(f)) %>% na.omit() 
            ##concat function
            d<-ldt %>% 
              ungroup() %>% 
              group_by_at(.vars=vars(agg_level_colnames)) %>% 
              distinct() %>% 
              summarise_at(vars(vn_agg),funs(paste0(.,collapse = " | "))) %>% 
              ungroup()
            
            #dummy dataframe if there is no records
            f<-c(agg_level_colnames,vn_agg)
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            #select data to merge with aggregation frame
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg"))
            
           
        #RANK questions - RANK3/RANK4
          }else if (i_aggmethod=="RANK1" | i_aggmethod=="RANK3" | i_aggmethod=="RANK4"){
            d<-"a"
            vn_agg<-names(db)[j]
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            #find rank group
            vn_qrankgroup<-paste0(i_qrankgroup,"/",i_aggmethod,"_SCORE")
            if(str_detect(vn_agg,vn_qrankgroup)){
               #heading with Rank score 
                
                #i_vn_cf_level<-vn_cf_level
                f<-c(agg_level_colnames,vn_weight,vn_agg)
                ldt<-db %>% 
                  select_at(vars(f)) %>%
                  na.omit() %>% 
                  mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
                #find the column index for the current aggregation variable
                vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
                vn_w_col_i<-which(names(ldt)==vn_weight)
                ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
                #multiply score with the weight
                ldt$result<-ldt[,vn_w_col_i]*ldt[,vn_col_i] #step included to check - can be avoided
                ldt[,vn_col_i]<-ldt[,vn_w_col_i]*ldt[,vn_col_i]
                #ldt$result<-apply(ldt[,2:3], 1, prod)
                d<-ldt %>% 
                  ungroup() %>% 
                  group_by_at(.vars=vars(agg_level_colnames)) %>% 
                  summarise_at(vars(vn_agg),funs(sum(.,na.rm=TRUE))) %>%
                  ungroup()
                  # i_cf_level<-conv_num(cf_level)
                  # ldt<-na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],i_cf_level,conv_num(db[,j])))
                  # ldt$result<-apply(ldt[,2:3], 1, prod)
                  # d<-tapply(ldt$result,ldt[,1],sum)
                  # d<-data.frame(row.names(d),d)
                  # d<-as.data.frame(d)	
              } else{
                    ###replace everything by NA - create empty dataframe
                    d <- get_empty_dataframe(db,c(agg_level_colnames, vn_agg))
                    #ldt<- data.frame(db_agg[,which(names(db_agg)==agg_level_colnames)],rep(NA,nrow(db_agg)))  
                    #d<-as.data.frame(ldt)
              }
            #dummy dataframe if there is no records
            #i_heading<-c(agg_level_colnames, vn_agg)
            #select data to merge with aggregation frame
            f<-c(agg_level_colnames,vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            #
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("d","f","vn_agg","vn_weight"))
        
        #SELECT ONE
          }else if(i_aggmethod=="SEL_1"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            #i_vn_cf_level<-vn_cf_level
            f<-c(agg_level_colnames,vn_agg,vn_weight)
            ldt<-db %>% 
              select_at(vars(f)) %>%
              na.omit() %>% 
              mutate_at(.vars=vars(vn_weight),.funs=funs(as.numeric(as.character(.)))) 
            #find the column index for the current aggregation variable
            vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
            vn_w_col_i<-which(names(ldt)==vn_weight)
            #ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
            #-----------------------------------------------#
            #d<-"a"
            #vn_agg<-names(db)[j]
            #i_cf_level<-conv_num(cf_level)
            #ldt<- na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],db[,j],i_cf_level))
            i_heading<-c(agg_level_colnames,vn_agg,vn_weight)
            if(nrow(ldt)==0){
                ldt <- get_empty_dataframe(db, i_heading)
            }
            #write.csv(ldt,"./data/data_final/sel1_rank00_ldt.csv")
            ldt<-ldt %>% ungroup() %>% 
              group_by_at(.vars=vars(agg_level_colnames,vn_agg)) %>% 
              summarise_at(vars(vn_weight),funs(sum(.,na.rm=TRUE))) %>%
              ungroup()
            # ldt<-ldt %>% group_by_(agg_level_colnames,as.name(vn_agg))%>%
            #              summarise(cf_level=sum(cf_level,na.rm=TRUE)) %>%
            #              ungroup()
            #remove no answer or do not know from the list
            ldt_count<-ldt %>% group_by_at(agg_level_colnames)%>%
                        summarise(n_record=n()) %>%
                        ungroup()
            
            ldt<-left_join(ldt,ldt_count,by=agg_level_colnames)
            #write_csv(ldt,"ldt_a.csv")
            ldt<-as.data.frame(ldt)
            #if count more than one and values are do not know or no answer -> change it to NA
            l_col_i<-which(names(ldt)=="n_record")
            # ldt[,vn_col_i]<-ifelse(ldt[,l_col_i]>1 & (ldt[,vn_col_i]=="No answer" |
            #                                           ldt[,vn_col_i]=="not sure / do not know"|
            #                                           ldt[,vn_col_i]=="Not sure/do not know"|
            #                                           ldt[,vn_col_i]=="Unsure"|
            #                                           ldt[,vn_col_i]=="Unsure / no answer"|
            #                                           ldt[,vn_col_i]=="Do not know"|
            #                                           ldt[,vn_col_i]=="Dont know"|
            #                                           ldt[,vn_col_i]=="Don’t know"|
            #                                           ldt[,vn_col_i]=="don't know"|
            #                                           ldt[,vn_col_i]=="dont know/no answer"|
            #                                           ldt[,vn_col_i]=="Don’t know/Unsure"|
            #                                           ldt[,vn_col_i]=="Dont know / Unsure"|
            #                                           ldt[,vn_col_i]=="Dont know / Unsure"|
            #                                           ldt[,vn_col_i]=="Do not know/ Unsure"|
            #                                           ldt[,vn_col_i]=="Do not know / unsure"|
            #                                           ldt[,vn_col_i]=="Dont Know / Unsure"|
            #                                           ldt[,vn_col_i]=="do not know  / unsure"|
            #                                           ldt[,vn_col_i]=="Do not know/Unsure"),NA,ldt[,vn_col_i])
            
            ldt[,vn_col_i]<-ifelse(ldt[,l_col_i]>1 & (ldt[,vn_col_i] %in% dnk_no_ans_label_list),NA,ldt[,vn_col_i])
            #Do not know
            #No answer
            #Do not know/ Unsure
            #Do not know / unsure
            #Dont Know / Unsure
            #do not know  / unsure
            
            ##--2018 list--
            #Do not know
            #do not know  / unsure
            #Do not know / unsure
            #Do not know/ Unsure
            #Don’t know
            #Dont Know
            #Dont Know / Unsure
            #No answer
            #not sure / do not know
            #Not sure/do not know
            #Unsure
            #Unsure / no answer
            
            ldt<-na.omit(ldt)
            #write_csv(ldt,"ldt_b.csv")
            # d<-ldt %>% group_by_(agg_level_colnames)%>%
            #   mutate(rank=rank(-cf_level,ties.method = 'min')) %>%
            #   ungroup()
            #for checking
            #ldt$cf_level<-ifelse(ldt$agg_pcode=="C4278",10,ldt$cf_level)
            
            ##RANK the data [- field name]
            
            d<-ldt %>% ungroup() %>% 
               group_by_at(.vars=vars(agg_level_colnames)) %>% 
               mutate_at(vars(vn_weight),funs(rank=rank(-.,ties.method = 'min'))) %>%
               ungroup()
            ##now select rank 1 only
            d<-filter(d,rank==1) %>% 
              group_by_at(.vars=vars(agg_level_colnames)) %>% 
              mutate_at(vars("rank"),funs(n_samerank=n())) %>%
              ungroup()
            #ldt<-as.data.table(ldt)
            #d<-ldt[,rank:=rank(-cf_level,ties.method = 'min'), by = agg_pcode]
            #now select rank 1 only
            #d<-as.data.table(filter(d,rank==1))
            #d[,n_samerank := .N, by = agg_pcode]
            #change to no_consensus if two rows are ranked same
            d[d$n_samerank>1,c(vn_agg)]<-"No_Consensus"
            #Get UNIQUE here
            f<-c(agg_level_colnames,vn_agg)
            d<-d %>% select_at(vars(f)) %>% distinct()
            #d<-unique(d[,c(agg_level_colnames,vn_agg)])
            #JUST INCASE
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, f)
            }
            #
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("ldt","d","f","vn_agg","vn_col_i","vn_w_col_i","vn_cf_level","vn_weight"))

            #write_csv(db_agg,paste0(j,".csv"),na='NA')
         
      #SELECT ONE - special case for protection sector request
            # For questions which have Yes, No and Sometimes
            # If only one category is chosen by all the KIs , take that category.
            # If more than one category is chosen by any number of the KIs , take ‘Sometimes’ 

            }else if(i_aggmethod=="SEL_1_UQ"){
              
              d<-"a"
              vn_agg<-db_heading[j]
              #prepare confidence level for weight
              vn_weight<-vn_cf_level
              d_weight_i<-conv_num(cf_level)
              #i_vn_cf_level<-vn_cf_level
              f<-c(agg_level_colnames,vn_agg,vn_weight)
              ldt<-db %>% 
                select_at(vars(f)) %>%
                na.omit() %>% 
                mutate_at(.vars=vars(vn_weight),.funs=funs(as.numeric(as.character(.)))) 
              #find the column index for the current aggregation variable
              vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
              vn_w_col_i<-which(names(ldt)==vn_weight)
              #ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
              #-----------------------------------------------#
              #d<-"a"
              #vn_agg<-names(db)[j]
              #i_cf_level<-conv_num(cf_level)
              #ldt<- na.omit(data.frame(db[,which(names(db)==agg_level_colnames)],db[,j],i_cf_level))
              i_heading<-c(agg_level_colnames,vn_agg,vn_weight)
              if(nrow(ldt)==0){
                ldt <- get_empty_dataframe(db, i_heading)
              }
              #write.csv(ldt,"./data/data_final/sel1_rank00_ldt.csv")
              ldt<-ldt %>% ungroup() %>% 
                group_by_at(.vars=vars(agg_level_colnames,vn_agg)) %>% 
                summarise_at(vars(vn_weight),funs(sum(.,na.rm=TRUE))) %>%
                ungroup()
              # ldt<-ldt %>% group_by_(agg_level_colnames,as.name(vn_agg))%>%
              #              summarise(cf_level=sum(cf_level,na.rm=TRUE)) %>%
              #              ungroup()
              #remove no answer or do not know from the list
              ldt_count<-ldt %>% group_by_at(agg_level_colnames)%>%
                summarise(n_record=n()) %>%
                ungroup()
              
              ldt<-left_join(ldt,ldt_count,by=agg_level_colnames)
              #write_csv(ldt,"ldt_a.csv")
              ldt<-as.data.frame(ldt)
              #if count more than one and values are do not know or no answer -> change it to NA
              l_col_i<-which(names(ldt)=="n_record")
              
              
              # ldt[,vn_col_i]<-ifelse(ldt[,l_col_i]>1 & (ldt[,vn_col_i]=="No answer" |
              #                                           ldt[,vn_col_i]=="Dont know"|
              #                                           ldt[,vn_col_i]=="Do not know"|
              #                                           ldt[,vn_col_i]=="Don’t know"|
              #                                           ldt[,vn_col_i]=="don't know"|
              #                                           ldt[,vn_col_i]=="dont know/no answer"|
              #                                           ldt[,vn_col_i]=="Don’t know/Unsure"|
              #                                           ldt[,vn_col_i]=="Dont know / Unsure"|
              #                                           ldt[,vn_col_i]=="Dont know / Unsure"|
              #                                           ldt[,vn_col_i]=="Do not know/ Unsure"|
              #                                           ldt[,vn_col_i]=="Do not know / unsure"|
              #                                           ldt[,vn_col_i]=="Dont Know / Unsure"|
              #                                           ldt[,vn_col_i]=="do not know  / unsure"|
              #                                           ldt[,vn_col_i]=="Do not know/Unsure"),NA,ldt[,vn_col_i])
              
              ldt[,vn_col_i]<-ifelse(ldt[,l_col_i]>1 & (ldt[,vn_col_i] %in% dnk_no_ans_label_list),NA,ldt[,vn_col_i])
              ldt<-na.omit(ldt)
              #count again after removing - checking whether more than one accepted answers are there or not
              ldt %>% group_by_at(vars(agg_level_colnames))%>%
                       summarise(n_record=n()) %>%
                       ungroup()
              ##---if more than one replace by sometimes-------------------
              ldt[,vn_col_i]<-ifelse(ldt[,l_col_i]>1,"sometimes",ldt[,vn_col_i])
               #Get UNIQUE here
               f<-c(agg_level_colnames,vn_agg, vn_weight)
               ldt<-ldt %>% select_at(vars(f)) %>% distinct()
               
              #RANK
               ##RANK the data (- for larger value to small rank number)
               d<-ldt %>% ungroup() %>% 
                 group_by_at(.vars=vars(agg_level_colnames)) %>% 
                 mutate_at(vars(vn_weight),funs(rank=rank(-.,ties.method = 'min'))) %>%
                 ungroup()
               ##now select rank 1 only
               d<-filter(d,rank==1) %>% 
                 group_by_at(.vars=vars(agg_level_colnames)) %>% 
                 mutate_at(vars("rank"),funs(n_samerank=n())) %>%
                 ungroup()
               #change to no_consensus if two rows are ranked same
               d[d$n_samerank>1,c(vn_agg)]<-"No_Consensus"
               #Get UNIQUE here
               f<-c(agg_level_colnames,vn_agg)
               d<-d %>% select_at(vars(f)) %>% distinct()
               #d<-unique(d[,c(agg_level_colnames,vn_agg)])
               ##CHECK for empty dataframe
               if(nrow(d)==0){
                 d <- get_empty_dataframe(db, f)
               }
               
               db_agg<-left_join(db_agg,d,by=agg_level_colnames)
               rm(list=c("ldt","d","f","vn_agg","vn_col_i","vn_w_col_i","vn_cf_level","vn_weight"))
               
               
    #SELECT multiple
    ##multiply 1 or 0 by weight. SUM them and rank later in the process to get SEL ALL or SEL 3 etc
          }else if (i_aggmethod=="SEL_ALL" | i_aggmethod=="SEL_3" | i_aggmethod=="SEL_4" | i_aggmethod=="SEL1_RALL"){
            d<-"a"
            vn_agg<-names(db)[j]
            #prepare confidence level for weight
            vn_weight<-vn_cf_level
            d_weight_i<-conv_num(cf_level)
            
            #find rank group
            vn_gname<-paste0(i_gname,"/")
            if(str_detect(vn_agg,vn_gname)){
              #i_vn_cf_level<-vn_cf_level
              f<-c(agg_level_colnames,vn_weight,vn_agg)
              ldt<-db %>% 
                select_at(vars(f)) %>%
                na.omit() %>% 
                mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
              #find the column index for the current aggregation variable
              vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
              vn_w_col_i<-which(names(ldt)==vn_weight)
              ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
              #multiply score with the weight
              ldt$result<-ldt[,vn_w_col_i]*ldt[,vn_col_i] #step included to check - can be avoided
              ldt[,vn_col_i]<-ldt[,vn_w_col_i]*ldt[,vn_col_i]
              ##sum the product
              d<-ldt %>% 
                 ungroup() %>% 
                 group_by_at(.vars=vars(agg_level_colnames)) %>% 
                  summarise_at(vars(vn_agg),funs(sum(.,na.rm=TRUE))) %>%
                  ungroup()
            } else{
              ###replace everything by NA - create empty dataframe
              d<-get_empty_dataframe(db,c(agg_level_colnames,vn_agg))
            }
            #dummy dataframe if there is no records
            i_heading<-c(agg_level_colnames, vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){
              d <- get_empty_dataframe(db, i_heading)
            }
            #select data to merge with aggregation frame
            f<-c(agg_level_colnames,vn_agg)
            d<-select_at(d, vars(f))
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("d","f","vn_agg","vn_weight"))
  ### weighted average      
          }else if (i_aggmethod=="SEL1_REL"){
              d<-"a"
              vn_agg<-names(db)[j]
              vn_weight<-vn_cf_level
              d_weight_i<-conv_num(cf_level)
              #find rank group
              vn_gname<-paste0(i_gname,"/")
              if(str_detect(vn_agg,vn_gname)){
                    #i_vn_cf_level<-vn_cf_level
                    f<-c(agg_level_colnames,vn_weight,vn_agg)
                    ldt<-db %>% 
                      select_at(vars(f)) %>%
                      na.omit() %>% 
                      mutate_at(.vars=vars(vn_weight,vn_agg),.funs=funs(as.numeric(as.character(.)))) 
                    #find the column index for the current aggregation variable
                    vn_col_i<-which(names(ldt)==vn_agg)#cf_level also
                    vn_w_col_i<-which(names(ldt)==vn_weight)
                    ldt[,vn_col_i]<-ifelse(ldt[,vn_col_i]=="NA" | ldt[,vn_col_i]=="NaN" | is.nan(ldt[,vn_col_i]),NA,ldt[,vn_col_i])
                    #multiply score with the weight
                    ldt$result<-ldt[,vn_w_col_i]*ldt[,vn_col_i]
                    #ldt$result<-apply(ldt[,2:3], 1, prod)
                    d<-ldt %>% 
                      ungroup() %>% 
                      group_by_at(.vars=vars(agg_level_colnames)) %>% 
                      summarise_at(vars(vn_weight,vn_agg,result),funs(sum(.,na.rm=TRUE))) %>%
                      ungroup()
                    #divide weight by
                    d[,vn_col_i]<-round2(d$result/d[,vn_w_col_i],0)
              
              }else{
                ###replace everything by NA - create empty dataframe
                d<-get_empty_dataframe(db,c(agg_level_colnames,vn_agg))
              }
              #dummy dataframe if there is no records
              f<-c(agg_level_colnames, vn_agg)
              #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
              if(nrow(d)==0){
                d <- get_empty_dataframe(db, f)
              }
              #select data to merge with aggregation frame
              #f<-c(agg_level_colnames,vn_agg)
              d<-select_at(d, vars(f))
              #join to the expanding aggregation data
              db_agg<-left_join(db_agg,d,by=agg_level_colnames)
              rm(list=c("d","f","vn_agg","vn_weight"))
              
    #NO Aggregation method defined - simply return NA  
           }else if(i_aggmethod=="NA"){
            d<-"a"
            vn_agg<-db_heading[j]
            #i_vn_cf_level<-vn_cf_level
            d<-get_empty_dataframe(db,c(agg_level_colnames,vn_agg))
            
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("d","vn_agg"))
            
          }else if (i_aggmethod=="DROP"){
            #just skip the field and don't include in the final resulting data
        #Everythind else return 'NA' Column
          }else {
            vn_agg<-db_heading[j]
            #i_vn_cf_level<-vn_cf_level
            d<-get_empty_dataframe(db,c(agg_level_colnames,vn_agg))
            
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_level_colnames)
            rm(list=c("d","vn_agg"))
            
          }
      
    }#while ### LOOP through each column in the data
   
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step01_WITH_SCORE_",agg_sector,".csv"),data_fname),na='NA')  

      db_agg<-sapply(db_agg,as.character)
      db_agg<-data.frame(db_agg,stringsAsFactors=FALSE,check.names=FALSE)    
  
####---REFINE AGGREGATION RESULTS---####
        
    ###############--------ORDINAL SCORE TO VARIABLE NAME------------###################
      db_agg<-assign_ordinal_label_byscore(db_agg,choices)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step02_ORD2LABEL_",agg_sector,".csv"),data_fname),na='NA')
      
    ###############--------------------------------------------------###################
    
      ###############--------ORDINAL REPLACE NAs by Do not know or No answer------------###################
      db_agg<-assign_ordinal_NAs_back2var(db_agg,choices,data,agg_level_colnames)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step02_ORD2LABEL_",agg_sector,".csv"),data_fname),na='NA')
      ###############--------------------------------------------------###################  
      
      
    ###############--------SELECT_MULTIPLE (ALL) SCORE TO 0/1------------###################
      db_agg<-select_all_score2zo(db_agg,agg_method_all)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step03_SEL_ALL_",agg_sector,".csv"),data_fname),na='NA')
      
    ###############--------------------------------------------------###################    
    
      ###############--------SELECT_ONE SPLIT AND RETAIL ALL SCORE TO 0/1------------###################
      db_agg<-select_one_retain_all_score2zo(db_agg,agg_method_all)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step03_SEL_ALL_",agg_sector,".csv"),data_fname),na='NA')
      
      ###############--------------------------------------------------###################    
      
      
      
    ###############--------SELECT_MULTIPLE (THREE/FOUR) SCORE TO 0/1------------###################
      db_agg<-select_upto_n_score2zo(db_agg,agg_method_all)
      write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step04_SEL3_",agg_sector,".csv"),data_fname),na='NA')
      
    ###############--------------------------------------------------###################
      #merge here before recoding ranks
      # db_no_dupl<-sapply(db_no_dupl,as.character)
      # db_no_dupl<-data.frame(db_no_dupl,stringsAsFactors=FALSE,check.names=FALSE)  
      # #
      # db_agg<-sapply(db_agg,as.character)
      # db_agg<-data.frame(db_agg,stringsAsFactors=FALSE,check.names=FALSE)   
      # #
      # db_agg<-bind_rows(db_agg,db_no_dupl)
    
    ###############--------RANK SCORE TO 0/1------------###################
       db_agg<-select_rank_score2rank(db_agg,agg_method_all)
       write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step05_RANK_",agg_sector,".csv"),data_fname),na='NA')
      
    ###############--------------------------------------------------###################    
       
       print(paste0("Some clean up - ", Sys.time())) 
       #output NA in the result
       db_agg[is.na(db_agg)] <- 'NA'
       # 
       # #Q_4/Q_4_9/Q_4_9_1_1	;	Q_4/Q_4_9/Q_4_9_2_1
       # db_agg[,which(names(db_agg)=="Q_4/Q_4_9/Q_4_9_1_1")]<-"NA"
       # db_agg[,which(names(db_agg)=="Q_4/Q_4_9/Q_4_9_2_1")]<-"NA"
       
       #some cleanup
       for (kl in 1:ncol(db_agg)){
         db_agg[,kl]<-ifelse(db_agg[,kl]==""|is.na(db_agg[,kl])|is.nan(db_agg[,kl]),"NA",db_agg[,kl])
       }
       print(paste0("Writing final results - ", Sys.time())) 
       
    write_csv(db_agg,gsub(".xlsx",paste0("_AGG_Step07_FINAL_",agg_sector,".csv"),data_fname))
    openxlsx::write.xlsx(db_agg,gsub(".xlsx",paste0("_AGG_Step07_FINAL_",agg_sector,".xlsx"),data_fname),sheetName="data",row.names=FALSE)
    print(paste0("Done - ", Sys.time()))    
      
} ##### lopping through each sector in the list    

      
end_time <- as.numeric(as.numeric(Sys.time())*1000, digits=10) # place at end
      
total_time<-(end_time - start_time)/(1000*60)   # run time (in milliseconds)      
      
print (paste0("ALL DONE - Time taken : ",total_time))     
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      

