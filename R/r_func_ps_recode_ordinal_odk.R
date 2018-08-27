assign_ordinal_score_bylabel <- function(data1, choices1) {
  print(paste0("Recode ordinal variables to score"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  ch_s1<-filter(choices1,vtype=="ord")
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(ch_s1_headers)){
    #column index from the data
    i_headername<-ch_s1_headers[i,1]
    col_ind<-which(data_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
        #lookuptable
        lookup_table<-filter(ch_s1,gname==i_headername)
        lookup_table<-select(lookup_table,c("namechoice","labelchoice","vtype","vscore","gname"))
        #loop through lookup table - which will be fewer rows to manage
        for (i_lt in 1:nrow(lookup_table)){
          #i_lt=2
          data_rec[,col_ind]<-ifelse(data_rec[,col_ind]==lookup_table$labelchoice[i_lt],lookup_table[["vscore"]][i_lt],data_rec[,col_ind])
        }
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL


assign_ordinal_label_byscore <- function(data1, choices1) {
  print(paste0("Recode ordinal score to variable name"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  ch_s1<-as.data.frame(filter(choices1,vtype=="ord"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(ch_s1_headers)){
    #column index from the data
    i_headername<-ch_s1_headers[i,1]
    col_ind<-which(data_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      #lookuptable
      lookup_table<-filter(ch_s1,gname==i_headername)
      lookup_table<-select(lookup_table,c("namechoice","labelchoice","vtype","vscore","gname"))
      #loop through lookup table - which will be fewer rows to manage
      for (i_lt in 1:nrow(lookup_table)){
        #i_lt=2
        data_rec[,col_ind]<-ifelse(data_rec[,col_ind]==lookup_table$vscore[i_lt],lookup_table[["labelchoice"]][i_lt],data_rec[,col_ind])
      }
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL

#-------------------------------------------------------------------------------------#
# Recode NAs in ordinal questions back to actual variable names
# recoding is done only if:
#   - all records for the community is either Do not know or No answer
#   - one or more records have actual answer, no recoding is done in this step
#
# Args:
#     data1: main data
#     choices1: kobo choices
#     agg_level_vars1: 
#
# Returns:
#     recoded dataset

assign_ordinal_NAs_back2var <- function(db_agg1,choices1,data1,agg_level_vars1) {
  print(paste0("Recode NAs back to variable name (mainly Do not know or No answer)","--",Sys.time()))
  #db_agg1<-db_agg
  #choices1<-dico
  #data1<-data
  #agg_level_vars1<-agg_level_colnames
  ###First, identify records which has only Do not know or No answers
  data_names<-names(data1)
  db_agg_names<-names(db_agg1)
  #-select all the field headers for select one
  ch_s1<-as.data.frame(filter(choices1,vtype=="ord"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,c("gname")]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  db_agg_rec<-as.data.frame(db_agg1)
  
  #list of no answer list
  no_ans_labelchoice_list<-c("No answer", 
                             "not sure / do not know",
                             "Not sure/do not know",
                             "Unsure",
                             "Unsure / no answer")
  
  for(i in 1:nrow(ch_s1_headers)){
    #i<-39
    #column index from the data
    i_headername<-ch_s1_headers[i,1]
    #only if it is included in the aggregated data
    col_ind<-which(db_agg_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      
      #run through not aggregated data (main raw data)
      ##data records
      f<-c(agg_level_vars1,i_headername)
      d<-data_rec[,f] %>% na.omit()
      ##incase of empty dataframe
      if (nrow(d)==0){
        d<-get_empty_dataframe(data_rec,f)
        d<-d %>% mutate_all(funs(as.character))
      }
      #lookuptable
      lookup_table<-filter(ch_s1,gname==i_headername)
      lookup_table<-select(lookup_table,c("namechoice","labelchoice","vtype","vscore","vweight","gname"))
      
      d_lt<-lookup_table[,c("labelchoice","vscore","vweight")]
      names(d_lt)[1]<-i_headername
      ##bring ordinal score
      d<-d %>% left_join(d_lt,by=i_headername)
      #beauty of categorical data
      d[,c(i_headername)]<-ifelse(d[,c("vscore")]!="NA","beauty of categorical data",d[,c(i_headername)])
      d[,c("vscore")]<-ifelse(d[,c("vscore")]!="NA","1",d[,c("vscore")])
      ##Count total records per aggregation level
      d_nr<-d %>% group_by_at(vars(agg_level_vars1)) %>% 
            summarise(n_records=n()) %>% 
            ungroup()
      
      ##Count NAs per aggregation level
      d_nr_na<-d %>% filter(vscore=="NA") %>% 
                     group_by_at(vars(agg_level_vars1)) %>% 
                     summarise  (n_records_na=n()) %>%
                     ungroup()
      
      d <- d %>% 
        left_join(d_nr,by=agg_level_vars1) %>% 
        left_join(d_nr_na,by=agg_level_vars1) 
      
      ##keep only records that has 
      #   n_records==n_records_na and vscore=="NA"
      d_<-d %>% filter(vscore=="NA" & n_records==n_records_na)
      
      #NOW group again - number of records per community
      d_nr<-d_ %>% group_by_at(vars(agg_level_vars1)) %>% 
        summarise(n_records=n()) %>% 
        ungroup()
      ##number of records per response
      d_nr_vars<-d_ %>% group_by_at(vars(f)) %>% 
                  summarise(n_records_vars=n(),sum_vweight=sum(as.numeric(vweight))) %>% 
                  ungroup()
      
      ###join again
      d_vars <- d_ %>% select(-c(vscore, n_records,n_records_na)) %>% 
                left_join(d_nr,by=agg_level_vars1) %>% 
                left_join(d_nr_vars,by=f)
      
      ##now do the rank of n_record_vars
      d_vars<-d_vars %>%
                 group_by_at(vars(agg_level_vars1)) %>% 
                 #mutate(na_rank=rank(-n_records_vars,ties.method = 'min')) %>%
                 mutate(na_rank=rank(-sum_vweight,ties.method = 'min')) %>%
                 ungroup() %>%          
                 distinct() 
      ##now select rank 1 only
      d_vars<-filter(d_vars,na_rank==1) %>% 
              group_by_at(.vars=vars(agg_level_vars1)) %>% 
              mutate_at(vars("na_rank"),funs(n_samerank=n())) %>%
              ungroup() %>% 
              as.data.frame()
      
      ###if more than one record has do not know or no answer
      ### remove no answer records
      kl<-which(names(d_vars)==i_headername)
      kl_r<-which(names(d_vars)=="n_samerank")
      
      # d_vars[,kl]<-ifelse(d_vars[,kl_r]>1 & (d_vars[,kl]=="No answer"|
      #                                        d_vars[,kl]=="not sure / do not know"|
      #                                        d_vars[,kl]=="Not sure/do not know"|
      #                                        d_vars[,kl]=="Unsure"|
      #                                        d_vars[,kl]=="Unsure / no answer"),NA,d_vars[,kl])
      # 
      d_vars[,kl]<-ifelse(d_vars[,kl_r]>1 & d_vars[,kl] %in% no_ans_labelchoice_list,NA,d_vars[,kl])
      d_vars<-na.omit(d_vars)
      d_replace<-d_vars %>% filter(na_rank==1) %>% select(f) %>% distinct()
      # d_replace<-filter(d_vars,na_rank==1 & n_samerank==1) %>% 
      #            select(f) %>% distinct()
      
      #loop through lookup table - which will be fewer rows to manage
      for (i_rp in 1:nrow(d_replace)){
        #i_rp=1
        ##find row number in aggregated data
        v_search<-paste0(d_replace[i_rp,c(agg_level_vars1)],collapse="")
        #
        d_chk_search<-db_agg_rec %>% select_at(vars(agg_level_vars1))
        #d_chk_search$chk_search<-apply(d_chk_search,1,paste0,collapse="")
        d_chk_search<-tidyr::unite(d_chk_search,"chk_search", sep="")
        #
        #row_ind<-which(paste0(db_agg_rec[,agg_level_vars1],collapse="")==v_search)
        row_ind<-which(d_chk_search[,c("chk_search")]==v_search)
        #df1$check <- ifelse(is.na(match(paste0(df1$pnr, df1$drug), 
        #                                paste0(df2$pnr, df2$drug))),"No", "Yes")
        col_ind_replace<-which(names(d_replace)==i_headername)
        #ideally this should be one record only
          for (i_row_ind in row_ind){
            db_agg_rec[i_row_ind,col_ind]<-ifelse(is.na(db_agg_rec[i_row_ind,col_ind]), d_replace[i_rp,col_ind_replace] ,db_agg_rec[i_row_ind,col_ind])
          }
      }
    }
  }#finish recoding of select one ORDINAL
  print(paste0("Recode NAs back to variable name (mainly Do not know or No answer)","--DONE--",Sys.time()))
  return(db_agg_rec)
  
}
NULL

