
d_path = "./data/data_export_csv"
##-----------covert files to csv------------------
 filenames=list.files(path=d_path, full.names=TRUE, pattern = "*.xlsx")
 db <- lapply(filenames, function(x){readXLSXwriteCSV(x)})
