assign_metadata_score_bylabel <- function(data1, dico1) {
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)

  ##CASE 1 - aggmethod=SCORE
  #-select all the field headers for select one
  dico_s1<-as.data.frame(filter(dico1,vtype=="cat"))
  #--loop through all the rows or take all value
  #dico_s1_headers<-distinct(as.data.frame(dico_s1[,"gname_full"]))
  data_rec<-data1 # dont see any reason to do it
  
  for(headername in data_names){
    #---extract gname=header name in data, namechoice and label choice
    #headername<-fn
    #column index from the data
    col_ind<-which(data_names==headername)
    #lookuptable
    lookup_table<-filter(dico_s1,gname_full==headername)
    lookup_table<-select(lookup_table,c("namechoice","labelchoice","vtype","vscore","gname_full"))
    #loop through lookup table - which will be fewer rows to manage
    for (i_lt in 1:nrow(lookup_table)){
      #i_lt=2
      data_rec[,col_ind]<-ifelse(data_rec[,col_ind]==lookup_table$labelchoice[i_lt],lookup_table[["vscore"]][i_lt],data_rec[,col_ind])
    }
  }#finish recoding of select_one
  return(data_rec)
}
NULL