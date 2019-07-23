select_all_score2zo <- function(data1, choices1) {
  print(paste0("Recode select all values to 1/0"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m_sall<-filter(choices1,aggmethod=="SEL_ALL")
  #--loop through all the rows or take all value
  agg_m_sall_headers<-distinct(as.data.frame(agg_m_sall[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(agg_m_sall_headers)){
    i_headername<-agg_m_sall_headers[i,1]
    #column index from the data
    col_ind<-which(str_detect(data_names, paste0(i_headername,"/")) %in% TRUE)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
        #loop through each index
        for (i_lt in col_ind){
          #i_lt=2
          d_i_lt<-conv_num(data_rec[,i_lt])
          data_rec[,i_lt]<-ifelse(d_i_lt>0,1,data_rec[,i_lt])
        }
    }
  }#finish recoding to 0/1
  return(data_rec)
}
NULL

####--------------------------------------------####
# with weight of the variable
# treatment of do not know and no answer
select_all_score2zo_vweight <- function(data1, choices1) {
  print(paste0("Recode select all values to 1/0 considering variable weight"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m_sall<-filter(choices1,aggmethod=="SEL_ALL")
  #--loop through all the rows or take all value
  agg_m_sall_headers<-distinct(as.data.frame(agg_m_sall[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(agg_m_sall_headers)){
    i_headername<-agg_m_sall_headers[i,1]
    #column index from the data
    col_ind<-which(str_detect(data_names, paste0(i_headername,"/")) %in% TRUE)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
        #loop through each index
        for (i_lt in col_ind){
          #i_lt=2
          d_i_lt<-as.numeric(as.character(data_rec[,i_lt])) #convert to number
          data_rec[,i_lt]<-ifelse(d_i_lt>0,1,data_rec[,i_lt]) ##greater than ZERO - means answered
        }
    }
    
    ###perform below operation if there are more than one columns
    ### otherwise simple above operation is enough
    ### no rowwise ranking is necessary if it has single column
      if (length(col_ind)>1){
          ###-----below steps are done to handle do not know or no answer------
          list_rnk<- select(data_rec, col_ind) %>% as.data.frame()
          #as.data.frame(data_rec[,col_ind])
          # convert to numeric first
          # and then replace 1 by variable weight (vweight - low weight) for
          # do not know and no answer
          # this is done to exclude do not know and no answer if any other variable
          # has an answer
          # 
          for (i_list in 1:ncol(list_rnk)){
            list_rnk[,i_list]<-as.numeric(as.character(list_rnk[,i_list]))
            ###------if do not know or no answer, substitute by small number
            var_headername<-names(list_rnk)[i_list]
            #var_name<-split_headername_get_varname(names(list_rnk)[i_list],"/")
            ###return to the original name
            #var_name<-gsub("_","/",var_name)
            ##replace if it is part of do not know or no answer field
            #if (var_name %in% dnk_no_ans_label_list){
            ##get the weight for the variable
            d_lk<-filter(choices1,gname_full_mlabel==var_headername) #should return one row
            ##if it is found in the data
            if (nrow(d_lk)>0){
              vw<-as.numeric(d_lk$vweight[1])##first row - by default it should return ONE row only
            }else{vw<-1}
            #list_rnk[,i_list]<-ifelse(list_rnk[,i_list]==1,vw,list_rnk[,i_list])
            list_rnk[,i_list]<-list_rnk[,i_list]*vw
            #}
          }## all replacement of score is done
          
          # to check if list_rnk has one or more fields - if only one field - this one does not work
          # in case one one columns only, no need for rowwise ranking.
            d_rank<-t(apply(list_rnk,1,function(x) rank(-x,na.last="keep", ties.method = "min")))
            d_rank<-as.data.frame(d_rank)
          # JUST INCASE data has all ZERO in the row,
          # rowwise rank returns 1. Replace it back to ZERO.
            #Zero removed - ZERO in the main table is substituted with ZERO
            for(ir in 1:ncol(d_rank)){
                d_rank[,ir]<-ifelse(list_rnk[,ir]==0,0,d_rank[,ir])
            }
          ##for second or third rank, change to 0
          ##this works are score is already reduced to 1.
          ##1 value should get rank 1
          for (i_lt in 1:ncol(d_rank)){
            d_rank[,i_lt]<-ifelse(d_rank[,i_lt]>1,0,d_rank[,i_lt])
          }
          #Replace values in the main table
          data_rec[,col_ind]<-d_rank
      }
    ##if length >0 i.e. header found in the data
    }#finish recoding of select one ORDINAL
    return(data_rec)
  }
  NULL



####-----------------------------------------------------------------#####
### SELECT ONE IS SPLIT INTO MULTIPLE COLUMNS AND RETAIN ALL ANSWERS
# This is equivalent to SELECT ALL APPLICABLE QUESTION.
select_one_retain_all_score2zo <- function(data1, choices1) {
  print(paste0("Recode select one and retain all values to 1/0"))
  ### First we provide attribute label to variable name
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m_sall<-filter(choices1,aggmethod=="SEL1_RALL" | aggmethod=="SEL_1_RALL")
  #--loop through all the rows or take all value
  agg_m_sall_headers<-distinct(as.data.frame(agg_m_sall[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(agg_m_sall_headers)){
    i_headername<-agg_m_sall_headers[i,1]
    #column index from the data
    col_ind<-which(str_detect(data_names, paste0(i_headername,"/")) %in% TRUE)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      #loop through each index
      #loop through each index
      for (i_lt in col_ind){
        #i_lt=2
        d_i_lt<-conv_num(data_rec[,i_lt])
        data_rec[,i_lt]<-ifelse(d_i_lt>0,1,data_rec[,i_lt])
      }
      ###-----------
      #list_rnk<-as.data.frame(data_rec[,col_ind])
      list_rnk<- select(data_rec, col_ind) %>% as.data.frame()
      # convert to numeric first
      # and then replace 1 by variable weight (vweight - low weight) for
      # do not know and no answer
      # this is done to exclude do not know and no answer if any other variable
      # has an answer
      # 
      for (i_list in 1:ncol(list_rnk)){
        list_rnk[,i_list]<-as.numeric(as.character(list_rnk[,i_list]))
        ###------if do not know or no answer, substitute by small number
        var_name<-split_headername_get_varname(names(list_rnk)[i_list],"/")
        ###return to the original name
        var_name<-gsub("_","/",var_name)
        ##replace if it is part of do not know or no answer field
        #if (var_name %in% dnk_no_ans_label_list){
          ##get the weight for the variable
          d_lk<-filter(choices1,gname==i_headername,labelchoice==var_name)
          if (nrow(d_lk)>0){
            vw<-as.numeric(d_lk$vweight[1])
          }else{vw<-1}
          #list_rnk[,i_list]<-ifelse(list_rnk[,i_list]==1,vw,list_rnk[,i_list])
          list_rnk[,i_list]<-list_rnk[,i_list]*vw
        #}
      }## all replacement of score is done
      
      d_rank<-t(apply(list_rnk,1,function(x) rank(-x,na.last="keep", ties.method = "min")))
      d_rank<-as.data.frame(d_rank)
      for (i_lt in 1:ncol(d_rank)){
        d_rank[,i_lt]<-ifelse(d_rank[,i_lt]>1,0,d_rank[,i_lt])
      }
      #Replace values in the main table
      data_rec[,col_ind]<-d_rank
      
      #time to extract the concatenated actual text response
      #txt_list_rank<-data_rec[,col_ind]
      txt_list_rank<-d_rank
      txt_list_rank1<-concat_multiresponse(txt_list_rank,1) #since it is Zero or 1, first rank gets the result
      #txt_list_rank2<-concat_multiresponse(txt_list_rank,2) #second rank
      #txt_list_rank3<-concat_multiresponse(txt_list_rank,3) #third rank
      #txt_list_rank4<-concat_multiresponse(txt_list_rank,4) #fourth rank
      #Replace '_' by '/' this is an original replacement
      txt_list_rank1<-gsub("_","/",txt_list_rank1)
      #txt_list_rank2<-gsub("_","/",txt_list_rank2)
      #txt_list_rank3<-gsub("_","/",txt_list_rank3)
      #txt_list_rank4<-gsub("_","/",txt_list_rank4)
      
      #now find out replacement column in the main database
      i_headername_col_ind<-which(data_names==i_headername)
      ##if column is in the data
      if (length(i_headername_col_ind)>0){
        data_rec[,i_headername_col_ind]<-txt_list_rank1
      }##done replacement in the main column
      
    }
  }#finish recoding of select multiple
  
  return(data_rec)
}
NULL


select_upto_n_score2zo <- function(data1, agg_method1) {
  print(paste0("Recode select top 3/top 4 values to 1/0"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m3<-filter(agg_method1,aggmethod=="SEL_3" | aggmethod=="SEL_4")
  #--loop through all the rows or take all value
  agg_m3_headers<-distinct(as.data.frame(agg_m3[,c("gname","aggmethod")]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(agg_m3_headers)){
    i_headername<-agg_m3_headers[i,1]
    i_type<-agg_m3_headers[i,2]
    #column index from the data
    col_ind<-which(str_detect(data_names, paste0(i_headername,"/")) %in% TRUE)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      #loop through each index
      #list_rnk<-as.data.frame(data_rec[,col_ind])
      list_rnk<-select(data_rec, col_ind) %>% as.data.frame()
      for (i_list in 1:ncol(list_rnk)){
        list_rnk[,i_list]<-as.numeric(as.character(list_rnk[,i_list]))
      }
     
      rank3<-t(apply(list_rnk,1,function(x) rank(-x,na.last="keep", ties.method = "min")))
      rank3<-as.data.frame(rank3)
      #Zero removed - ZERO in the main table is substituted with maximum rank value
      for(ir in 1:ncol(rank3)){
        rank3[,ir]<-ifelse(list_rnk[,ir]==0,ncol(rank3),rank3[,ir])
      }
      #Now select based on SEL_3 or SEL_4
      
      if(i_type=="SEL_4"){
        for(ir in 1:ncol(rank3)){rank3[,ir]<- rank3[,ir]<=4}
      }else{
        for(ir in 1:ncol(rank3)){rank3[,ir]<- rank3[,ir]<=3}
      }
      
      #change true false to 1/0
      for (ir in 1:ncol(rank3)){
        rank3[,ir]<-ifelse(rank3[,ir]=="True"|rank3[,ir]=="TRUE",1,ifelse(rank3[,ir]=="False"|rank3[,ir]=="FALSE",0,rank3[,ir]))
      }
      #Replace values in the main table
      data_rec[,col_ind]<-rank3
      
      # count<-0
      # for (i_lt in col_ind){
      #   count<-count+1
      #   data_rec[,i_lt]<-rank3[,count]
      # }
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL

#--------------------Weighted--------------------------------------#
# considers the weight of the variable
# useful to treat Do not know or No answer
# small weight is assigned to these variables
# so that it will have minimal effect during
# aggregation process
select_upto_n_score2zo_vweight <- function(data1, choices1) {
  print(paste0("Recode select top 3/top 4 values to 1/0 considering weight of the variable"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m3<-filter(choices1,aggmethod=="SEL_3" | aggmethod=="SEL_4")
  #--loop through all the rows or take all value
  agg_m3_headers<-distinct(as.data.frame(agg_m3[,c("gname","aggmethod")]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  if (nrow(agg_m3_headers)>0){ #only if there are rows
    for(i in 1:nrow(agg_m3_headers)){
      i_headername<-agg_m3_headers[i,1]
      i_type<-agg_m3_headers[i,2]
      #column index from the data
      col_ind<-which(str_detect(data_names, paste0(i_headername,"/")) %in% TRUE)
      #Replace only if header is found in the main data table
      if (length(col_ind)>0){
        #loop through each index
        #list_rnk<-as.data.frame(data_rec[,col_ind])
        list_rnk<-select(data_rec, col_ind) %>% as.data.frame()
        #convert to numeric
        for(i_list in 1:ncol(list_rnk)){
            list_rnk[,i_list]<-as.numeric(as.character(list_rnk[,i_list]))
            ###------if do not know or no answer, substitute by small number
            var_headername<-names(list_rnk)[i_list]
            #var_name<-split_headername_get_varname(names(list_rnk)[i_list],"/")
            ###return to the original name
            #var_name<-gsub("_","/",var_name)
            ##replace if it is part of do not know or no answer field
            #if (var_name %in% dnk_no_ans_label_list){
            ##get the weight for the variable
            d_lk<-filter(choices1,gname_full_mlabel==var_headername) #should return one row
            if (nrow(d_lk)>0){
              vw<-as.numeric(d_lk$vweight[1])
            }else{vw<-1}
            #list_rnk[,i_list]<-ifelse(list_rnk[,i_list]==1,vw,list_rnk[,i_list])
            list_rnk[,i_list]<-list_rnk[,i_list]*vw
        }
        #
        rank3<-t(apply(list_rnk,1,function(x) rank(-x,na.last="keep", ties.method = "min")))
        rank3<-as.data.frame(rank3)
        #Zero removed - ZERO in the main table is substituted with maximum rank value
        for(ir in 1:ncol(rank3)){
          rank3[,ir]<-ifelse(list_rnk[,ir]==0,ncol(rank3),rank3[,ir])
        }
        #Now select based on SEL_3 or SEL_4
        
        if(i_type=="SEL_4"){
          for(ir in 1:ncol(rank3)){rank3[,ir]<- rank3[,ir]<=4}
        }else{
          for(ir in 1:ncol(rank3)){rank3[,ir]<- rank3[,ir]<=3}
        }
        
        #change true false to 1/0
        for (ir in 1:ncol(rank3)){
          rank3[,ir]<-ifelse(rank3[,ir]=="True"|rank3[,ir]=="TRUE",1,ifelse(rank3[,ir]=="False"|rank3[,ir]=="FALSE",0,rank3[,ir]))
        }
        #Replace values in the main table
        data_rec[,col_ind]<-rank3
        
        # count<-0
        # for (i_lt in col_ind){
        #   count<-count+1
        #   data_rec[,i_lt]<-rank3[,count]
        # }
      }
    }#finish recoding of select one ORDINAL
  }#IF
  return(data_rec)
}
NULL


select_rank_score2rank <- function(data1, agg_method1) {
  print(paste0("Recode select rank score to actual ranking"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_rank<-filter(agg_method1,aggmethod=="RANK1"|aggmethod=="RANK3" | aggmethod=="RANK4")
  #--loop through all the rows or take all value
  agg_rank_headers<-distinct(as.data.frame(agg_rank[,c("qrankgroup","aggmethod")]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(agg_rank_headers)){
    i_headername<-agg_rank_headers[i,1]
    i_type<-agg_rank_headers[i,2]
    #lookup table
    lookup_table<-filter(agg_rank,qrankgroup==i_headername)
    
    #column index from the data
    col_ind<-which(str_detect(data_names, paste0(i_headername,"/","RANK")) %in% TRUE)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      #loop through each index
      #list_rnk<-data_rec[,col_ind]
      list_rnk<-select(data_rec, col_ind) %>% as.data.frame()
      
      for (i_list in 1:ncol(list_rnk)){
        list_rnk[,i_list]<-as.numeric(as.character(list_rnk[,i_list]))
      }
      rank3<-t(apply(list_rnk,1,function(x) rank(-x,na.last="keep", ties.method = "min")))
      rank3<-as.data.frame(rank3)
      #Zero removed - ZERO in the main table is substituted with maximum rank value
      for(ir in 1:ncol(rank3)){
        rank3[,ir]<-ifelse(list_rnk[,ir]==0,ncol(rank3),rank3[,ir])
      }
      #Now select based on SEL_3 or SEL_4
      
      if(i_type=="RANK4"){
          for(ir in 1:ncol(rank3)){
           rank3[,ir]<-ifelse(rank3[,ir]>4,NA,rank3[,ir])
          }
      }else if (i_type=="RANK1"){
          for(ir in 1:ncol(rank3)){
            rank3[,ir]<-ifelse(rank3[,ir]>1,NA,rank3[,ir])
          }
      }else{
          for(ir in 1:ncol(rank3)){
            rank3[,ir]<-ifelse(rank3[,ir]>3,NA,rank3[,ir])
          }
      }
      #Replace values in the main table
      data_rec[,col_ind]<-rank3
      
          #time to extract the concatenated actual text response
          txt_list_rank<-rank3
          txt_list_rank1<-concat_multiresponse(txt_list_rank,1) #first rank
          txt_list_rank2<-concat_multiresponse(txt_list_rank,2) #second rank
          txt_list_rank3<-concat_multiresponse(txt_list_rank,3) #third rank
          txt_list_rank4<-concat_multiresponse(txt_list_rank,4) #fourth rank
          #Replace '_' by '/' this is an original replacement
          txt_list_rank1<-gsub("_","/",txt_list_rank1)
          txt_list_rank2<-gsub("_","/",txt_list_rank2)
          txt_list_rank3<-gsub("_","/",txt_list_rank3)
          txt_list_rank4<-gsub("_","/",txt_list_rank4)
          
              #now find out replacement column in the main database
              for (ir in 1:nrow(lookup_table)){
                rank_gname<-lookup_table$gname[ir]
                rank_score<-as.numeric(lookup_table$qrankscore[ir])
                rank_level<-nrow(lookup_table)-rank_score+1
                if(rank_level==1){data_rec[,which(data_names==rank_gname)]<-txt_list_rank1}
                if(rank_level==2){data_rec[,which(data_names==rank_gname)]<-txt_list_rank2}
                if(rank_level==3){data_rec[,which(data_names==rank_gname)]<-txt_list_rank3}
                if(rank_level==4){data_rec[,which(data_names==rank_gname)]<-txt_list_rank4}
              }#done replacement in the main column
    }
      
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL

#concatenate multiple rank response texts
concat_multiresponse<-function(db_rnk,rnk){
  txt_list_rank<-db_rnk
  for(ir in 1:ncol(db_rnk)){
    txt_list_rank[,ir]<-ifelse(db_rnk[,ir]==rnk,split_heading_get_varname(names(db_rnk),ir,"/"),NA)
    txt_list_rank<-as.data.frame(txt_list_rank)
  }
  #txt_list_rank1$result<-apply(txt_list_rank1,1, function(x) toString(na.omit(x)))
  concat_result<-apply(txt_list_rank,1, function(x) {paste(x[which(!is.na(x))],collapse="; ")})
  return(concat_result)  
}
NULL

#split column header and get the last one
split_heading_get_varname<-function(headername,ind,sep){
  txt_split<-str_split(headername[ind],sep)
  txt_len<-length(txt_split[[1]])
  txt_val<-txt_split[[1]][txt_len]
  return(txt_val)
}
NULL

#split column header and get the last one
split_headername_get_varname<-function(headername,sep){
  txt_split<-str_split(headername,sep)
  txt_len<-length(txt_split[[1]])
  txt_val<-txt_split[[1]][txt_len]
  return(txt_val)
}
NULL


