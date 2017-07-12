#------------HR.info----KoBo data Access-------
'----------------------------------------------
Developed by: Punya Prasad Sapkota
Last Modified: 11 July 2017
-----------------------------------------------'
#supply url
#user names and password to be loaded from external authenticate file - this approach to be checked
kobohr_getforms <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
}

kobohr_getforms_csv <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n\n")
  d_content_csv <-read_csv(content(rawdata,"raw",encoding = "UTF-8"))
}


kobohr_getdata<-function(url,u,pw){
  #supply url for the data
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n\n")
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
}

kobohr_getdata_csv<-function(url,u,pw){
  #supply url for the data
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n\n")
  d_content <- read_csv(content(rawdata,"raw",encoding = "UTF-8"))
}

f_csv <- function(x) {
  setDT(read_csv(content(x, "raw")))[]
}

#merging multiple files in a a folder
multi_files_merge_csv = function(mypath){
  #mypath <- datawd_csv
  filenames=list.files(path=mypath, full.names=TRUE, pattern = "*.csv")
  #data = lapply(filenames, function(x){read.csv(file=x, header=TRUE)})
  #Reduce(function(x,y) {merge(x,y)}, data)
  #all_files <- Reduce(rbind, lapply(filenames, function(x) data.frame({unname(read.csv(file=x, header=TRUE))})))
  all_files <- lapply(filenames, function(x) {read_csv(x)})
  all_files_merged <-Reduce(bind_rows,all_files)
}
