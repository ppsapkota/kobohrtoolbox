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

#----------Export XLSX2CSV -------------#
readXLSXwriteCSV<-function(fname){
  dbc<-read_excel(fname, sheet = 1)
  fname_csv = gsub("\\.xlsx","\\.csv",fname)
  #-----create file path in 'CSV' folder-----
  fname_csv = gsub(basename(fname_csv),paste0("CSV/",basename(fname_csv)),fname_csv)
  write.csv(dbc,file=fname_csv, fileEncoding = "UTF-8",row.names = FALSE)
}

#----------Export CSV2XLSX -------------#
readCSVwriteXLSX<-function(fname){
  dbc<-read.csv(fname,na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
  #dbc<-read_csv(fname, col_types="text")
  fname_xlsx = gsub("\\.csv","\\.xlsx",fname)
  #-----create file path in 'CSV' folder-----
  fname_xlsx = gsub(basename(fname_xlsx),paste0("XLSX/",basename(fname_xlsx)),fname_xlsx)
  write.xlsx2(dbc,file=fname_xlsx, row.names = FALSE)
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


### write big excel
wbig.xlsx<-function(db,filen,sheetname){
  newWB <- loadWorkbook(filen,create=TRUE)	
  createSheet(newWB,name=sheetname)
  tot.rows <- nrow(db)
  last.row =0
  for (i in seq(ceiling( tot.rows / 1) )) {
    if(i==1){
      writeWorksheet(newWB, db[i,],sheet=sheetname,header=TRUE, startRow=i)
    }else{
      writeWorksheet(newWB, db[i,], sheet=sheetname, header=FALSE, startRow=i+1)
    }
    print(i)
    saveWorkbook(newWB)
  }
} 


