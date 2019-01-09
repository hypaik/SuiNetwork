#Make test, trainSet for K fold CV
setwd("[your home directory]")
outDir="[full path of directory for the results file]"
myData<-read.table("[name of your input file]", header=F, sep="\t", quote="", skip=1, na.strings = c(""))
head(myData)
headCol=c("Idnum","sex","age","marital_statusReshape","religion","monthly_income","livig_status","educationReshape",
          "urbanicity","ER_visit_date","ER_visit_date_isweekend","ER_visit_time24","admission_route","admission_transportation","Discharge_dateReshape",
          "SIS1","SIS2","SIS3","SIS4","SIS5","SIS6","SIS7","SIS8","SIS9","SIS10","SIS11","SIS12","SIS13","SIS14","SIS15","CSSRS_fatality")
colnames(myData)= headCol #if you has a different column names, please amend 'headCol'
head(myData)
myData$age
myData$CSSRS_fatality= as.numeric(myData$CSSRS_fatality>3)

#data shuffle
myData<-myData[sample(nrow(myData)),]

#Create k(10) equally size folds
k=10
folds <- cut(seq(1,nrow(myData)),breaks=k,labels=FALSE)

#outfile headTag
tePrefix=paste(outDir, "te", sep="")
trPrefix=paste(outDir, "tr", sep="")

#Perform k(10) fold cross validation
for(i in 1:k){
  tePrefix=paste(outDir, "te", sep="")
  trPrefix=paste(outDir, "tr", sep="")
  #Segement your data by fold using the which() function 
  teIndexes <- which(folds==i,arr.ind=TRUE)
  print(paste("!!!!!!indices_te!!!!!!!!", i, sep="!"))
  print(rownames(myData[teIndexes, ]))
  print(paste("#######indices_tr#######", i, sep="#"))
  print(rownames(myData[-teIndexes, ]))
  teData_i <- myData[teIndexes, ] #selet sample 10%
  trData_i<- myData[-teIndexes, ] #selet the rest of sample 90%
  
  #Use the test and train data partitions however you desire...
  
  tePrefix=paste(paste(tePrefix, i, sep=""), "txt", sep=".")
  trPrefix=paste(paste(trPrefix, i, sep=""), "txt", sep=".")
  write.table(file=tePrefix, teData_i, sep="\t", col.names = TRUE, row.names = FALSE, append = FALSE, quote=FALSE)
  write.table(file=trPrefix, trData_i, sep="\t", col.names = TRUE, row.names = FALSE, append = FALSE, quote=FALSE)
}



