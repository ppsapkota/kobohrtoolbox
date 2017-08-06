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
library(openxlsx) #'write xlsx'
library(xlsx) #write.xlsx2
library(XLConnect) #for big file to write
library(WriteXLS) #another one for big file

library(data.table)


#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")


source("./R/r_ps_kobo_authenticate.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")
source("./R/r_func_ps_kobo_dico.R")
source("./R/r_func_ps_recode_from_odk.R")
source("./R/r_func_ps_recode_metadata_odk.R")