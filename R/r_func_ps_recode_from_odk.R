kobo_encode <- function(data, dico) {
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data)
  ######names(data_names)[1] <- "fullname"
  #data_names <- join (x=data_names, y=dico, by="fullname", type="left" )
  ### Now we can also re-encode the records themself
  ##CASE 1 - Select_one
    #-select all the field headers for select one
    dico_s1<-as.data.frame(filter(dico,qtype=="select_one"))
    #--loop through all the rows or take all value
    dico_s1_headers<-distinct(as.data.frame(dico_s1[,"gname"]))
    data_rec<-data # dont see any reason to do it
    #check Q_1/Q_K1/Q_K1_D = row26
    for(i in 1:nrow(dico_s1_headers)){
      #---extract gname=header name in data, namechoice and label choice
      #i=738 for location gov
      #i=26
      headername<-dico_s1_headers[i,1]
      #column index from the data
      col_ind<-which(data_names==headername)
      #lookuptable
      lookup_table<-filter(dico_s1,gname==headername)
      lookup_table<-select(lookup_table,c("namechoice","labelchoice"))
      #loop through lookup table - which will be fewer rows to manage
      #rec_var<-left_join(rec_var,lookup_table,by=structure(names=headername,"namechoice"))
      #ifelse is required to check non matching and if any variable is not in the lookup table, it will be retained as is
      for (i_lt in 1:nrow(lookup_table)){
        #i_lt=2
        data_rec[,col_ind]<-ifelse(data_rec[,col_ind]==lookup_table$namechoice[i_lt],lookup_table[["labelchoice"]][i_lt],data_rec[,col_ind])
      }
    }#finish recoding of select_one
    # recoded_fname<-"./data/data_export_csv/recoded_select_ONE.xlsx"
    # write.xlsx2(data_rec,recoded_fname,row.names = FALSE)
  
  ##CASE 2 - Select_multiple
    #-select all the field headers for SELECT MULTIPLE
    dico_smult<-as.data.frame(filter(dico,qtype=="select_multiple"))
    #--loop through all the rows or take all value
    dico_smult_headers<-distinct(as.data.frame(dico_smult[,"gname_full"]))
    
    #loop through each variable
    for (i in 1:nrow(dico_smult_headers)){
      #i=1
      headername<-dico_smult_headers[i,1]
      #column index from the data
      col_ind<-which(data_names==headername)
      #lookuptable
      lookup_table<-filter(dico_smult,gname_full==headername)
      lookup_table<-select(lookup_table,c("namechoice","labelchoice","gname","gname_full","gname_full_mlabel","gname_full_label"))
      gnamelabel<-lookup_table$gname_full_mlabel[1]
      #rename header name
      data_names[col_ind]<-gnamelabel
      #names(data_rec)[col_ind]<- gnamelabel
      ##CHANGE all True/False to 1/0
      data_rec[,col_ind]<-ifelse(data_rec[,col_ind]=="True"|data_rec[,col_ind]=="TRUE",1,ifelse(data_rec[,col_ind]=="False"|data_rec[,col_ind]=="FALSE",0,data_rec[,col_ind]))
    }
    names(data_rec)<-data_names
    #
    # #CHANGE all True/False to 1/0
    # for (kl in 1:ncol(data_rec)){
    #   data_rec[,kl]<-ifelse(data_rec[,kl]=="True",1,ifelse(data_rec[,kl]=="False",0,data_rec[,kl]))
    # }
  
  # 
  # recoded_fname<-"./data/data_export_csv/recoded_select_MULT.xlsx"
  # write.xlsx2(data_rec,recoded_fname,row.names = FALSE)
  # 
  return(data_rec)
}
NULL