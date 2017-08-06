'----
Developed by: Punya Prasad Sapkota
Reference: Tool developed by Olivier/REACH
Last modified: 5 Aug 2017
----'

#4-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
##-----data preparation---------
      data_fname<-"./data/data_final/multisector_assessment_raw_data_all_recode.xlsx"
      data<-read_excel(data_fname,col_types ="text",na='NA')
      #data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
      data<-as.data.frame(data)
      #read data file to recode
      nameodk<-"./xlsform/kobo_master_v7_agg_method.xlsx"
      #read ODK file choices and survey sheet
      survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
      dico<-read_excel(nameodk,sheet="choices",col_types ="text")
      
      #Some clean up label
      ind<-which(names(dico)=="label")
      dico[,ind]<-str_replace_all(dico[,ind],c('\\.'='_','\\*'='','\\:'='','/'='_','\\?'=''))
      
      #--key
      key<-row.names(data)
      data<-cbind(key, data)
      #some cleanup of the data
      for (kl in 1:ncol(data)){
        data[,kl]<-ifelse(data[,kl]=="NA" | data[,kl]=="" | data[,kl]=="NULL" | is.nan(data[,kl]),NA,data[,kl])
      }
      #--
      # for (kl in 1:ncol(data)){
      #   data[,kl]<-ifelse(data[,kl]=="NULL",NA,data[,kl])
      # }
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
      
      #Geographic level for aggregation
      agg_pcode<-ifelse(is.na(data[,c("Q_M/Q_M5")]),data[,c("admin4pcode")],data[,c("neighpcode")])
      data_level<-ifelse(is.na(data[,c("Q_M/Q_M5")]),"Community","Neighbourhood")
      
      data<-cbind(
        agg_pcode,
        cf_level_is,
        cf_level_cccm,
        cf_level_edu,
        cf_level_fss,
        cf_level_health,
        cf_level_nfishelter,
        cf_level_prot,
        cf_level_erl,
        data_level,
        data
      )
      write_csv(data,gsub(".xlsx","_CL.csv",data_fname),na='NA')
#-----------Get the unique locations for AGGREGATION FRAME----------------------------------------
    agg_geo_colname<-"agg_pcode"
    agg_geo_level<-distinct(as.data.frame(data[,"agg_pcode"]))  
    names(agg_geo_level)[1] <- "agg_pcode"
    db_agg<-agg_geo_level  
    #add number of records per agg_geo_level
    d<-db %>% 
      group_by_(agg_geo_colname) %>% 
      summarise(num_record=n()) %>% 
      ungroup()
      
    db_agg<-left_join(db_agg,d,by=agg_geo_colname)
    print(paste0("\nAggregate data - Start: ",Sys.time()))  
    
    
    
    
    
    #ODK forms
    agg_method_all<-survey
    #data
    db<-data
    db_heading<-names(db)
    #Loop through each column of the main data
      #-identify question and aggregation type    
    j<-1 #exclude the first agg_pcode column
    
    while(j<ncol(db))
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
      ### find out the heading in the agg_method table
      indexagg<-which(agg_method_all$gname%in%check)
      if(length(indexagg)==0){
          non_agg<-TRUE
          sector<-"NA"
          i_aggmethod<-"NA"
        }else{
          sector<-agg_method_all$sector[indexagg]
          i_aggmethod<-agg_method_all$aggmethod[indexagg]
        }
      
      if(length(sector)==0 | is.na(sector)){sector<-"NA"}
      
      ####-----DEFINE ADDITIONAL AGGREGATION METHOD-----------
      #run some checks here
      #1.aggregation method if variable is confidenec level
      if(substr(agg_heading,1,9)=="cf_level_"){
        i_aggmethod<-"AVG"
      }
      
      #2. aggregation method if variable is 'key'
      if(agg_heading=="key"){
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
      
      #aggregation method for geographic level
      if (agg_heading=="agg_pcode"){
        i_aggmethod<-"DONOTHING"
      }
      
      
      print(paste0("Running - ",agg_heading))
      
      #Confidence level column
       if (sector=="intersector"){
        cf_level<-cf_level_is
       }else if (sector=="cccm"){
         cf_level<-cf_level_cccm
       }else if (sector=="education"){
         cf_level<-cf_level_edu
       }else if (sector=="fss"){
         cf_level<-cf_level_fss
       }else if (sector=="health"){
         cf_level<-cf_level_health
       }else if (sector=="nfishelter"){
         cf_level<-cf_level_nfishelter
       }else if (sector=="protection"){
         cf_level<-cf_level_prot
       }else if (sector=="erl"){
        cf_level<-cf_level_erl
       }else {cf_level<-rep(1,nrow(db))} 
      
      
      #-------to do---------
          #SEL_1
          #ORD_1
          #RANK3
      #---------------------
      
      
      
      #NOW - THE AGGREGATION STARTS
        #Average (Confidence Level Weighted)
          if (i_aggmethod=="AVG_W"){
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
    
   
    
    
    
    write_csv(db_agg,gsub(".xlsx","_AGG_FINAL.csv",data_fname),na='NA')
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      

