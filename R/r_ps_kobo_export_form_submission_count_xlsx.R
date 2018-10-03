#----export KoBo form submission count per form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 27 July 2017
----'

#load libraries and additional functions from r_ps_kobo_library_init.R

#-----------export formlist in XLSX format----------------
#csv_link<-'https://kc.humanitarianresponse.info/api/v1/forms.csv'
csv_link<-paste0(kc_server_url,"api/v1/forms.csv")
save_fname <- paste0("./data/",kobo_user,"_formlist_details.xlsx")
d_formlist<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
#--remove some fields
d_formlist<-d_formlist %>% 
            select(date_created,date_modified, description, downloadable, formid,id_string,last_submission_time,num_of_submissions,submission_count_for_today,title,url,uuid) %>% 
            filter(downloadable=="True")

d_formlist$download<-"YES"

write.xlsx(d_formlist,save_fname,sheetName = "formlist")


