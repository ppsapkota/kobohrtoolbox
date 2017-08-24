'----
Developed by: Punya Prasad Sapkota
Reference: Tool developed by Olivier/REACH
Last modified: 20 Aug 2017
----'

#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
##-----data preparation---------
      #data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
      data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1035hrs.xlsx"
      
      
      print(paste0("Reading data file - ", Sys.time())) 
      data<-read_excel(data_fname,col_types ="text",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      data<-as.data.frame(data)
      #read data file to recode
      nameodk<-"./xlsform/kobo_master_v7_agg_method.xlsx"
      
      #nameodk<-"./xlsform/kobo_master_v7_protection_wcase_agg_method.xlsx"
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
      #--
      # for (kl in 1:ncol(data)){
      #   data[,kl]<-ifelse(data[,kl]=="NULL",NA,data[,kl])
      # }
###############--------SPLIT RANK SELECT ONE TO MULTIPLE------------###################
      data<-split_select_one_rank(data,dico)
      write_csv(data,gsub(".xlsx","_S1_Step01_SPLIT_RANK.csv",data_fname),na='NA')
###############------------------------------------------------------###################      
      
      
  ##---------confidence level calculation---------
      #confidence level calculation
      #-InterSector
        dc_method<-as.data.frame(data[,c("Q_1/Q_K1/Q_K1_C","Q_1/Q_K2_1/Q_K2_C","Q_1/Q_K3_1/Q_K3_C")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #
        ki_type<-as.data.frame(data[,c("Q_1/Q_K1/Q_K1_D","Q_1/Q_K2_1/Q_K2_D","Q_1/Q_K3_1/Q_K3_D")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_is<-dc_method[,4]+ki_type[,4]
        cf_level_is[is.nan(cf_level_is)]<-NA
        
      #-CCCM
        dc_method<-as.data.frame(data[,c("Q_2/Q_2k_1/Q_2k_1_c","Q_2/Q_2k_2/Q_2k_2_c","Q_2/Q_2k_3/Q_2k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_2/Q_2k_1/Q_2k_1_d","Q_2/Q_2k_2/Q_2k_2_d","Q_2/Q_2k_3/Q_2k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_cccm<-dc_method[,4]+ki_type[,4]
        cf_level_cccm[is.nan(cf_level_cccm)]<-NA
      
      #-Education
        dc_method<-as.data.frame(data[,c("Q_3/Q_3k_1/Q_3k_1_c","Q_3/Q_3k_2/Q_3k_2_c","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_3/Q_3k_1/Q_3k_1_d","Q_3/Q_3k_2/Q_3k_2_d","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_edu<-dc_method[,4]+ki_type[,4]
        cf_level_edu[is.nan(cf_level_edu)]<-NA
        
      #-FSS
        dc_method<-as.data.frame(data[,c("Q_4/Q_4k_1/Q_4k_1_c","Q_4/Q_4k_2/Q_4k_2_c","Q_4/Q_4k_3/Q_4k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_4/Q_4k_1/Q_4k_1_d","Q_4/Q_4k_2/Q_4k_2_d","Q_4/Q_4k_3/Q_4k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_fss<-dc_method[,4]+ki_type[,4]
        cf_level_fss[is.nan(cf_level_fss)]<-NA
        
      #-Health
        dc_method<-as.data.frame(data[,c("Q_5/Q_5k_1/Q_5k_1_c","Q_5/Q_5k_2/Q_5k_2_c","Q_5/Q_5k_3/Q_5k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_5/Q_5k_1/Q_5k_1_d","Q_5/Q_5k_2/Q_5k_2_d","Q_5/Q_5k_3/Q_5k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_health<-dc_method[,4]+ki_type[,4]
        cf_level_health[is.nan(cf_level_health)]<-NA
          
      #-NFI-Shelter
        dc_method<-as.data.frame(data[,c("Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_c","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_c","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_d","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_d","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_nfishelter<-dc_method[,4]+ki_type[,4]
        cf_level_nfishelter[is.nan(cf_level_nfishelter)]<-NA
        
        
      #Protection
        dc_method<-as.data.frame(data[,c("Q_7/Q_7k_1/Q_7k_1_c","Q_7/Q_7k_2/Q_7k_2_c","Q_7/Q_7k_3/Q_7k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_7/Q_7k_1/Q_7k_1_d","Q_7/Q_7k_2/Q_7k_2_d","Q_7/Q_7k_3/Q_7k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_prot<-dc_method[,4]+ki_type[,4]
        cf_level_prot[is.nan(cf_level_prot)]<-NA
        
      #ERL
        dc_method<-as.data.frame(data[,c("Q_8/Q_8k_1/Q_8k_1_c","Q_8/Q_8k_2_1/Q_8k_2_c","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_c")])
        dc_method<-ifelse(dc_method[,1:3]=="Face to face",3,ifelse(dc_method[,1:3]=="Remote",1,NA))
        dc_method<-cbind(dc_method,dc_method_score=rowMeans(dc_method[,1:3],na.rm =TRUE))
        #-
        ki_type<-as.data.frame(data[,c("Q_8/Q_8k_1/Q_8k_1_d","Q_8/Q_8k_2_1/Q_8k_2_d","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_d")])
        ki_type<-assign_metadata_score_bylabel(ki_type,dico)
        ki_type<-sapply(ki_type,as.numeric)
        ki_type<-cbind(ki_type,ki_type_score=rowMeans(ki_type[,1:3],na.rm = TRUE))
        
        cf_level_erl<-dc_method[,4]+ki_type[,4]
        cf_level_erl[is.nan(cf_level_erl)]<-NA
      #Geographic level for aggregation
      #agg_pcode<-ifelse(is.na(data[,c("Q_M/Q_M5")]),data[,c("admin4pcode")],data[,c("neighpcode")])
      #data_level<-ifelse(is.na(data[,c("Q_M/Q_M5")]),"Community","Neighbourhood")
      
      data<-cbind(
        cf_level_is,
        cf_level_cccm,
        cf_level_edu,
        cf_level_fss,
        cf_level_health,
        cf_level_nfishelter,
        cf_level_prot,
        cf_level_erl,
        data
      )
      write_csv(data,gsub(".xlsx","_S1_Step02_CL.csv",data_fname),na='NA')
#--------AGGREGATION PREPARATION------------------#
      #ODK forms
      agg_method_all<-as.data.frame(filter(survey, type!="begin_group", type!="note",type!="end_group"))
      choices<-dico
    
      #data
      db_all<-data
      agg_geo_colname<-"agg_pcode"      
        #add number of records per agg_geo_level
        d_nr<-db_all %>% 
          group_by_(agg_geo_colname) %>% 
          summarise(num_record=n()) %>% 
          ungroup()
        
      db_all<-left_join(db_all,d_nr,by=agg_geo_colname) 
      write_csv(db_all,gsub(".xlsx","_S1_Step03_COUNT_DUPLICATE.csv",data_fname))  
      
      
      
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
    
    db<-db_all
    
    db_heading<-names(db)  
  #--AGGREGATION OUTPUT FRAME------------
    #Get unique community list for the aggregation frame
    
    agg_geo_level<-distinct(as.data.frame(db[,"agg_pcode"]))  
    names(agg_geo_level)[1] <- "agg_pcode"
    
    #Prepare aggregation frame
    db_agg<-agg_geo_level
    db_agg<-left_join(db_agg,d_nr,by=agg_geo_colname)
    print(paste0("Aggregate data - Start: ",Sys.time()))  
    
    write_csv(db_agg,gsub(".xlsx","_AGG_Step00_FRAME.csv",data_fname),na='NA')
    
    
    ###############--------ORDINAL TO SCORE------------###################
    
    db<-assign_ordinal_score_bylabel(db,choices)
    write_csv(db,gsub(".xlsx","_S1_Step04_ORD_RECODING.csv",data_fname),na='NA')
    
    #Recode 'NA' to NA 
    for (kl in 1:ncol(db)){
      db[,kl]<-ifelse(db[,kl]=="NA" | db[,kl]=="" | db[,kl]=="NULL" | is.nan(db[,kl]),NA,db[,kl])
    }
    write_csv(db,gsub(".xlsx","_S1_Step04_ORD_RECODING_1.csv",data_fname),na='NA')
    ###############------------------------------------###################
    
    #Loop through each column of the main data
      #-identify question and aggregation type    
    j<-0 #exclude the first agg_pcode column
    
    while(j<ncol(db))
    #while(j<100)
    {
      j<-j+1
      #j=21 for testing
      #initiate variables
      non_agg<-0 # flag to hold for aggregation or not
      indexagg<-0 #
      ###-extract question columns  
      agg_heading<-db_heading[j]
      #check<-strsplit(agg_heading,split="/")[1] #for now don't split - check full
      check<-agg_heading
      
      #if ranking prepare check names
      if (str_detect(agg_heading,"/RANK3_SCORE") | str_detect(agg_heading,"/RANK4_SCORE")|str_detect(agg_heading,"/RANK1_SCORE")){
        #gather group name
        t_p<-str_locate(agg_heading,"/RANK")
        t_str<-substr(agg_heading,1,t_p-1)
        i_str<-which(agg_method_all$qrankgroup %in% t_str)
        #should detect more than one 
        check<-agg_method_all$gname[i_str][1]
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
      
      ### find out the heading in the agg_method table
      indexagg<-which(agg_method_all$gname%in%check)
      if(length(indexagg)==0){
          non_agg<-TRUE
          sector<-"NA"
          i_aggmethod<-"NA"
        }else{
          sector<-agg_method_all$sector[indexagg]
          i_aggmethod<-agg_method_all$aggmethod[indexagg]
          i_qrankgroup<-agg_method_all$qrankgroup[indexagg]
          i_gname<-agg_method_all$gname[indexagg]
        }
      
      if(length(sector)==0 | is.na(sector)){sector<-"NA"}
      
      ####-----DEFINE ADDITIONAL AGGREGATION METHOD-----------
      #run some checks here
      #1.aggregation method if variable is confidenec level
      if(substr(agg_heading,1,9)=="cf_level_"){
        i_aggmethod<-"AVG"
      }
      
      #2. aggregation method if variable is 'key'
      if(agg_heading=="Key" | agg_heading=="key"){
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
      if (i_aggmethod=="SCORE"){i_aggmethod<-"CONCAT_U"} #could be changed to average later/before running recoding is required
      
      #check for RANK
      
      #aggregation method for geographic level
      if (agg_heading=="agg_pcode" | agg_heading=="num_record"){
        i_aggmethod<-"DONOTHING"
      }
      
      print(paste0(nrow(db_agg), " -- ", "Running -- ",agg_heading, " -- Column:",j))
      
      #Confidence level column
       if (sector=="intersector"){
        cf_level<-db[["cf_level_is"]]
       }else if (sector=="cccm"){
         cf_level<-db[["cf_level_cccm"]]
       }else if (sector=="education"){
         cf_level<-db[["cf_level_edu"]]
       }else if (sector=="fss"){
         cf_level<-db[["cf_level_fss"]]
       }else if (sector=="health"){
         cf_level<-db[["cf_level_health"]]
       }else if (sector=="nfishelter"){
         cf_level<-db[["cf_level_nfishelter"]]
       }else if (sector=="protection"){
         cf_level<-db[["cf_level_prot"]]
       }else if (sector=="erl"){
        cf_level<-db[["cf_level_erl"]]
       }else {cf_level<-rep(1,nrow(db))} 
      
      ####---THE AGGREGATION STARTS---####
        #Average (Confidence Level Weighted)
          if (i_aggmethod=="AVG_W"|i_aggmethod=="ORD_1"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare confidence level
            i_cf_level<-conv_num(cf_level)
            #db[,j]<-recode(db[,j],'NA'=NA)
            ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],i_cf_level,conv_num(db[,j])))
            ldt$result<-apply(ldt[,2:3], 1, prod)
            d<-round2(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum),0)
            d<-data.frame(row.names(d),d)
            d<-as.data.frame(d)	
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
                names(d)<-i_heading
                #join to the expanding aggregation data
                db_agg<-left_join(db_agg,d,by=agg_geo_colname)
                rm(list=c("ldt","d","i_heading","vn_agg"))
                
        #round up for ordinal question - done for protection questions
          }else if (i_aggmethod=="ORD_1_RUP"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare confidence level
            i_cf_level<-conv_num(cf_level)
            #db[,j]<-recode(db[,j],'NA'=NA)
            ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],i_cf_level,conv_num(db[,j])))
            ldt$result<-apply(ldt[,2:3], 1, prod)
            d<-round_up(tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum))
            #d<-tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum)
            d<-data.frame(row.names(d),d)
            d<-as.data.frame(d)	
            #d[,2]<-round_up(d[,2])
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))
            
            
      #take the worst case scenario for the ordinal answers
          }else if (i_aggmethod=="ORD_1_WCASE"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare confidence level
            i_cf_level<-conv_num(cf_level)
            #db[,j]<-recode(db[,j],'NA'=NA)
            ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],i_cf_level,conv_num(db[,j])))
            ldt$result<-ldt[,3]
            d<-tapply(ldt$result,ldt[,1],max,na.rm=TRUE)
            #d<-tapply(ldt$result,ldt[,1],sum)/tapply(conv_num(ldt[,2]),ldt[,1],sum)
            d<-data.frame(row.names(d),d)
            d<-as.data.frame(d)	
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))
            
        #Average/Mean (no Weighting applied) - for example age of KI or Confidene level score
          }else if (i_aggmethod=="AVG"){
            vn_agg<-db_heading[j]
            ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],conv_num(db[,j])))
            ldt[,2]<-ifelse(ldt[,2]=="NA" | ldt[,2]=="NaN" | is.nan(ldt[,2]),NA,ldt[,2])
            d<-tapply(ldt[,2],ldt[,1],mean,na.rm=TRUE)
            d<-data.frame(row.names(d),d)
            d<-as.data.frame(d)	
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))
              
        #Concatenate responses  
          }else if (i_aggmethod=="CONCAT"){    
            d<-"a"
            vn_agg<-names(db)[j]
            ldt<- na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],db[,j]))
            # d<-as.data.frame(ldt)
            # if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            # #d<-aggregate(key~agg_pcode,d,paste0,collapse=";")
            # d<-aggregate(x=d[,2],by=list(d[,1]),paste0,collapse=";")
            # i_heading<-c(agg_geo_colname,vn_agg)
            # #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            # if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            # names(d)<-i_heading
            
            #alternatee method using data.table
            ldt<-as.data.frame(ldt)
            i_heading<-c(agg_geo_colname,vn_agg)
            if(nrow(ldt)==0){ldt<-data.frame(x="temp",y=NA)}
            names(ldt)<-i_heading
            
            ldt<-as.data.table(ldt)
            d<-ldt[,lapply(.SD, function(x) toString(x)), by = agg_geo_colname] #data.table function
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))
            
        #Admin list
          }else if (i_aggmethod=="CONCAT_U") {  
            d<-"a"
            vn_agg<-names(db)[j]
            ldt<-na.omit(data.frame(db[,which(names(db) == agg_geo_colname)],db[,j]))
            ldt<-as.data.frame(ldt)
            # d<-tapply(ldt[,2],ldt[,1], unique,na.rm=T)
            # d<-cbind(row.names(d),d)
            # d<-data.frame(d)
            
            #Alternate method using data.table
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            i_heading<-c(agg_geo_colname,vn_agg)
            if(nrow(ldt)==0){ldt<-data.frame(x="temp",y=NA)}
            names(ldt)<-i_heading
            ldt<-as.data.table(ldt)
            d<-ldt[,lapply(.SD, function(x) toString(unique(x))), by = agg_geo_colname]
            names(d)<-i_heading
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))
           
        #RANK questions - RANK3/RANK4
          }else if (i_aggmethod=="RANK1" | i_aggmethod=="RANK3" | i_aggmethod=="RANK4"){
            d<-"a"
            vn_agg<-names(db)[j]
            #find rank group
            vn_qrankgroup<-paste0(i_qrankgroup,"/",i_aggmethod,"_SCORE")
            
              if(str_detect(vn_agg,vn_qrankgroup)){
               #heading with Rank score 
                  #prepare confidence level
                  i_cf_level<-conv_num(cf_level)
                  ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],i_cf_level,conv_num(db[,j])))
                  ldt$result<-apply(ldt[,2:3], 1, prod)
                  d<-tapply(ldt$result,ldt[,1],sum)
                  d<-data.frame(row.names(d),d)
                  d<-as.data.frame(d)	
              } else{
                  ldt<- data.frame(db_agg[,which(names(db_agg)==agg_geo_colname)],rep(NA,nrow(db_agg)))  
                  d<-as.data.frame(ldt)
              }
            
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by="agg_pcode")
            rm(list=c("ldt","d","i_heading","vn_agg"))
        
        #SELECT ONE
          }else if(i_aggmethod=="SEL_1"){

            d<-"a"
            vn_agg<-names(db)[j]
            i_cf_level<-conv_num(cf_level)
            ldt<- na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],db[,j],i_cf_level))

            i_heading<-c(agg_geo_colname,vn_agg,"cf_level")
            if(nrow(ldt)==0){ldt<-data.frame(x="temp",y=NA,z=NA)}
            names(ldt)<-i_heading

            #write.csv(ldt,"./data/data_final/sel1_rank00_ldt.csv")

            ldt<-ldt %>% group_by_(agg_geo_colname,as.name(vn_agg))%>%
                         summarise(cf_level=sum(cf_level,na.rm=TRUE)) %>%
                        ungroup()
            
            #remove no answer or do not know from the list
            ldt_count<-ldt %>% group_by_(agg_geo_colname)%>%
                        summarise(n_record=n()) %>%
                        ungroup()
            
            ldt<-left_join(ldt,ldt_count,by=agg_geo_colname)
            #write_csv(ldt,"ldt_a.csv")
            ldt<-as.data.frame(ldt)
            #if count more than one and values are do not know or no answer -> change it to NA
            ldt[,2]<-ifelse(ldt[,4]>1 & (ldt[,2]=="No answer" |
                                          ldt[,2]=="dont know/no answer"|
                                          ldt[,2]=="Dont know / Unsure"|
                                          ldt[,2]=="Dont know / Unsure"|
                                            ldt[,2]=="Dont know"|
                                            ldt[,2]=="Don’t know/Unsure"|
                                            ldt[,2]=="Don’t know"|
                                            ldt[,2]=="don't know"|
                                            ldt[,2]=="Do not know/Unsure"),NA,ldt[,2])
            ldt<-na.omit(ldt)
            #write_csv(ldt,"ldt_b.csv")
            # d<-ldt %>% group_by_(agg_geo_colname)%>%
            #   mutate(rank=rank(-cf_level,ties.method = 'min')) %>%
            #   ungroup()
            #for checking
            #ldt$cf_level<-ifelse(ldt$agg_pcode=="C4278",10,ldt$cf_level)
            
            ldt<-as.data.table(ldt)
            d<-ldt[,rank:=rank(-cf_level,ties.method = 'min'), by = agg_pcode]
            #now select rank 1 only
            d<-as.data.table(filter(d,rank==1))
            d[,n_samerank := .N, by = agg_pcode]
            #change to no_consensus if two rows are ranked same
            d[d$n_samerank > 1,2]<-"No_Consensus"
            #Get UNIQUE here
            d<-unique(d[,1:2])
            db_agg<-left_join(db_agg,d,by=agg_geo_colname)
            rm(list=c("ldt","d","i_heading","vn_agg"))

            #write_csv(db_agg,paste0(j,".csv"),na='NA')
         
      #SELECT ONE - special case for protection sector request
            # For questions which have Yes, No and Sometimes
            # If only one category is chosen by all the KI s , take that category.
            # If more than one category is chosen by any number of the KIs , take ‘Sometimes’ 

            }else if(i_aggmethod=="SEL_1_UQ"){
              
              d<-"a"
              vn_agg<-names(db)[j]
              i_cf_level<-conv_num(cf_level)
              ldt<- na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],db[,j],i_cf_level))
              
              i_heading<-c(agg_geo_colname,vn_agg,"cf_level")
              if(nrow(ldt)==0){ldt<-data.frame(x="temp",y=NA,z=NA)}
              names(ldt)<-i_heading
              
              ldt<-ldt %>% group_by_(agg_geo_colname,as.name(vn_agg))%>%
                summarise(cf_level=sum(cf_level,na.rm=TRUE)) %>%
                ungroup()
              
              #remove no answer or do not know from the list
              ldt_count<-ldt %>% group_by_(agg_geo_colname)%>%
                summarise(n_record=n()) %>%
                ungroup()
              
              ldt<-left_join(ldt,ldt_count,by=agg_geo_colname)
              
              #write_csv(ldt,"./Data/100_Aggregation/sel1_uq_ldt_1.csv")
              #write_csv(ldt,"ldt_a.csv")
              ldt<-as.data.frame(ldt)
              #if count more than one and values are do not know or no answer -> change it to NA
              ldt[,2]<-ifelse(ldt[,4]>1 & (ldt[,2]=="No answer" |
                                             ldt[,2]=="dont know/no answer"|
                                             ldt[,2]=="Dont know / Unsure"|
                                             ldt[,2]=="Dont know / Unsure"|
                                             ldt[,2]=="Dont know"|
                                             ldt[,2]=="Don’t know/Unsure"|
                                             ldt[,2]=="Don’t know"|
                                             ldt[,2]=="don't know"|
                                             ldt[,2]=="Do not know/Unsure"|
                                             ldt[,2]=="dont know"),NA,ldt[,2])
              ldt<-na.omit(ldt)
              
              #count again after removing
              #remove no answer or do not know from the list
              ldt_count<-ldt %>% group_by_(agg_geo_colname)%>%
                            summarise(n_record=n()) %>%
                            ungroup()
              ldt<-left_join(ldt[1:3],ldt_count,by=agg_geo_colname)
              #if more than two records -replace by sometimes
              ldt<-as.data.frame(ldt)
              ldt[,2]<-ifelse(ldt[,4]>1,"sometimes",ldt[,2])
              ldt<-unique(ldt[,1:3])
              #write_csv(ldt,"./Data/100_Aggregation/sel1_uq_ldt_2.csv")
              #write_csv(ldt,"ldt_b.csv")
              
              ldt<-as.data.table(ldt)
              d<-ldt[,rank:=rank(-cf_level,ties.method = 'min'), by = agg_pcode]
              #now select rank 1 only
              d<-as.data.table(filter(d,rank==1))
              d[,n_samerank := .N, by = agg_pcode]
              #change to no_consensus if two rows are ranked same
              d[d$n_samerank > 1,2]<-"No_Consensus"
              #Get UNIQUE here
              d<-unique(d[,1:2])
              db_agg<-left_join(db_agg,d,by=agg_geo_colname)
              rm(list=c("ldt","d","i_heading","vn_agg"))
              
              #write_csv(db_agg,paste0(j,".csv"),na='NA')
            
               
        #SELECT multiple
          }else if (i_aggmethod=="SEL_ALL" | i_aggmethod=="SEL_3" | i_aggmethod=="SEL_4"){
            d<-"a"
            vn_agg<-names(db)[j]
            #find rank group
            vn_gname<-paste0(i_gname,"/")
            if(str_detect(vn_agg,vn_gname)){
              #prepare confidence level
              i_cf_level<-conv_num(cf_level)
              ldt<-na.omit(data.frame(db[,which(names(db)==agg_geo_colname)],i_cf_level,conv_num(db[,j])))
              ldt$result<-apply(ldt[,2:3], 1, prod)
              d<-tapply(ldt$result,ldt[,1],sum)
              d<-data.frame(row.names(d),d)
              d<-as.data.frame(d)	
            } else{
              ldt<- data.frame(db_agg[,which(names(db_agg)==agg_geo_colname)],rep(NA,nrow(db_agg)))  
              d<-as.data.frame(ldt)
            }
            
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by="agg_pcode")
            rm(list=c("ldt","d","i_heading","vn_agg"))
            
                
        #NO Aggregation method defined - simply return NA  
          }else if(i_aggmethod=="NA"){
            d<-"a"
            vn_agg<-db_heading[j]
            #prepare NA rows
            ldt<- na.omit(data.frame(db_agg[,which(names(db_agg)==agg_geo_colname)]))
            ldt$result<-NA
            d<-as.data.frame(ldt)
            i_heading<-c("agg_pcode",vn_agg)
            #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
            if(nrow(d)==0){d<-data.frame(x="temp",y=NA)}
            #
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by="agg_pcode")
            rm(list=c("ldt","d","i_heading","vn_agg"))
          
          }else if (i_aggmethod=="DONOTHING"){
            #just skip the field and don't include in the final resulting data
            
        #Everythind else return 'NA' Column
          }else {
            d<-data.frame(x="temp",y=NA)
            vn_agg<-db_heading[j]
            #prepare NA rows
            i_heading<-c("agg_pcode",vn_agg)
            names(d)<-i_heading
            #join to the expanding aggregation data
            db_agg<-left_join(db_agg,d,by="agg_pcode")
            rm(list=c("d","i_heading","vn_agg"))
          }
      
    }#while
   
      write_csv(db_agg,gsub(".xlsx","_AGG_Step01_WITH_SCORE.csv",data_fname),na='NA')  

      db_agg<-sapply(db_agg,as.character)
      db_agg<-data.frame(db_agg,stringsAsFactors=FALSE,check.names=FALSE)    
  
####---REFINE AGGREGATION RESULTS---####
        
    ###############--------ORDINAL SCORE TO VARIABLE NAME------------###################
      db_agg<-assign_ordinal_label_byscore(db_agg,choices)
      write_csv(db_agg,gsub(".xlsx","_AGG_Step02_ORD2LABEL.csv",data_fname),na='NA')
      
    ###############--------------------------------------------------###################
    
    ###############--------SELECT_MULTIPLE (ALL) SCORE TO 0/1------------###################
      db_agg<-select_all_score2zo(db_agg,agg_method_all)
      write_csv(db_agg,gsub(".xlsx","_AGG_Step03_SEL_ALL.csv",data_fname),na='NA')
      
    ###############--------------------------------------------------###################    
    
    ###############--------SELECT_MULTIPLE (THREE/FOUR) SCORE TO 0/1------------###################
      db_agg<-select_upto_n_score2zo(db_agg,agg_method_all)
      write_csv(db_agg,gsub(".xlsx","_AGG_Step04_SEL3.csv",data_fname),na='NA')
      
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
       write_csv(db_agg,gsub(".xlsx","_AGG_Step05_RANK.csv",data_fname),na='NA')
      
    ###############--------------------------------------------------###################    
    
       #Separate consideration for Areas of Origin locations
       location_aoo1<-as.data.frame(db[,c("agg_pcode","cf_level_is","Q_1/Q_1_2_A/Q_1_2_A_1/Q_1_2_A_1_1","Q_1/Q_1_2_A/Q_1_2_A_1/Q_1_2_A_1_2","Q_1/Q_1_2_A/Q_1_2_A_1/Q_1_2_A_1_3")])
       location_aoo2<-as.data.frame(db[,c("agg_pcode","cf_level_is","Q_1/Q_1_2_A/Q_1_2_A_2/Q_1_2_A_2_1","Q_1/Q_1_2_A/Q_1_2_A_2/Q_1_2_A_2_2","Q_1/Q_1_2_A/Q_1_2_A_2/Q_1_2_A_2_3")])
       location_aoo3<-as.data.frame(db[,c("agg_pcode","cf_level_is","Q_1/Q_1_2_A/Q_1_2_A_3/Q_1_2_A_3_1","Q_1/Q_1_2_A/Q_1_2_A_3/Q_1_2_A_3_2","Q_1/Q_1_2_A/Q_1_2_A_3/Q_1_2_A_3_3")])
       location_aoo4<-as.data.frame(db[,c("agg_pcode","cf_level_is","Q_1/Q_1_2_A/Q_1_2_A_4/Q_1_2_A_4_1","Q_1/Q_1_2_A/Q_1_2_A_4/Q_1_2_A_4_2","Q_1/Q_1_2_A/Q_1_2_A_4/Q_1_2_A_4_3")])
       location_aoo5<-as.data.frame(db[,c("agg_pcode","cf_level_is","Q_1/Q_1_2_A/Q_1_2_A_5/Q_1_2_A_5_1","Q_1/Q_1_2_A/Q_1_2_A_5/Q_1_2_A_5_2","Q_1/Q_1_2_A/Q_1_2_A_5/Q_1_2_A_5_3")])
       #change the header name
       names(location_aoo1)<-c("agg_pcode","cf_level","admin1name_aoo","admin2name_aoo","admin3name_aoo")
       names(location_aoo2)<-c("agg_pcode","cf_level","admin1name_aoo","admin2name_aoo","admin3name_aoo")
       names(location_aoo3)<-c("agg_pcode","cf_level","admin1name_aoo","admin2name_aoo","admin3name_aoo")
       names(location_aoo4)<-c("agg_pcode","cf_level","admin1name_aoo","admin2name_aoo","admin3name_aoo")
       names(location_aoo5)<-c("agg_pcode","cf_level","admin1name_aoo","admin2name_aoo","admin3name_aoo")
       
       location_aoo_all<-bind_rows(location_aoo1,location_aoo2,location_aoo3,location_aoo4,location_aoo5)
       location_aoo_all<-location_area_of_origin(location_aoo_all)	
       location<-unique(db[,c("agg_pcode","admin1pcode","admin2pcode","admin3pcode","admin4pcode","neighpcode")])	
       location_aoo_all<-left_join(location,location_aoo_all,by="agg_pcode")
       write_csv(location_aoo_all,gsub(".xlsx","_AGG_Step06_AoO_Location.csv",data_fname),na='NA')
       
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
       
write_csv(db_agg,gsub(".xlsx","_AGG_Step07_FINAL.csv",data_fname))
openxlsx::write.xlsx(db_agg,gsub(".xlsx","_AGG_Step07_FINAL.xlsx",data_fname),sheetName="data",row.names=FALSE)
print(paste0("Done - ", Sys.time()))    
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      

