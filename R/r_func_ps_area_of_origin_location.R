location_area_of_origin<-function(db_location){
    d<-"a"
    i_cf_level<-conv_num(db_location$cf_level)
    #ldt<- filter(db_location,!is.na(admin1name_aoo)|!is.na(admin2name_aoo)|!is.na(admin3name_aoo))
    ldt<-na.omit(db_location)
    ldt<-ldt %>% group_by(agg_pcode,admin1name_aoo,admin2name_aoo,admin3name_aoo)%>%
      summarise(cf_level=sum(cf_level,na.rm=TRUE)) %>%
      ungroup()
    ldt<-as.data.table(ldt)
    d<-ldt[,rank:=rank(-cf_level,ties.method = 'min'), by = agg_pcode]
    #now select rank 1 only
    d<-as.data.table(filter(d,rank<6))
    d[,n_samerank := .N, by = agg_pcode]
    #change to no_consensus if two rows are ranked same
    #d[d$n_samerank > 1,2]<-"No_Consensus"
    #Get UNIQUE here
    d<-unique(d[,1:4])
    #db_agg<-left_join(db_agg,d,by=agg_geo_colname)
    rm(list=c("ldt","d"))
    return(d)
}