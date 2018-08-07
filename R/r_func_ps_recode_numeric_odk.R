# Recode -1 and -5 to NA in numeric questions
#
# Args:
#     data1: main data
#     choices1: kobo choices 
#
# Returns:
#     recoded dataset

recode_numeric_question <- function(data1, choices1) {
  print(paste0("Recode -1 and -5 to NA in numeric questions"))
  
  data_names<-names(data1)
  #-select all the field headers for select one
  ch_s1<-filter(choices1,qtype=="integer" | qtype=="decimal")
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  for(i in 1:nrow(ch_s1_headers)){
    #column index from the data
    i_headername<-ch_s1_headers[i,1]
    col_ind<-which(data_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
          #i_lt=2
          data_rec[,col_ind]<-ifelse(as.numeric(data_rec[,col_ind])== -1 | as.numeric(data_rec[,col_ind])== -5,NA,data_rec[,col_ind])
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
NULL

