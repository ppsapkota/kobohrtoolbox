#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'
#rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
#1---------------------CREATE DICTIONARY---------------------
#####--ONE TIME RUN---------
#xlsform_name<-"./xlsform/kobo_master_v7.xlsx"
xlsform_name<-"./xlsform/MSNA2019_KI_PR/MSNA2019_KI_Protection_Kobo_file_V3.xlsx"
#xlsform_name<-"./xlsform/kobo_master_v7_protection_wcase.xlsx"
#form_file_name <- xlsform_name
#create dictionary from the ODK/XLSFORM design form
kobo_dico(xlsform_name)


      

