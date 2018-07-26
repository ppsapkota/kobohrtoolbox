#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'
rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
#1---------------------CREATE DICTIONARY---------------------
#####--ONE TIME RUN---------
#xlsform_name<-"./xlsform/kobo_master_v7.xlsx"
xlsform_name<-"./xlsform/ochaMSNA2018v9_master.xlsx"
#xlsform_name<-"./xlsform/kobo_master_v7_protection_wcase.xlsx"
form_file_name <- xlsform_name
#create dictionary from the ODK/XLSFORM design form
kobo_dico(xlsform_name)


      

