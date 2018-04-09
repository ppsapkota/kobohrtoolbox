#----loading kobo form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'
library(xlsx)
#1---------------------CREATE DICTIONARY---------------------
#####--ONE TIME RUN---------
#xlsform_name<-"./xlsform/kobo_master_v7.xlsx"
xlsform_name<-"./xlsform/Displacement tracking_20180104.xlsx"
#xlsform_name<-"./xlsform/kobo_master_v7_protection_wcase.xlsx"
form_file_name <- xlsform_name
#create dictionary from the ODK/XLSFORM design form
kobo_dico(xlsform_name)


      

