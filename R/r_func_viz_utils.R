###-------Heat Map-------------------
draw_heatmap<-function(d_,x_,y_,value,title_i){
  #value<-"n_records"
  base_size <- 9
  p<- ggplot(data = d_,aes_string(x =x_, y =y_)) +
    geom_tile(aes_string(fill=value),colour = "white")+
    geom_text(aes_string(label=value))+
    coord_fixed(expand = TRUE) +
    scale_fill_gradient(low = "lightblue", high = "steelblue")
  
  heatmap<- p + 
    theme_grey(base_size = base_size) + 
    labs(title=title_i)+
    scale_x_discrete(expand = c(0, 0),position = "top") +
    scale_y_discrete(expand = c(0, 0)) + 
    theme(axis.text.x = element_text(size = base_size*0.8, angle = 90, hjust = 0, colour = "grey50"))+
    theme(legend.position="none")
  
  heatmap
  return(heatmap)
}

###------------------------------------------------###
##d_i<-data (summarise data table)
##x_i<-x field
##y_i<-y field
##fill_i<-fill field
##title_i<-title text

draw_barchart_value<-function(d_i,x_i,y_i,fill_i, title_i){
  ##concat %
  #d_i$freq_percentage_label<-do.call(paste0, c(d_i[y_i],"%"))
  
  #p<-ggplot(data=d_i,aes(x=reorder(variables,freq_percentage), y=freq_percentage, fill=freq_percentage))+
  #  geom_bar(stat="identity", width=0.8, position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda")
  p<-ggplot(data=d_i,aes_string(x=paste0("reorder(",x_i,",",y_i,")"), y=y_i, fill=y_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge(0.5),fill="#9ebcda",colour="#9ebcda")
  
  ##apply legend
  bar_chart<-p+
    theme(legend.position = "none",
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          plot.background = element_rect(fill ="white",colour = NA),
          panel.background = element_rect(fill ="white",colour = NA),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
    )+
    geom_text(aes_string(y=0,label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
    scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
    ylab("mean rank score")
  
  #bar_chart
  return(bar_chart)
}

draw_barchart_facet_value<-function(d_i,x_i,y_i,fill_i, title_i,facet_i){
  ##concat %
  #d_i$freq_percentage_label<-do.call(paste0, c(d_i[y_i],"%"))
  facet_colind<-which(names(d_i) == facet_i)
  names(d_i)[facet_colind]<-"facet_name"
  facet_i<-"facet_name"
  
  #p<-ggplot(data=d_i,aes(x=reorder(variables,freq_percentage), y=freq_percentage, fill=freq_percentage))+
  #  geom_bar(stat="identity", width=0.8, position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda")
  p<-ggplot(data=d_i,aes_string(x=paste0("reorder(",x_i,",",y_i,")"), y=y_i, fill=y_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge(0.5),fill="#9ebcda",colour="#9ebcda")+
    facet_grid(cols=vars(facet_name))
  ##apply legend
  bar_chart<-p+
    theme(legend.position = "none",
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          plot.background = element_rect(fill ="white",colour = NA),
          panel.background = element_rect(fill ="white",colour = NA),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
    )+
    geom_text(aes_string(y=0,label=y_i),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
    scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
    ylab("mean rank score")
  
  #bar_chart
  return(bar_chart)
}


###draw barchart for percentage
draw_barchart_percentage<-function(d_i,x_i,y_i,fill_i, title_i){
  ##concat %
  d_i$freq_percentage_label<-do.call(paste0, c(d_i[y_i],"%"))
  
  #p<-ggplot(data=d_i,aes(x=reorder(variables,freq_percentage), y=freq_percentage, fill=freq_percentage))+
  #  geom_bar(stat="identity", width=0.8, position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda")
  p<-ggplot(data=d_i,aes_string(x=paste0("reorder(",x_i,",",y_i,")"), y=y_i, fill=y_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge(0.5),fill="#9ebcda",colour="#9ebcda")
  
  ##apply legend
  bar_chart<-p+
    theme(legend.position = "none",
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          plot.background = element_rect(fill ="white",colour = NA),
          panel.background = element_rect(fill ="white",colour = NA),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
    )+
    geom_text(aes_string(y=0,label="freq_percentage_label"),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
    scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
    ylab("relative frequencies (%)")
  
  #bar_chart
  return(bar_chart)
}

###draw barchart for percentage
draw_barchart_facet_percentage<-function(d_i,x_i,y_i,fill_i, title_i, facet_i){
  ##concat %
  d_i$freq_percentage_label<-do.call(paste0, c(d_i[y_i],"%"))
  
  facet_colind<-which(names(d_i) == facet_i)
  names(d_i)[facet_colind]<-"facet_name"
  facet_i<-"facet_name"
  #p<-ggplot(data=d_i,aes(x=reorder(variables,freq_percentage), y=freq_percentage, fill=freq_percentage))+
  #  geom_bar(stat="identity", width=0.8, position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda")
  p<-ggplot(data=d_i,aes_string(x=paste0("reorder(",x_i,",",y_i,")"), y=y_i, fill=y_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge(0.5),fill="#9ebcda",colour="#9ebcda")+
    facet_grid(cols=vars(facet_name))
  
  ##apply legend
  bar_chart<-p+
    theme(legend.position = "none",
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          plot.background = element_rect(fill ="white",colour = NA),
          panel.background = element_rect(fill ="white",colour = NA),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
    )+
    geom_text(aes_string(y=0,label="freq_percentage_label"),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
    scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
    ylab("relative frequencies (%)")
  
  #bar_chart
  return(bar_chart)
}


###draw barchart for percentage
draw_barchart_facetplus_percentage<-function(d_i,x_i,y_i,fill_i, title_i, facet_i, agg_i){
  ##concat %
  d_i$freq_percentage_label<-do.call(paste0, c(d_i[y_i],"%"))
  
  facet_colind<-which(names(d_i) == facet_i)
  names(d_i)[facet_colind]<-"facet_name"
  facet_i<-"facet_name"
  #p<-ggplot(data=d_i,aes(x=reorder(variables,freq_percentage), y=freq_percentage, fill=freq_percentage))+
  #  geom_bar(stat="identity", width=0.8, position=position_dodge(0.8),fill="#9ebcda",colour="#9ebcda")
  p<-ggplot(data=d_i,aes_string(x=paste0("reorder(",x_i,",",y_i,")"), y=y_i, fill=y_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge(0.5),fill="#9ebcda",colour="#9ebcda")+
    facet_grid(cols=vars(facet_name))
  
  ##apply legend
  bar_chart<-p+
    theme(legend.position = "none",
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          plot.background = element_rect(fill ="white",colour = NA),
          panel.background = element_rect(fill ="white",colour = NA),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
    )+
    geom_text(aes_string(y=0,label="freq_percentage_label"),hjust=-0.5, vjust=0.5, size = 3, color = "grey20")+
    scale_x_discrete(labels=function(x){str_wrap(x,width = 50)})+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
    ylab("relative frequencies (%)")
  
  #bar_chart
  return(bar_chart)
}







###------------------------------------------------###
draw_barchart_faceted<-function(d_i,x_i,y_i,fill_i, title_i, facet_i){
  p<-ggplot(data=d_i, aes_string(x=x_i, y=y_i, fill=fill_i))+
    geom_bar(stat="identity", width=0.8, position=position_dodge())
  
  bar_chart<-p+
    theme(legend.position = "top")+
    geom_text(aes_string(label =y_i),hjust=-0.3, vjust=0.5, size = 3, color = "grey20", position=position_dodge(0.9))+
    coord_flip()+
    labs(title=title_i)
  bar_chart
  return(bar_chart)
}




###----------------------------------------####
draw_barchart_stacked<-function(d_i,x_i,y_i,fill_i, title_i){
  #--get cumulative sum for label
  d_i<-d_i %>% 
       group_by_(x_i) %>%  
       arrange_(x_i,fill_i) %>% 
       rename_("value_i"=y_i)%>% #"value_i #had to do it because of mutate cumsum function"    
       mutate(value_i_cs=cumsum(value_i)-0.5*value_i)
  y_i<-"value_i" #had to do it because of mutate cumsum function
  #--plot--
  p<-ggplot(data=d_i, aes_string(x=x_i, y=y_i, fill=fill_i))+
     geom_bar(stat="identity", width=0.8)
  
  bar_chart<-p+
    theme(legend.position = "top")+
    geom_text(aes_string(label =y_i, y="value_i_cs"),hjust=1.5, vjust=0.5, size = 3, color = "grey20")+
    coord_flip()+
    labs(title=str_wrap(title_i,width=30))+
  bar_chart
  return(bar_chart)
}

#####---------------------DATA-------------------------#####
###----------------------------------------------------###
agg_data_facet_select_one<-function(db,data_geo_level,agg_geo_level,facet_col_name, vn_gname){
  ##get the data
  d_viz_so<-db %>% select_at(vars(data_geo_level,agg_level_colnames,vn_gname))
  
  #get total records
  ##Alternate method
  total_responses<-d_viz_so %>%
                   select_at(vars(data_geo_level)) %>% 
                   distinct() %>% 
                   nrow()
  
  #For facet total
  d_facet_total_responses<- d_viz_so %>% 
                            na.omit() %>%
                            select_at(vars(data_geo_level,facet_col_name)) %>% 
                            distinct() %>% 
                            group_by_at(vars(facet_col_name)) %>% 
                            summarize(total_responses=n()) %>% 
                            arrange(desc(total_responses)) %>% 
                            ungroup()
                    
  #
  d_viz<- d_viz_so %>%
          select_at(vars(data_geo_level,facet_col_name, vn_gname)) %>% 
          na.omit() %>% 
          group_by_at(vars(facet_col_name, vn_gname)) %>% 
          summarize(freq_count=n()) %>% 
          left_join(d_facet_total_responses,by=facet_col_name) %>% 
          mutate(freq_percentage=round(freq_count/total_responses,2)*100) %>% 
          arrange(desc(freq_count)) %>% 
          ungroup() 
  
  i_colind<-which(names(d_viz)==vn_gname)
  names(d_viz)[i_colind]<-"variables"
  #
  x_i<-"variables" #column name
  y_i<-"freq_percentage" #column name
  fill_i<-"freq_percentage"
  #title_i<- paste0(str_wrap(vn_title, width=50),"\n",vn_dcol)
  title_i<- paste0(str_wrap(vn_title, width=50))
  #
  #--plot--
  bar_chart_facet<-draw_barchart_facet_percentage(d_viz,x_i,y_i,fill_i=y_i, title_i,facet_i = facet_col_name)
  bar_chart_facet
  #
  doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
  doc<-body_add_table(doc,d_facet_total_responses, style = "table_template")
  ##print in the file
}

###----------------------------------------------------###
agg_data_facet_select_multiple<-function(db,data_geo_level,agg_geo_level,facet_col_name, vn_gname){
  ##frequency
  f<-c(data_geo_level,agg_geo_level,facet_col_name)
  col_ind_f<-which(names(db) %in% f)
  #
  col_ind_i<-which(str_detect(names(db),vn_gname))
  
  d_viz_sm<-db %>% select(col_ind_f, col_ind_i)
  #
  d_viz<-d_viz_sm %>% gather(key="key",value="value",(length(col_ind_f)+1):ncol(d_viz_sm))
  d_viz$key<-str_remove_all(d_viz$key,vn_gname)
  d_viz$key<-gsub("_","/",d_viz$key)
  
  ###calculate number of responses
  total_responses<- d_viz %>% 
                    na.omit() %>%
                    filter(value>0|str_to_lower(value)=="true"|value=="1") %>%  
                    select_at(vars(data_geo_level)) %>% 
                    distinct() %>% 
                    nrow()
  
  ##total responses by facet
  d_facet_total_responses<- d_viz %>% 
                            na.omit() %>%
                            filter(value>0|str_to_lower(value)=="true"|value=="1") %>%  
                            select_at(vars(data_geo_level, facet_col_name)) %>% 
                            distinct() %>% 
                            group_by_at(vars(facet_col_name)) %>% 
                            summarize(total_responses=n()) %>% 
                            arrange(desc(total_responses)) %>% 
                            ungroup()
  ###
  f<-c(facet_col_name)
  ##BY AGGREGATION LEVEL
  d_viz_agg<- d_viz %>% 
              na.omit() %>% 
              filter(value>0|str_to_lower(value)=="true"|value=="1") %>% 
              group_by_at(vars(f,"key")) %>% 
              summarize(freq_count=n()) %>% 
              left_join(d_facet_total_responses,by=f) %>% 
              mutate(freq_percentage=round(freq_count/total_responses,2)*100) %>% 
              ungroup() %>% 
              arrange(desc(freq_count)) 
  
  
  d_viz_agg_freq_count<-d_viz_agg %>% select(-freq_percentage) %>% spread(key=key,value=c(freq_count),fill=0)
  #d_viz_agg_freq_count<-d_viz_agg_freq_count %>% left_join(d_total_responses_agg_level,by=f)
  
  #
  
  d_viz_agg_freq_percentage<-d_viz_agg %>% select(-freq_count) %>% spread(key=key,value=c(freq_percentage),fill=0)
  #d_viz_agg_freq_percentage<-d_viz_agg_freq_percentage %>% left_join(d_total_responses_agg_level,by=f)
  
  #
  i_colind<-which(names(d_viz_agg)=="key")
  names(d_viz_agg)[i_colind]<-"variables"
  
  ###print only of it has records
  if (nrow(d_viz_agg)>0){
    ##Alternate method
    #f_count <- table(d_viz)
    x_i<-"variables" #column name
    y_i<-"freq_percentage" #column name
    fill_i<-"freq_percentage"
    title_i<- paste0(str_wrap(vn_title, width=35))
    facet_i<-facet_col_name
    #--plot--
    ###FACETED
    bar_chart_facet<-draw_barchart_facet_percentage(d_viz_agg,x_i,y_i,fill_i=y_i, title_i,facet_i)
    bar_chart_facet
    #
    doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
    doc<-body_add_table(doc,d_facet_total_responses, style = "table_template")
  }
}

###----------------------------------------------------###
agg_data_facet_select_one_rank<-function(db,data_geo_level,agg_geo_level,facet_col_name, vn_gname){
  ##frequency
  f<-c(data_geo_level,facet_col_name, agg_geo_level)
  col_ind_f<-which(names(db) %in% f)
  #
  col_ind_i<-which(str_detect(names(db),vn_gname))
  
  d_viz_raw<-db %>% select(col_ind_f, col_ind_i)
  #
  d_viz<-d_viz_raw %>% gather(key="key",value="value",(length(col_ind_f)+1):ncol(d_viz_raw))
  d_viz$key<-str_remove_all(d_viz$key,vn_gname)
  d_viz$key<-gsub("_","/",d_viz$key)
  
  ##RANK to SCORE
  d_viz<- d_viz %>% 
          mutate(value=as.numeric(value)) %>% 
          mutate(value_score=(max(value, na.rm = TRUE)-value+1))
  
  #
  ###calculate number of responses
  total_responses<- d_viz %>% 
                    na.omit() %>%
                    select_at(vars(data_geo_level)) %>% 
                    distinct() %>% 
                    nrow()
  
  
  ##total responses by facet
  d_total_responses_facet<- d_viz %>% 
                            na.omit() %>%
                            select_at(vars(data_geo_level, facet_col_name)) %>% 
                            distinct() %>% 
                            group_by_at(vars(facet_col_name)) %>% 
                            summarize(total_responses=n()) %>% 
                            arrange(desc(total_responses)) %>% 
                            ungroup()
  
  
  ###make data ready for bar chart
  f<-c(facet_col_name)
  d_viz_agg<- d_viz %>% 
              na.omit() %>% 
              group_by_at(vars(f,"key")) %>% 
              summarize(value_score=sum(value_score)) %>% 
              left_join(d_total_responses_facet,by=f) %>% 
              mutate(avg_value=round(value_score/total_responses,1)) %>%
              ungroup() %>% 
              arrange(desc(avg_value)) 
  
  d_viz_agg_avg_score<-d_viz_agg %>% select(-value_score,total_responses) %>% spread(key=key,value=c(avg_value),fill=0)
  
  #
  i_colind<-which(names(d_viz_agg)=="key")
  names(d_viz_agg)[i_colind]<-"variables"
  
  ###print only of it has records
  if (nrow(d_viz_agg)>0){
    ##Alternate method
    #f_count <- table(d_viz)
    x_i<-"variables" #column name
    y_i<-"avg_value" #column name
    fill_i<-"avg_value"
    title_i<- paste0(str_wrap(vn_title_full, width=50))
    facet_i<-facet_col_name
    ###FACETED
    bar_chart_facet<-draw_barchart_facet_value(d_viz_agg,x_i,y_i,fill_i=y_i, title_i,facet_i)
    bar_chart_facet
    #
    doc<-body_add_gg(doc,value=bar_chart_facet,style = "Normal")
    doc<-body_add_table(doc,d_total_responses_facet, style = "table_template")
  }
}






