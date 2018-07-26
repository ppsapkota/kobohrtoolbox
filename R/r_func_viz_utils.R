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
draw_barchart_dodge<-function(d_i,x_i,y_i,fill_i, title_i){
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

###------------------------------------------------###
draw_barchart_dodge_faceted<-function(d_i,x_i,y_i,fill_i, title_i, facet_i){
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
    labs(title=title_i)
  bar_chart
  return(bar_chart)
}