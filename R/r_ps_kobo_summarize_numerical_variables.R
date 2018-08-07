'----
Developed by: Punya Prasad Sapkota
Last modified: 5 August 2018
----'
rm(list=ls())
source("./R/91_r_ps_kobo_library_init.R")
source("./R/r_func_ps_kobo_utils.R")
source("./R/r_func_ps_utils.R")

#-------------------------------------#
nameodk<-"./xlsform/ochaMSNA2018v9_master_agg_method.xlsx"
hub<-"NES"
#hub<-"TurkeyXB"

if (hub=="TurkeyXB"){
  #####STEP 2--Merge data---
  t_stamp <- format(Sys.time(),"%Y%m%d_%H%M")
  #
  xlsx_path<-"./Data/01_Download_CSV/"
  save_path<-"./Data/00_Coverage/"
}else if (hub=="NES"){
  #####STEP 2--Merge data---
  t_stamp <- format(Sys.time(),"%Y%m%d_%H%M")
  #
  xlsx_path<-"./Data/01_Download_CSV/NES/"
  save_path<-"./Data/00_Coverage/NES/"
}

###----------merge data-----------------------------------------------------
d_merged<- as.data.frame(files_merge_xlsx(xlsx_path))
#d_merged[is.na(d_merged)] <- 'NA'
###-------read admin list
d_admin4<-read_excel("./Data/Admin/syr_admin_20180701.xlsx",sheet="admin4",col_types = "text")
d_admin4<-select(d_admin4, admin1Name_en,admin2Name_en,admin3Name_en,admin4Name_en,admin4Pcode)
d_merged<-left_join(d_merged,d_admin4, by=c("Q_M/admin4"="admin4Pcode"))

#
save_name<-paste0(save_path,"Numeric_Data_Check.xlsx")

#read data file to recode
data<-d_merged
#some cleanup of the data
for (kl in 1:ncol(data)){
  data[,kl]<-ifelse(data[,kl]=="NA" | data[,kl]=="" | data[,kl]=="NULL" | is.nan(data[,kl]),NA,data[,kl])
}

col_ind<-which(names(data)=="agg_pcode")
if (length(col_ind)==0){
  data$agg_pcode<-ifelse(!is.na(data[,c("Q_M/neighborho")]),data[,c("Q_M/neighborho")],data[,c("Q_M/admin4")])
}

#read ODK file choices and survey sheet
survey<-read_excel(nameodk,sheet = "survey",col_types = "text")  
dico<-read_excel(nameodk,sheet="choices",col_types ="text")

#----------function-------------------------------#
convert_to_numeric_column<-function(data1,choices1){
  print(paste0("Convert to numeric question"))
  ### First we provide attribute label to variable name
  data_names<-names(data1)
  #-select all the field headers for select one
  ch_s1<-filter(choices1,qtype=="integer" | qtype=="double")
  #--loop through all the rows or take all value
  ch_s1_headers<-distinct(as.data.frame(ch_s1[,"gname"]))
  data_rec<-as.data.frame(data1) # dont see any reason to do it
  
  for(i in 1:nrow(ch_s1_headers)){
    #column index from the data
    i_headername<-ch_s1_headers[i,1]
    col_ind<-which(data_names==i_headername)
    #Replace only if header is found in the main data table
    if (length(col_ind)>0){
      f<-c(i_headername)
      data_rec<- data_rec %>% 
        mutate_at(vars(f),funs(as.numeric))
      #class(data_rec[,f])
    }
  }#finish recoding of select one ORDINAL
  return(data_rec)
}
#------------------------------------#
#convert all numeric (integer and double questions to numric field type
data<-convert_to_numeric_column(data,dico)
data_num<-dplyr::select_if(data, is.numeric)

data_num<-cbind(data[,c("agg_pcode","Q_E/Q_E6","admin1Name_en","admin2Name_en","admin3Name_en","admin4Name_en")],data_num)

##remove -1 and -5
 for (kl in 1:ncol(data_num)){
   data_num[,kl]<-ifelse(data_num[,kl]=="NA" | data_num[,kl]=="" | data_num[,kl]==-1 | data_num[,kl]==-5,NA,data_num[,kl])
 }

#agg_geo_field<-c("agg_pcode")
agg_geo_field<-c("agg_pcode","admin1Name_en","admin2Name_en","admin3Name_en","admin4Name_en")
agg_var_field<-c("Q_E/Q_E6")

scol<-length(c(agg_geo_field, agg_var_field))+1

##Creat Excel workbook to save the result
wb<-createWorkbook()

for (i_col in scol:ncol(data_num)){
  #Loop through all numeric column and spread it to the sample
  #i_col<-7
  i_fname<-names(data_num)[i_col]
  f<-c(agg_geo_field,agg_var_field,i_fname)
  d<-data_num %>% select_at(vars(f))
  #
  f1<-c(agg_geo_field,agg_var_field)
  d<-d %>% group_by_at(vars(f1)) %>% 
           summarise_at(vars(i_fname),funs(max)) %>% 
           spread_(key=agg_var_field,value=i_fname) %>% 
           ungroup()
  i_start<-length(agg_geo_field)+1
  i_end<-ncol(d)
  
  d<-d %>% mutate(AVG = rowMeans(.[i_start:i_end], na.rm = TRUE),
                  MIN = do.call('pmin',c(.[,i_start:i_end],na.rm=TRUE)),
                  MAX = do.call('pmax',c(.[,i_start:i_end],na.rm=TRUE))
                  )
  
  #remove NAN
  d<-rapply(d, f=function(x) ifelse(is.nan(x),NA,x), how="replace" )
  
  ###-------ADD VALIDATION RULE---------------##
  
  d$CHECK<-ifelse(d$MAX > d$AVG*2,"CHECK VALUES",NA)
  d<-filter(d, CHECK=="CHECK VALUES" & MAX>5)
  
  ###get question label for the column
  ch_s1<-filter(dico,gname==i_fname)
  q_label<-ch_s1$gname_label[1]
  
  
  #d_$MIN<-do.call('pmin',c(d_[,i_start:i_end],list(na.rm=TRUE)))
  #$MAX<-do.call('pmax',c(d_[,i_start:i_end],list(na.rm=TRUE)))
  #df %>% mutate(Min = pmap(df, min), Mean = rowMeans(.))
  #get field name
  vn_name<-unlist(str_split(i_fname,"/"))
  vn_name<-vn_name[length(vn_name)]##excel sheet name limit
  sheet_name<-str_sub(vn_name,1,13)##excel sheet name limit
  ##add sheet in the excel workbook
  
  ## save for checking only of d has values
  if (nrow(d)>0){
    addWorksheet(wb, vn_name)
    ## 
    writeData(wb, x = i_fname, sheet=sheet_name,startRow = 1)
    writeData(wb, x = q_label, sheet=sheet_name,startRow = 2)
    writeData(wb, x = d, sheet=sheet_name, startRow = 5,withFilter = TRUE)
  }
  
  
}

saveWorkbook(wb, file = save_name, overwrite = TRUE)

# mtcars %>% 
#   group_by(cyl) %>% 
#   summarise_each (funs(mean), mpg, disp)
# with a single group
# 
# mtcars %>% 
#   group_by(cyl) %>% 
#   summarise_each(funs(min, max) , mpg, disp)

# df %>%
#   group_by(category) %>%
#   summarise_all(funs(mean, median, first))
# 
# df %>% 
#   group_by(category) %>% 
#   summarize_at(vars(x, y), funs(min, max))





  