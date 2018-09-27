# translate Arabic texts to English
#
# Args:
#     data1: main data
#     choices1: kobo choices 
#
# Returns:
#     texts translated dataset

translate_ar2en<-function(db1,choices1){
  print(paste0("translate Arabic to English"))
  data_names<-names(db1)
  #-select all the field headers for select one
  ch_text<-filter(choices1,qtype=="text")
  #--loop through all the rows or take all value
  ch_text_headers<-distinct(as.data.frame(ch_text[,"gname"]))
  data_rec<-as.data.frame(db1) # dont see any reason to do it
  for(i in 1:nrow(ch_text_headers)){
    #column index from the data
    i_headername<-ch_text_headers[i,1]
    col_ind<-which(data_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      #i_lt=2
      ###call translate function
      ###find a solutions
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}