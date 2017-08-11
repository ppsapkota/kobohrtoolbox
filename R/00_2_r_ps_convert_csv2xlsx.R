
d_path = "./Data/01_Download_CSV"
##-----------covert files to csv------------------
 filenames=list.files(path=d_path, full.names=TRUE, pattern = "*.csv")
 db <- lapply(filenames, function(x){readCSVwriteXLSX(x)})
