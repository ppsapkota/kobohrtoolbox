'
split select one into multiple columns for each variable

'
split_select_one_rank<-function(db,choices){
  print(paste0("Split select_one questions for Ranking: ", Sys.time()))
  #variable initialization
  vn<-"0"
  vn_group<-"0"
  vn_rank<-"0"
  
  ##CASE 1 - Select_one
  #-select all the field headers for select one and Rank
  #ch_s1<-choices[choices$aggmethod=="RANK3" | choices$aggmethod=="RANK4" ,]
  ch_s1<-as.data.frame(filter(choices,aggmethod=="RANK1" | aggmethod=="RANK3" | aggmethod=="RANK4"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,c("qrankgroup","aggmethod")]))
  #names(ch_s1_headers)[1]<-"qrankgroup"
  db_rec<-db # dont see any reason to do it
  #check Q_1/Q_K1/Q_K1_D = row26
  for(i in 1:nrow(ch_s1_headers)){
    #---extract gname=header name in data, namechoice and label choice
    #i=1
    i_vn_group<-ch_s1_headers[i,1]
    i_aggmethod<-ch_s1_headers[i,2]
    #get all variables table
    ch_s1_lookup<-as.data.frame(filter(ch_s1,qrankgroup==i_vn_group))
    #column index from the data
    col_ind<-which(str_detect(names(db_rec),i_vn_group)%in%TRUE)
    if(length(col_ind)>0){
          last_col<-col_ind[length(col_ind)] # where to start adding new columns
          #loop through lookup table - which will be fewer rows to manage
          off<-0
          #ifelse is required to check non matching and if any variable is not in the lookup table, it will be retained as is
          for (i_lt in 1:nrow(ch_s1_lookup)){
            #i_lt=26
            vn<-ch_s1_lookup$gname[i_lt]
            vn_group<-ch_s1_lookup$qrankgroup[i_lt]
            
            vn_rank<-paste0(vn_group,"/",i_aggmethod,"_SCORE/",ch_s1_lookup$labelchoice_clean[i_lt])
            vn_ind<-last_col+off
            #check variable name in the main data
            ch_ind<-which(names(db_rec)==vn_rank)
            #if does not already exist add
            if (length(ch_ind)==0){
              db_rec<-data.frame(append(db_rec, vn_rank, after =  vn_ind),check.names=FALSE,stringsAsFactors=F)
              ch_ind<-vn_ind+1
              db_rec[,ch_ind]<-NA
              names(db_rec)[ch_ind]<-gsub("\"","",names(db_rec)[ch_ind])
              off<-off+1
            }
            #now assign rank score 3,2,1
            vn_gname<-ch_s1_lookup$gname[i_lt]
            vn_qrankscore<-ch_s1_lookup$qrankscore[i_lt]
            vn_labelchoice<-ch_s1_lookup$labelchoice[i_lt]
            d_ind<-which(names(db_rec)==vn_gname)
            #
            db_rec[,ch_ind]<-ifelse(db_rec[,d_ind]==vn_labelchoice & !is.na(db_rec[,d_ind]),vn_qrankscore,db_rec[,ch_ind])
          }
    }
  }
  #write_csv(db_rec,gsub(".xlsx","_RANK_SPLIT_CHECKS.csv",data_fname),na='NA')
  print(paste0("Split select_one questions for Ranking: DONE", Sys.time()))
  return(db_rec)
}

#------------------------------------------------###
'
split select one into multiple columns for each variable

'
split_select_one<-function(db,choices){
  print(paste0("Split select_one questions for ALL variables: ", Sys.time()))
  #variable initialization
  vn<-"0"
  vn_name<-"0"
  vn_group<-"0"
  vn_rank<-"0"
  
  ##CASE 1 - Select_one
  #-select all the field headers for select one and Rank
  #ch_s1<-choices[choices$aggmethod=="RANK3" | choices$aggmethod=="RANK4" ,]
  ch_s1<-as.data.frame(filter(choices,aggmethod=="SEL1_RALL" | aggmethod=="SEL1_REL"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,c("name","qrankgroup","aggmethod")]))
  #names(ch_s1_headers)[1]<-"qrankgroup"
  db_rec<-db # dont see any reason to do it
  #check Q_1/Q_K1/Q_K1_D = row26
  for(i in 1:nrow(ch_s1_headers)){
    #---extract gname=header name in data, namechoice and label choice
    #i=1
    i_vn_name<-ch_s1_headers[i,c("name")]
    i_vn_group<-ch_s1_headers[i,c("qrankgroup")]
    i_aggmethod<-ch_s1_headers[i,c("aggmethod")]
    #get all variables table
    ch_s1_lookup<-as.data.frame(filter(ch_s1,name==i_vn_name))
    #column index from the data
    col_ind<-which(str_detect(names(db_rec),i_vn_name)%in%TRUE)
    if(length(col_ind)>0){
      last_col<-col_ind[length(col_ind)] # where to start adding new columns
      #loop through lookup table - which will be fewer rows to manage
      off<-0
      #ifelse is required to check non matching and if any variable is not in the lookup table, it will be retained as is
      for (i_lt in 1:nrow(ch_s1_lookup)){
        #i_lt=26
        vn<-ch_s1_lookup$gname[i_lt]
        vn_name<-ch_s1_lookup$name[i_lt]
        vn_group<-ch_s1_lookup$qrankgroup[i_lt]
        
        vn_split<-paste0(vn,"/SPLIT_VAR_",i_aggmethod,"/",ch_s1_lookup$labelchoice_clean[i_lt])
        vn_ind<-last_col+off
        #check variable name in the main data
        ch_ind<-which(names(db_rec)==vn_split)
        #if does not already exist add
        if (length(ch_ind)==0){
          db_rec<-data.frame(append(db_rec, vn_split, after =  vn_ind),check.names=FALSE,stringsAsFactors=F)
          ch_ind<-vn_ind+1
          db_rec[,ch_ind]<-NA
          names(db_rec)[ch_ind]<-gsub("\"","",names(db_rec)[ch_ind])
          off<-off+1
        }
        #now assign rank score 3,2,1
        vn_gname<-ch_s1_lookup$gname[i_lt]
        vn_qrankscore<-ch_s1_lookup$qrankscore[i_lt]
        vn_labelchoice<-ch_s1_lookup$labelchoice[i_lt]
        d_ind<-which(names(db_rec)==vn_gname)
        #
        db_rec[,ch_ind]<-ifelse(db_rec[,d_ind]==vn_labelchoice & !is.na(db_rec[,d_ind]),vn_qrankscore,db_rec[,ch_ind])
      }
    }
  }
  #write_csv(db_rec,gsub(".xlsx","_RANK_SPLIT_CHECKS.csv",data_fname),na='NA')
  print(paste0("Split select_one questions for ALL variables: DONE ", Sys.time()))
  return(db_rec)
}


##----------------SEL1_RALL------FOR Select ONE Retain all answers------------------------------------------------###
split_select_one_all_transfer<-function(db,choices){
  print(paste0("Split select_one questions Transfer ALL to MEN/WOMEN/BOYS/GIRLS: ", Sys.time()))
  #variable initialization
  vn<-"0"
  vn_name<-"0"
  vn_group<-"0"
  vn_rank<-"0"
  
  ##CASE 1 - Select_one
  #-select all the field headers for select one and Rank
  #ch_s1<-choices[choices$aggmethod=="RANK3" | choices$aggmethod=="RANK4" ,]
  ch_s1<-as.data.frame(filter(choices,aggmethod=="SEL1_RALL"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,c("name","qrankgroup","aggmethod","gname")]))
  #names(ch_s1_headers)[1]<-"qrankgroup"
  db_rec<-db # dont see any reason to do it
  #check Q_1/Q_K1/Q_K1_D = row26
  for(i in 1:nrow(ch_s1_headers)){
    #---extract gname=header name in data, namechoice and label choice
    #i=1
    i_vn_name<-ch_s1_headers[i,c("name")]
    i_vn_group<-ch_s1_headers[i,c("qrankgroup")]
    i_vn_gname<-ch_s1_headers[i,c("gname")]
    i_aggmethod<-ch_s1_headers[i,c("aggmethod")]
    #get all variables table
    ch_s1_lookup<-as.data.frame(filter(ch_s1,qrankgroup==i_vn_name))
    #column index from the data
    col_ind<-which(str_detect(names(db_rec),i_vn_name)%in%TRUE)
    ##identify col_ind for all
    vn_for_all<-paste0(i_vn_gname,"/SPLIT_VAR_",i_aggmethod,"/","All")
    col_ind_for_all<-which(str_detect(names(db_rec),vn_for_all) %in% TRUE)
    
    if(length(col_ind)>0 && length(col_ind_for_all)>0){
      ###Loop through each column
      #last_col<-col_ind[length(col_ind)] # where to start adding new columns
      #loop through lookup table - which will be fewer rows to manage
      #off<-0
      #ifelse is required to check non matching and if any variable is not in the lookup table, it will be retained as is
      for (i_lt in 1:nrow(ch_s1_lookup)){
        #i_lt=26
        vn<-ch_s1_lookup$gname[i_lt]
        vn_group<-ch_s1_lookup$qrankgroup[i_lt]
        vn_labelchoice<-ch_s1_lookup$labelchoice_clean[i_lt]
        vn_qrankscore<-ch_s1_lookup$qrankscore[i_lt]
        vn_split<-paste0(vn,"/SPLIT_VAR_",i_aggmethod,"/",vn_labelchoice)
        #vn_ind<-last_col+off
        #check variable name in the main data
        ch_ind<-which(names(db_rec)==vn_split)
        #ch_ind<-which(names(a)==vn_rank)
        if (str_to_upper(vn_labelchoice)!="DO NOT KNOW" && str_to_upper(vn_labelchoice)!="NO ANSWER"){
            ### if variable is not Do not know or No answer, then assign 1 of col_ind_for_all has 1.
            db_rec[,ch_ind]<-ifelse(db_rec[,col_ind_for_all]==vn_qrankscore & !is.na(db_rec[,col_ind_for_all]),vn_qrankscore,db_rec[,ch_ind])
            #a[,ch_ind]<-ifelse(db_rec[,col_ind_for_all]==vn_qrankscore,vn_qrankscore,a[,ch_ind])
        }
        
      }
    }
  }
  #write_csv(db_rec,gsub(".xlsx","_RANK_SPLIT_CHECKS.csv",data_fname),na='NA')
  print(paste0("Split select_one questions for ALL transfer: DONE ", Sys.time()))
  return(db_rec)
}

##----------------SEL1_REL------Transfer value from the Related fied------in 'group' column---------------------###
split_select_one_related_q_value_transfer<-function(db,choices){
  print(paste0("Split select_one questions Transfer Value from Related field: ", Sys.time()))
  #variable initialization
  vn<-"0"
  vn_name<-"0"
  vn_group<-"0"
  vn_rank<-"0"
  vn_related<-"0"
  ##CASE 1 - Select_one
  #-select all the field headers for select one and Rank
  #ch_s1<-choices[choices$aggmethod=="RANK3" | choices$aggmethod=="RANK4" ,]
  ch_s1<-as.data.frame(filter(choices,aggmethod=="SEL1_REL"))
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,c("name","qrankgroup","aggmethod","gname","group")]))
  #names(ch_s1_headers)[1]<-"qrankgroup"
  db_rec<-db # dont see any reason to do it
  #check Q_1/Q_K1/Q_K1_D = row26
  for(i in 1:nrow(ch_s1_headers)){
    #---extract gname=header name in data, namechoice and label choice
    #i=1
    i_vn_name<-ch_s1_headers[i,c("name")]
    i_vn_group<-ch_s1_headers[i,c("qrankgroup")]
    i_vn_gname<-ch_s1_headers[i,c("gname")]
    i_aggmethod<-ch_s1_headers[i,c("aggmethod")]
    #another related field to get the value for substitution
    i_vn_related<-ch_s1_headers[i,c("group")]
    #get all variables table
    ch_s1_lookup<-as.data.frame(filter(ch_s1,qrankgroup==i_vn_name))
    #column index from the data
    col_ind<-which(str_detect(names(db_rec),i_vn_name)%in%TRUE)
    
    #identify col_ind_related for related field to get the data value
    #the value from col_ind_related will be substituted to main ones i.e. col_ind
    col_ind_related<-which(str_detect(names(db_rec),i_vn_related)%in%TRUE)
    
    if(length(col_ind)>0 && length(col_ind_related)>0){
      ###Loop through each column
      #last_col<-col_ind[length(col_ind)] # where to start adding new columns
      #loop through lookup table - which will be fewer rows to manage
      #off<-0
      #ifelse is required to check non matching and if any variable is not in the lookup table, it will be retained as is
      for (i_lt in 1:nrow(ch_s1_lookup)){
        #i_lt=26
        vn<-ch_s1_lookup$gname[i_lt]
        vn_group<-ch_s1_lookup$qrankgroup[i_lt]
        vn_labelchoice<-ch_s1_lookup$labelchoice_clean[i_lt]
        vn_qrankscore<-ch_s1_lookup$qrankscore[i_lt]
        vn_split<-paste0(vn,"/SPLIT_VAR_",i_aggmethod,"/",vn_labelchoice)
        #vn_ind<-last_col+off
        #check variable name in the main data
        ch_ind<-which(names(db_rec)==vn_split)
        #ch_ind<-which(names(a)==vn_rank)
        #if (str_to_upper(vn_labelchoice)!="NOT ACCESSIBLE" && str_to_upper(vn_labelchoice)!="DO NOT KNOW"){
          ### if variable is not Do not know or No answer, then assign 1 of col_ind_for_all has 1.
          db_rec[,ch_ind]<-ifelse(!is.na(db_rec[,col_ind_related]) & !is.na(db_rec[,ch_ind]),db_rec[,col_ind_related],db_rec[,ch_ind])
          #a[,ch_ind]<-ifelse(db_rec[,col_ind_for_all]==vn_qrankscore,vn_qrankscore,a[,ch_ind])
        #}
      }
    }
  }
  #write_csv(db_rec,gsub(".xlsx","_RANK_SPLIT_CHECKS.csv",data_fname),na='NA')
  print(paste0("Split select_one questions for ALL transfer: DONE ", Sys.time()))
  return(db_rec)
}
NULL








