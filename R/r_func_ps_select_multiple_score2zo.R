select_all_score2zo <- function(data1, agg_method1) {
  print(paste0("Recode select all values to 1/0"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  agg_m_sall<-filter(agg_method1,aggmethod=="SEL_ALL")
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
          data_rec[,i_lt]<-ifelse(d_i_lt>1,1,data_rec[,i_lt])
        }
    }
  }#finish recoding of select one ORDINAL
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
      list_rnk<-data_rec[,col_ind]
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
      list_rnk<-data_rec[,col_ind]
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


