
#update CSV file in package
connectionDetails$schema=resultsDatabaseSchema
conn<-connect(connectionDetails)
achilles_analysis<-querySql(conn,'select * from achilles_analysis')
#this line caused issue 151: names(achilles_analysis) <- tolower(names(achilles_analysis))
write.csv(achilles_analysis,file = 'inst/csv/analysisDetails.csv',na = '',row.names = F)
