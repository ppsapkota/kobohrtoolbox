#fields_i<-c("var1", "var2")

calculate_confidence_level<-function(data_i, fields_i, dico_i){
  
  dc_ki_info<-as.data.frame(data_i[,fields_i])
  dc_ki_info<-assign_metadata_score_bylabel(dc_ki_info,dico)
  dc_ki_info<-as.data.frame(sapply(dc_ki_info,as.numeric))
  #
  d_cf_level<-dc_ki_info %>% 
              mutate(cf_level=rowSums(.[,1:ncol(dc_ki_info)],na.rm=TRUE)) %>% 
              mutate(cf_level=ifelse(is.nan(cf_level)|cf_level==0,NA,cf_level)) %>% 
              select(cf_level)
#
 return(d_cf_level)  
}


