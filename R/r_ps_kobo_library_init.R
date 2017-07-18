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
library(maptools)

#load file r_kobo_utils.R file first
options(stringsAsFactors = FALSE)
#language setting
Sys.setlocale(category = "LC_ALL",locale = "arabic")

source("./R/r_kobo_utils.R")
source("./R/r_ps_kobo_authenticate.R")