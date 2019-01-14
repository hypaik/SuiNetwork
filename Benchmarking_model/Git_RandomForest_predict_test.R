#Random forest prediction
#require('randomForest')
library(ggplot2)
library(randomForest)
library(ROCR)

setwd("[a full path directory for K-fold cross validation]")
outdir="[a full path directory for the prediction results for K-fold corss validation]"
K=10 #K-fold, K=10

#out file 1: raw results of prediction_binary
#out file 2: roc_curve_overlaying 10 fold (sensitivity, specificity, accuracy, NPV, PPV) at 0.5 threshold
outFile_perf=paste(outdir,"rfPerform_bin", sep="")
outFile_pred=paste(outdir,"rfPredRaw_bin", sep="")
perfBin_print=data.frame(K=numeric(),sensitivity_recall_tpr=numeric(), specificity=numeric(), ppv_precision=numeric(), npv=numeric(), accuracy=numeric(), auc=numeric())
predBin_print=data.frame(K=numeric(), Idnum=character(), target=numeric(), predic_bin=numeric())
for(i in seq(1:K)){
  print(i)
  
  #1) training/test data load in K fold: eg. 1_train, 2_train.... 10_train
  tr_i= read.table(paste(i,"train",sep="_"), header=T, sep="\t", quote="", na.strings = c(""))
  
  tr_i$CSSRfatalityBinary=as.factor( tr_i$CSSRfatalityBinary) #for binary classification (predic val = 0 or 1)
  
  te_i= read.table(paste(i,"test",sep="_"), header=T, sep="\t", quote="", na.strings = c(""))
  te_i$CSSRfatalityBinary=as.factor(te_i$CSSRfatalityBinary)
  #2) data training
  rf_tr_i<-randomForest(CSSRfatalityBinary ~ ., data=tr_i[,2:(ncol(tr_i))], importance=TRUE, proximity=TRUE, ntree=500) #format for classofication
  
  #3) prediction w/ training set
  rf_te_i.pred <-predict(rf_tr_i, te_i)
  data.frame(Idnum=te_i$Idnum, target = te_i$CSSRfatalityBinary, predicted = rf_te_i.pred)
  pred.obj=prediction(as.numeric(as.vector(rf_te_i.pred)), as.numeric(te_i$CSSRfatalityBinary))
  #perf <- performance( pred.obj, "tpr", "fpr" )
  #plot( perf )
  performance(pred.obj, measure="auc")@y.values
  #unlist(performance(pred.obj, measure="sens")@y.values)[2] #sensitivity
  #unlist(performance(pred.obj, measure="spec")@y.values)[2] #specificity
  #unlist(performance(pred.obj, measure="ppv")@y.values)[2] #specificity

  perfBin_print=rbind(perfBin_print, data.frame(K=i,sensitivity_recall_tpr=unlist(performance(pred.obj, measure="sens")@y.values)[2], specificity=unlist(performance(pred.obj, measure="spec")@y.values)[2], 
                                                ppv_precision=unlist(performance(pred.obj, measure="ppv")@y.values)[2], npv=unlist(performance(pred.obj, measure="npv")@y.values)[2], 
                                                accuracy=unlist(performance(pred.obj, measure="acc")@y.values)[2], auc=unlist(unlist(performance(pred.obj, measure="auc")@y.values))
  ))
  
  predBin_print=rbind(predBin_print, data.frame(K=i, Idnum=te_i$Idnum, target=te_i$CSSRfatalityBinary, predic_bin=rf_te_i.pred))
  
  outFile_model=paste(paste(outdir,"rfModel_bin", sep=""), i, sep="")
  save(rf_te_i.pred,file = paste(outFile_model,"RData", sep=".")) #save the Random Forest model as RData
  
}
write.table(file=outFile_perf, perfBin_print, quote=FALSE, row.names = FALSE, col.names = TRUE, sep="\t", append=FALSE )
write.table(file=outFile_pred, predBin_print, quote=FALSE, row.names= FALSE, col.names=TRUE, sep="\t", append=FALSE)


assign("last.warning", NULL, envir = baseenv())

options(warn=0)