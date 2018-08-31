# Rename labels to new label name in select one question.
# Renaming is defined in choices sheet "rename_label" column
#
# Args:
#     data1: main data
#     choices1: kobo choices 
#
# Returns:
#     renamed dataset

select_one_rename_label <- function(data1, choices1) {
  print(paste0("Renaming select one kobo labels to new label"))
  ### First we provide attribute label to variable name
  #data.label <- as.data.frame(names(data))
  #data<-as.data.frame(data,stringsAsFactors=FALSE,check.names=FALSE)
  data_names<-names(data1)
  #-select all the field headers for select one
  ch_s1<-filter(choices1,!is.na(rename_label))
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
      lookup_table<-select(lookup_table,c("namechoice","labelchoice","vtype","vscore","vweight","gname","rename_label"))
      #loop through lookup table - which will be fewer rows to manage
      for (i_lt in 1:nrow(lookup_table)){
        #i_lt=2
        data_rec[,col_ind]<-ifelse(data_rec[,col_ind]==lookup_table$labelchoice[i_lt],lookup_table[["rename_label"]][i_lt],data_rec[,col_ind])
      }
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL