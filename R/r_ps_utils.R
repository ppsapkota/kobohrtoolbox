#------------HR.info----KoBo data Access-------
'----------------------------------------------
Developed by: Punya Prasad Sapkota
Last Modified: 11 July 2017
-----------------------------------------------'

#merging multiple files in a a folder
multi_files_merge_csv = function(mypath){
  #mypath <- datawd_csv
  filenames=list.files(path=mypath, full.names=TRUE, pattern = "*.csv")
  #all_files <- lapply(filenames, function(x) {read_csv(x)})
  all_files <- lapply(filenames, function(x) {read_csv(x,col_types = cols(Q_E_Q_E6=col_character()))})
  all_files_merged <-Reduce(bind_rows,all_files)
  #returns the merged dataframe
}
