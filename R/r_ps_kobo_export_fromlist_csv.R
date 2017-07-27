#----export KoBo form list-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'


#load libraries and additional functions from r_ps_kobo_library_init.R

#-----------export formlist in CSV format----------------
csv_link <- "https://kc.humanitarianresponse.info/api/v1/data.csv"
save_fname <- paste0("./data/","formlist_csv.csv")
d_formlist_csv<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
write_csv(d_formlist_csv,save_fname)
#export filename as XLSX
save_fname_xlsx<-paste0("./data/",kobo_user,"_formlist.xlsx")
write.xlsx2(d_formlist_csv,save_fname_xlsx,sheetName = "formlist")


