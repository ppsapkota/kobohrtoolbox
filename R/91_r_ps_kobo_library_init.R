#load libraries
library(httr)
library(jsonlite)
library(lubridate)
library(tidyverse)
library(stringr)
library(readxl) #read excel file
library(dplyr)
library(ggplot2)
library(rgdal)
#library(xlsx) #write.xlsx2
library(openxlsx) #'write xlsx'
#library(XLConnect) #for big file to write


library(data.table)


#load file r_kobo_utils.R file first
options(java.parameters = "-Xmx6000m")
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")
Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")
Sys.getenv("R_ZIPCMD","zip")

source("./R/r_ps_kobo_authenticate.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")
source("./R/r_func_ps_kobo_dico.R")
source("./R/r_func_ps_recode_from_odk.R")
source("./R/r_func_ps_recode_metadata_odk.R")
source("./R/r_func_ps_split_select_one.R")
source("./R/r_func_ps_select_multiple_score2zo.R")
source("./R/r_func_ps_recode_ordinal_odk.R")
source("./R/r_func_ps_area_of_origin_location.R")
source("./R/r_func_ps_protection_gender_all_transfer.R")

path <- Sys.getenv("PATH")
Sys.setenv("PATH" = paste(path, "C:/Rtools/bin", sep = ";"))

tempfile(tmpdir="C:/Users/PSAPKOTA/Documents/R/TempData")




