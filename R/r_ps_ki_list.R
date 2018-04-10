'----
Developed by: Punya Prasad Sapkota
Reference: Tool developed by Olivier/REACH
Last modified: 24 Aug 2017
----'

#-----------------AGGREGATION STARTS HERE-------------------------------------------------------------
##-----data preparation---------
#data_fname<-"./Data/100_Aggregation/syria_msna_2018_JOR_DAM_TUR_data_merged_forAggregation.xlsx"
data_fname<-"./Data/100_Aggregation/syria_msna_2018_raw_data_merged_all_20170824_1455hrs.xlsx"


print(paste0("Reading data file - ", Sys.time())) 
data<-read_excel(data_fname,col_types ="text",na='NA')
#data<-read.csv(data_fname,na="NA",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
data<-as.data.frame(data)

##---------confidence level calculation---------
      ki_header<-c("agg_pcode","partner_code","ki_gender","ki_age","dc_modality","ki_type","meta_uuid")
    

    #-InterSector
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_1/Q_K1/Q_K1_A","Q_1/Q_K1/Q_K1_B",	"Q_1/Q_K1/Q_K1_C",	"Q_1/Q_K1/Q_K1_D",	"meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_1/Q_K2_1/Q_K2_A","Q_1/Q_K2_1/Q_K2_B","Q_1/Q_K2_1/Q_K2_C","Q_1/Q_K2_1/Q_K2_D","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_1/Q_K3_1/Q_K3_A","Q_1/Q_K3_1/Q_K3_B","Q_1/Q_K3_1/Q_K3_C","Q_1/Q_K3_1/Q_K3_D","meta/instanceID")]
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      #
      metadata_is<-bind_rows(metadata1,metadata2,metadata3)
      metadata_is$sector<-"intersector"
    #-cccm
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_2/Q_2k_1/Q_2k_1_a","Q_2/Q_2k_1/Q_2k_1_b","Q_2/Q_2k_1/Q_2k_1_c","Q_2/Q_2k_1/Q_2k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_2/Q_2k_2/Q_2k_2_a","Q_2/Q_2k_2/Q_2k_2_b","Q_2/Q_2k_2/Q_2k_2_c","Q_2/Q_2k_2/Q_2k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_2/Q_2k_3/Q_2k_3_a","Q_2/Q_2k_3/Q_2k_3_b","Q_2/Q_2k_3/Q_2k_3_c","Q_2/Q_2k_3/Q_2k_3_d","meta/instanceID")]
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_cccm<-bind_rows(metadata1,metadata2,metadata3)
      metadata_cccm$sector<-"cccm"
    #-education
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_3/Q_3k_1/Q_3k_1_a","Q_3/Q_3k_1/Q_3k_1_b","Q_3/Q_3k_1/Q_3k_1_c","Q_3/Q_3k_1/Q_3k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_3/Q_3k_2/Q_3k_2_a","Q_3/Q_3k_2/Q_3k_2_b","Q_3/Q_3k_2/Q_3k_2_c","Q_3/Q_3k_2/Q_3k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_a","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_b","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_c","Q_3/Q_3k_2/Q_3k_3/Q_3k_3_d","meta/instanceID")]
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_edu<-bind_rows(metadata1,metadata2,metadata3)
      metadata_edu$sector<-"education"
    #-FSS
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_4/Q_4k_1/Q_4k_1_a","Q_4/Q_4k_1/Q_4k_1_b","Q_4/Q_4k_1/Q_4k_1_c","Q_4/Q_4k_1/Q_4k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_4/Q_4k_2/Q_4k_2_a","Q_4/Q_4k_2/Q_4k_2_b","Q_4/Q_4k_2/Q_4k_2_c","Q_4/Q_4k_2/Q_4k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_4/Q_4k_3/Q_4k_3_a","Q_4/Q_4k_3/Q_4k_3_b","Q_4/Q_4k_3/Q_4k_3_c","Q_4/Q_4k_3/Q_4k_3_d","meta/instanceID")]
      #
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_fss<-bind_rows(metadata1,metadata2,metadata3)
      metadata_fss$sector<-"fss"
    #-health
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_5/Q_5k_1/Q_5k_1_a","Q_5/Q_5k_1/Q_5k_1_b","Q_5/Q_5k_1/Q_5k_1_c","Q_5/Q_5k_1/Q_5k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_5/Q_5k_2/Q_5k_2_a","Q_5/Q_5k_2/Q_5k_2_b","Q_5/Q_5k_2/Q_5k_2_c","Q_5/Q_5k_2/Q_5k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_5/Q_5k_3/Q_5k_3_a","Q_5/Q_5k_3/Q_5k_3_b","Q_5/Q_5k_3/Q_5k_3_c","Q_5/Q_5k_3/Q_5k_3_d","meta/instanceID")]
      #
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_health<-bind_rows(metadata1,metadata2,metadata3)
      metadata_health$sector<-"health"
    #-nfishelter
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_a","Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_b","Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_c","Q_6/Q_6k_1/Q_6_group_1/Q_6_group_2/Q_6k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_a","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_b","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_c","Q_6/Q_6k_1/Q_6_group_4/Q_6_group_5/Q_6k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_a","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_b","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_c","Q_6/Q_6k_1/Q_6_group_7/Q_6_group_8/Q_6k_3_d","meta/instanceID")]      
      #
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_nfishelter<-bind_rows(metadata1,metadata2,metadata3)
      metadata_nfishelter$sector<-"nfishelter"
    #-protection
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_7/Q_7k_1/Q_7k_1_a","Q_7/Q_7k_1/Q_7k_1_b","Q_7/Q_7k_1/Q_7k_1_c","Q_7/Q_7k_1/Q_7k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_7/Q_7k_2/Q_7k_2_a","Q_7/Q_7k_2/Q_7k_2_b","Q_7/Q_7k_2/Q_7k_2_c","Q_7/Q_7k_2/Q_7k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_7/Q_7k_3/Q_7k_3_a","Q_7/Q_7k_3/Q_7k_3_b","Q_7/Q_7k_3/Q_7k_3_c","Q_7/Q_7k_3/Q_7k_3_d","meta/instanceID")]
      #
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_prot<-bind_rows(metadata1,metadata2,metadata3)
      metadata_prot$sector<-"protection"
    #-erl
      metadata1<-data[,c("agg_pcode","Q_E/Q_E6","Q_8/Q_8k_1/Q_8k_1_a","Q_8/Q_8k_1/Q_8k_1_b","Q_8/Q_8k_1/Q_8k_1_c","Q_8/Q_8k_1/Q_8k_1_d","meta/instanceID")]
      metadata2<-data[,c("agg_pcode","Q_E/Q_E6","Q_8/Q_8k_2_1/Q_8k_2_a","Q_8/Q_8k_2_1/Q_8k_2_b","Q_8/Q_8k_2_1/Q_8k_2_c","Q_8/Q_8k_2_1/Q_8k_2_d","meta/instanceID")]
      metadata3<-data[,c("agg_pcode","Q_E/Q_E6","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_a","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_b","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_c","Q_8/Q_8k_2_1/Q_8k_3_1/Q_8k_3_d","meta/instanceID")]
      #
      #rename header for consistency
      names(metadata1)<-ki_header
      names(metadata2)<-ki_header
      names(metadata3)<-ki_header
      metadata_erl<-bind_rows(metadata1,metadata2,metadata3)
      metadata_erl$sector<-"erl"
      
      metadata_all<-bind_rows(metadata_is,
                              metadata_cccm,
                              metadata_edu,
                              metadata_fss,
                              metadata_health,
                              metadata_nfishelter,
                              metadata_prot,
                              metadata_erl)
      write_csv(metadata_all,"./Data/100_Aggregation/msna_ki_metadata.csv")
      
      			
      
      
      
      
      