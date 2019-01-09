setwd("[your home directory]")


library(bnstruct) #for KNN imputation with categorical and continuous variables 
myData=read.table("[your matrix data from suicide attempters=MYDATA.raw]", header=T, sep="\t", na.strings = c(''))
#This is an example head line of matrix we will use.
#colnames(myData)
#[1] "region"                             "Idnum"                              "ER_visit_date(YYYY-MM-DD)"                      "ER_visit_hour"                      "ER_visit_minutes"                   "sex"                               
#[7] "year_of_birth"                      "age"                                "marital_status"                     "education"                          "occupation"                         "religion"                          
#[13] "monthly_income"                     "living_status"                      "urbanicity"                         "admission_route"                    "admission_transportation"           "mental_status_admission"           
#[19] "physical.illness"                   "pain_scale_of_physical_illness"     "history_of_psychiatric_disease"     "history_of_psychiatric_treatment"   "history_of_psychiatric_treatment.2" "history_of_psychiatric_ward"       
#[25] "history_of_suicide_attempts"        "number_of_suicide_attempts"         "CSSRS_idea_screening1"              "CSSRS_idea_screening2"              "CSSRS_idea1"                        "CSSRS_idea2"                       
#[31] "CSSRS_idea3"                        "CSSRS_severity_start_year"          "CSSRS_severity_start_month"         "CSSRS_severity_start_day"           "CSSRS_severity_weeksago"            "CSSRS_severity_months_ago"         
#[37] "CSSRS_severity_frequency"           "CSSRS_severity_duration"            "CSSRS_severity_controllable"        "CSSRS_severity_stop"                "CSSRS_severity_reason"              "CSSRS_behavior"                    
#[43] "CSSRS_fatality"                     "CSSRS_potential_fatality"           "SIS1"                               "SIS2"                               "SIS3"                               "SIS4"                              
#[49] "SIS5"                               "SIS6"                               "SIS7"                               "SIS8"                               "SIS9"                               "SIS10"                             
#[55] "SIS11"                              "SIS12"                              "SIS13"                              "SIS14"                              "SIS15"                              "outcome"                           
#[61] "injection"                          "medication"                         "discharge_date"                     "discharge_day"                      "Final.diagnosis"                    "isFirstAttempt"                    
#[67] "ER_visit_time24"                    "Discharge_dateReshape"              "marital_statusReshape"              "educationReshape"                   "admission_routeReshape"             "ER_visit_date_isweekend(Y/N)"

#category of info
#cat 1) SIS1~8: objective measure of SIS
#cat 2) SIS9~15+NA: self measure of SIS
#cat 3) demography: sex, age, marital_statusReshape, religion, monthly_income, livig_status, educationReshape, urbanicity
#cat 4) ER collected info: ER_visit_date, ER_visit_date_isweekend, ER_visit_time24, admission_route, admission_transportation, Discharge_dateReshape

myData.trim=data.frame(Idnum=as.character(myData$Idnum), 
                       sex=myData$sex, age=myData$age, 
                       marital_statusReshape=myData$marital_statusReshape, religion=myData$religion, 
                       monthly_income=myData$monthly_income, livig_status=myData$living_status, 
                       educationReshape=myData$educationReshape, urbanicity=myData$urbanicity,
                       ER_visit_date=myData$ER_visit_date, ER_visit_date_isweekend=as.numeric(myData$ER_visit_date_isweekend), 
                       ER_visit_time24=myData$ER_visit_time24, admission_route=myData$admission_routeReshape, 
                       admission_transportation=myData$admission_transportation, Discharge_dateReshape=myData$Discharge_dateReshape,
                       SIS1=myData$SIS1, SIS2=myData$SIS2, SIS3=myData$SIS3, SIS4=myData$SIS4, SIS5=myData$SIS5, SIS6=myData$SIS6, SIS7=myData$SIS7, SIS8=myData$SIS8,
                       SIS9=myData$SIS9, SIS10=myData$SIS10, SIS11=myData$SIS11, SIS12=myData$SIS12, SIS13=myData$SIS13, SIS14=myData$SIS14, SIS15=myData$SIS15,
                       CSSRS_fatality=myData$CSSRS_fatality)

myData.trim.DateNorm=myData.trim
#Date type --> as numeric + normalize
#initYr=2013
#initYr+((abs(as.Date("2013-01-01", format="%Y-%m-%d")-as.Date(myData.trim$ER_visit_date)))-0.5)/365

myDateNorm<-function(initYr, curruntDate, leapYrFlag){
  normDate=NA
  if(is.na(leapYrFlag)!=TRUE){
    if(leapYrFlag==TRUE){
      leapYrFlag=1
    }else{
      leapYrFlag=0
    }
    firstDate=paste(as.character(initYr),"01-01",sep="-")
    normDate=initYr+((as.numeric(abs(as.Date(firstDate,fromat="%Y-%m-%d")-as.Date(curruntDate)))-0.5)/365)
  }
  return(as.numeric(normDate))
}
initYr=2013 ##The initial Year of your study set, such as 2018
leapYrFlag=FALSE ##If the data was recorded across two year, it the value of leapYrFlag is 'TRUE'.

#For the date and time normalization
#Raw format of date (YYYY-MM-DD); normalized within [0,1]
#Raw format of time (0~24); normalized within [0,1]
myData.trim.DateNorm$ER_visit_date= myDateNorm(initYr, myData.trim.DateNorm$ER_visit_date, leapYrFlag)
myData.trim.DateNorm$Discharge_dateReshape= myDateNorm(initYr, myData.trim.DateNorm$Discharge_dateReshape, leapYrFlag)
myData.trim.DateNorm$ER_visit_time24= as.numeric(abs(difftime(strptime("00:00:00",format="%H:%M:%S"), strptime(myData.trim$ER_visit_time24, format="%H:%M:%S"), units="mins")))/(24*60)

assign("last.warning", NULL, envir = baseenv())

write.table(file="[your date normalized matrix=MYDATA.raw_dateTimeNorm]", myData.trim.DateNorm, row.names = FALSE, col.names = TRUE, quote=FALSE, append=FALSE, sep="\t")
myData.trim.DateNorm=read.table("[your date normalized matrix=MYDATA.raw_dateTimeNorm]", header=T, sep="\t", na.strings=c(''), quote="", stringsAsFactors = FALSE)
myData.trim.DateNorm.mat=as.matrix(as.data.frame(lapply(myData.trim.DateNorm[,2:ncol(myData.trim.DateNorm)], as.numeric)))
rownames(myData.trim.DateNorm.mat)= myData.trim.DateNorm$Idnum

#column indices of categorical data
#sex(1), marital_statusReshape(3), religion(4), living_status(6), educationReshape(7), urbanicity(8), ER_visit_date_isweekend(10), admission_route(12), admission_transportation(13)
#educationReshape(7) is not a categorical data. (0:no_education --> 6: higher education.) So, it's a quantitative measure as integer scale. 
catVarCol=c(1,3,4,6,8,10,12,13)
myData.trim.DateNorm.mat[,catVarCol]

#KNN impute
myData.trim.DateNorm.mat.imput=knn.impute(myData.trim.DateNorm.mat, k=10, cat.var=catVarCol) #You can change the value of k.
myData.trim.DateNorm.mat.imput_round=myData.trim.DateNorm.mat.imput
#rounding as integer (SIS columns, educationReshape)
roundingColname=c("educationReshape", "SIS1", "SIS2", "SIS3", "SIS4", "SIS5", "SIS6", "SIS7", "SIS8", "SIS9", "SIS10", "SIS11", "SIS12", "SIS13", "SIS14", "SIS15", "CSSRS_fatality")
for (r in roundingColname){
  print(r)
  myData.trim.DateNorm.mat.imput_round[,r]=round(myData.trim.DateNorm.mat.imput[,r])
}

write.table(file="[your date normalized matrix& KNN imputed results=MYDATA.raw_dateTimeNorm_KNN]", myData.trim.DateNorm.mat.imput_round, 
            row.names = TRUE,  quote=FALSE, append=FALSE, sep="\t", col.names=NA)


#Those lines are for the confirmation of the KNN imutation results############################################################
#x=knn.impute(myData.trim.DateNorm.mat, k=10, cat.var = c(1,3))
#knn.impute(myData.trim.DateNorm.mat, k=10, cat.var = c(1,3,9))
#x2=knn.impute(myData.trim.DateNorm.mat[,c("Discharge_dateReshape","sex", "admission_route")], cat.var=c(3))
#x3=knn.impute(myData.trim.DateNorm.mat[,c("Discharge_dateReshape","sex", "admission_route")], cat.var=c(1))
#knn.impute(myData.trim.DateNorm.mat, k=10, cat.var = c(1,3,4,7,8,9))
#myData.trim.DateNorm.mat$age
#knn.impute(myData.trim.DateNorm.mat, k=10, cat.var = c(7,8))

