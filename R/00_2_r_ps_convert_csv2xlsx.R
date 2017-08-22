
d_path = "./Data/02_Convert_to_XLSX"
##-----------covert files to csv------------------
 filenames=list.files(path=d_path, full.names=TRUE, pattern = "*.csv")
 db <- lapply(filenames, function(x){readCSVwriteXLSX(x)})
