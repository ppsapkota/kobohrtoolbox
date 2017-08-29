protection_gender_all_transfer <- function(data1, agg_method1) {
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)

  ##CASE 1 - aggmethod=SCORE
  #-select all the field headers for select one
  agg_s1<-as.data.frame(filter(agg_method1,!is.na(group),sector=="protection"))
  #--loop through all the rows or take all value
  #dico_s1_headers<-distinct(as.data.frame(dico_s1[,"gname_full"]))
  data_rec<-data1 # dont see any reason to do it
  
  for(i in 1:nrow(agg_s1)){
    #---extract gname=header name in data, namechoice and label choice
    #headername<-fn
    i_gname<-agg_s1$gname[i]
    i_name<-agg_s1$name[i]
    i_group<-agg_s1$group[i]
    i_name_all<-filter(agg_method1,name==i_group)
    i_gname_corres_all<-i_name_all$gname[1]
    #column index from the data
    col_ind<-which(data_names==i_gname)
    col_ind_all<-which(data_names==i_gname_corres_all)
    #check value in col_ind
    data_rec[,col_ind]<-ifelse(is.na(data_rec[,col_ind]) & !is.na(data_rec[,col_ind_all]),data_rec[,col_ind_all],data_rec[,col_ind])
  }#finish recoding of select_one metadata
  return(data_rec)
}
NULL