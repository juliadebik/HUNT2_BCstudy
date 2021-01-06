library(readxl)
library(randomForest)
library(caret)
library(pROC)

Molecules_raw = read_excel("Molecules.xlsx", na="")
Molecules_df = data.frame(Molecules_raw)

data = Molecules_df

set.seed(1610)

AUC = numeric(8)
Accuracy = numeric(8)


cv_folds = createFolds(data$outcome, k = 8, list = TRUE, returnTrain = FALSE)

for(i in 1:8){
  test_indx = cv_folds[[i]]
  train_indx = 1:dim(data)[1]
  train_indx = train_indx[-test_indx]

  data_train = data.frame(data[train_indx, ])
  data_test = data.frame(data[test_indx, ])

  Xtrain = data_train[,5:dim(data_train)[2]]
  Ytrain = data_train[,1]

  Xtest = data_test[,5:dim(data_test)[2]]
  Ytest = data_test[,1]

  min_tree = numeric(12)
  mtry_error = numeric(12)
  
  for(j in 1:12){
    rf = randomForest(as.factor(Ytrain)~., data=cbind(Ytrain, Xtrain), type="binomial", mtry=j, ntree=500)
    min_tree[j] = which.min(rf$err.rate[,1])
    mtry_error[j] = min(rf$err.rate)
  }

  rf_tuned = randomForest(as.factor(Ytrain)~., data=cbind(Ytrain, Xtrain), type="binomial", mtry=which.min(mtry_error), ntree =500)
  Ypred = predict(rf_tuned, newdata=Xtest, type="prob")
  Ypred_01 = predict(rf_tuned, newdata=Xtest)

  AUC[i] = auc(Ytest, Ypred[,1])
  conf_table = table(Ytest, Ypred_01)
  Accuracy[i] = sum(diag(conf_table))/sum(conf_table)
}
