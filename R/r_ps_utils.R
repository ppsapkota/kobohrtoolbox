#------------HR.info----KoBo data Access-------
'----------------------------------------------
Developed by: Punya Prasad Sapkota
Last Modified: 11 July 2017
-----------------------------------------------'

#merging multiple files in a a folder
multi_files_merge_csv = function(mypath){
  #mypath <- datawd_csv
  filenames=list.files(path=mypath, full.names=TRUE, pattern = "*.csv")
  all_files <- lapply(filenames, function(x) {read.csv(x,na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)})
  all_files_merged <-Reduce(bind_rows,all_files)
  #returns the merged dataframe
  return(all_files_merged)
}


#create roundup function	
round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5   
  z = trunc(z)
  z = z/10^n
  z*posneg
}	


#function coerce to numbers
conv_num<-function(x){as.numeric(as.character(x))}

#replace some funny characters 
replace_chars_incol <- function(db,colname){
  db$colname<-str_replace_all(db$colname,c('\\.'='_','\\*'='','\\:'='','/'='','\\?'=''))
}
