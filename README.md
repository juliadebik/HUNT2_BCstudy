# HUNT2 Breast Cancer study
Source code for the serum metabolomics breast cancer study on the HUNT2 cohort

Four different machine learning algorithms have been applied for analyzing the serum data for prediction of a future breast cancer case based on serum levels of metabolite and lipoprotein concentrations, measured by NMR:

1. A random forest classfier (using the randomForest in package in R)
2. A gradient boosting machine (using the gbm package in R)
3. A partial least squares discriminaant analysis (using the PLS Toolbox in Matlab)
4. A deep learning model (using the keras library in Python).

The variables (metabolic concentrations) are stored in the columns E to EA in the Molecules.xlsx file, while the outcome (future breast cancer) is a binary variable, stored in column A. 

Data cannot be made available due to its sensitive nature.
