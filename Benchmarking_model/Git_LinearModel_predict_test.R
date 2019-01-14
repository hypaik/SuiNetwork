#Random forest prediction
#require('randomForest')
library(ggplot2)
library(randomForest)
library(ROCR)
setwd("[a full path directory for K-fold cross validation]")
outdir="[a full path directory for the prediction results for K-fold corss validation]"
K=10 #K-fold, K=10


#out file 1: raw results of prediction_continuous
#out file 2: roc_curve_overlaying 10 fold (sensitivity, specificity, accuracy, NPV, PPV) at 0.5 threshold
outFile_perf=paste(outdir,"lmPerform_cont_Cut05", sep="") #performance evaluation out file
outFile_pred=paste(outdir,"lmPredRaw_cont", sep="") #prediction score (0.0~ 1.0) of each individual


#for preformance evaluation at 0.5 cut
perfContCut05_print=data.frame(K=numeric(), optCut05=numeric(), sensitivity_recall_tpr=numeric(), specificity=numeric(), ppv_precision=numeric(), npv=numeric(), accuracy=numeric(), auc=numeric())

#for the presentation of predicted values [0~1]
predContCut05_print=data.frame(K=numeric(), Idnum=character(), target=numeric(), predic_cont=numeric(), optCut05_atK=numeric())

roc_multiplotdf05cut=data.frame(K=numeric(), FalsePositive=numeric(), TruePositive=numeric())
for(i in seq(1:K)){
  print(i)
  #1) training/test data load in K fold: eg. 1_train, 2_train.... 10_train
  tr_i= read.table(paste(i,"train",sep="_"), header=T, sep="\t", quote="", na.strings = c(""))
  #tr_i$CSSRS_fatality=as.factor( tr_i$CSSRS_fatality)
  
  te_i= read.table(paste(i,"test",sep="_"), header=T, sep="\t", quote="", na.strings = c(""))
  #te_i$CSSRS_fatality=as.factor(te_i$CSSRS_fatality)
  #2) data training
  lm_tr_i<-lm(CSSRfatalityBinary ~.,  data=tr_i[,2:ncol(tr_i)])
  
  #3) prediction w/ training set
  lm_te_i.pred_cont <-as.vector(predict(lm_tr_i, te_i[,2:ncol(te_i)], type="response"))
  data.frame(Idnum=te_i$Idnum, target = te_i$CSSRfatalityBinary, predicted =lm_te_i.pred_cont)
  pred.obj_bin=prediction(as.vector(as.numeric(lm_te_i.pred_cont>0.5)), as.numeric(te_i$CSSRfatalityBinary))
  #predict(classifier, type="prob")
  
  plot(performance( pred.obj_cont, "tpr", "fpr" ))
  plot(performance( pred.obj_bin, "tpr", "fpr" ))
  
  #get optimized cut [this part is for other threshold between 0 to 1]
  #cost.perf = performance(pred.obj_cont, "cost")
  #optCut_i=pred.obj_cont@cutoffs[[1]][which.min(cost.perf@y.values[[1]])]
  
  performance(pred.obj_bin, measure="auc")@y.values
  
  
  perfContCut05_print=rbind(perfContCut05_print,data.frame(K=i, optCut05=0.5, 
                                                           sensitivity_recall_tpr=performance(pred.obj_bin, measure="sens")@y.values[[1]][2], 
                                                           specificity=performance(pred.obj_bin, measure="spec")@y.values[[1]][2], 
                                                           ppv_precision=performance(pred.obj_bin, measure="ppv")@y.values[[1]][2], 
                                                           npv=performance(pred.obj_bin, measure="npv")@y.values[[1]][2], 
                                                           accuracy=performance(pred.obj_bin, measure="acc")@y.values[[1]][2], 
                                                           auc=performance(pred.obj_bin, measure="auc")@y.values[[1]]))
  
  predContCut05_print=rbind(predContCut05_print, data.frame(K=i, Idnum=te_i$Idnum, target=te_i$CSSRfatalityBinary, predic_cont= lm_te_i.pred_cont, optCut05_atK=0.5))
  
  roc_multiplotdf05cut=rbind(roc_multiplotdf05cut, data.frame(K=i, FalsePositive=performance(pred.obj_bin, measure="fpr")@y.values[[1]], TruePositive=performance(pred.obj_bin, measure="tpr")@y.values[[1]]))
  
  outFile_model=paste(paste(outdir,"lmModel_cont", sep=""), i, sep="")
  save(lm_te_i.pred_cont,file = paste(outFile_model,"RData", sep=".")) #save the linear regression model as RData
  
}

ggplot(roc_multiplotdf05cut, aes(x=FalsePositive, y=TruePositive, color=K)) + geom_line()

write.table(file=outFile_perf, perfContCut05_print, quote=FALSE, row.names = FALSE, col.names = TRUE, sep="\t", append=FALSE )
write.table(file=outFile_pred, predContCut05_print, quote=FALSE, row.names= FALSE, col.names=TRUE, sep="\t", append=FALSE)


assign("last.warning", NULL, envir = baseenv())
#options(warn=0)