#creates a dataframe by replacing NA to the v_fields
# and to the frame of d_i
get_dataframe_empty_all_rows<-function(d_i, group_fields, v_field){
  #i_vn_cf_level<-vn_cf_level
  f<-c(group_fields,v_field)
  d_e<-d_i %>% 
       select_at(vars(f))
  #find the column index for the current aggregation variable
  v_col_i<-which(names(d_e)==v_field)
  #replace the value 
  d_e[,v_col_i]<-NA
  d_e<-d_e %>%
       group_by_at(f) %>% 
       distinct() %>%
       ungroup() 
  return(d_e)
}

get_empty_dataframe<-function(d_i,fields){
  #check if d does not have rows i.e all NA so omitted in previous step, then create empty data frame
  d_e<-d_i %>% 
       select_at(vars(fields))
  ##keep first row only
  d_e<-d_e[1,]
    #d_e <- data.frame(matrix(vector(),ncol=length(fields)))
    #names(d_e)<-fields
  d_e[1,]<-NA
   return(d_e)  
  }  
NULL