#Project title: SuiNetwork#######
Network-based analysis to predict and understand suicide fatality

Authors of source code: hyojungpaik@gmail.com, polord@gmail.com
Current version of the project: ver. 0.1

#Prerequisites#######
0. R version 3.3.2 -- "Sincre Pumpkin Patch"
1. Python version 2.7.15 
2. Tensorflow --- www.tensorflow.org
3. Data of ours in matrix format. 

#License#########
The development of source codes are funded by National Supercomputing Center included resources and technology (K-18-L-12-C08-S01, KAT GPU cluster system) and the Korea Institute of Science and Technology Information (KISTI) (K-17L03-C02-S01, P-18-SI-CT-1-S01). Use of source codes are free for academic researchers. However, the users of source codes from the private sector will need to contact to the developers of the project.

#Patent##########
This project involves the patent of KISTI. Patent No: 10-2018-0137393. 'Prediction method for the lethality of suicide attempt based on the relationship between numeric features of an individual' 

#CAVEAT###########
We present the source codes as an example of our research project to help a user who has a little background of computational analysis.

#How to use########
This project consists of three steps.
<Step 0>: see the folder "DataProcessing"
0-0. preprocessing of data (e.g. conversion date into numeric value based on the method of KSP data format)
0-1. KNN imputation for missing values
0-2. Data split into train and test data for 10-fold cross validation  

<Step 1>: see the folder "EGONet"
0-0. Generation of the relationship reinforced features
0-1. Train and test of EGONet

Step 2>: see the folder "Benchmarking_model"
0-0. Train and test of other machine learning models including linear regression and random forest.
