# Codes to run a gbm algorithm with a 8-fold CV of the HUNT2 samples in R. 
# The outcome is a future breast cancer and the variables are serum metabolite and lipoprotein concentrations, measured by NMR, 
# which are in the colums E to EA Molecules.xlsx file, while the outcome is stored in column A. 
# Data cannot be made available due to its sensitive nature.



library(readxl)
library(gbm)
library(caret)
library(pROC)
library(dplyr)


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


  hyper_grid = expand.grid(
    learning_rate = c(0.01, 0.005, 0.001),
    interaction_depth = c(1, 2, 3),
    error = NA,
    trees = NA,
    time = NA
  )


  for(k in seq_len(nrow(hyper_grid))) {

    set.seed(1610)
    
    train_time = system.time({
      fit = gbm(
        formula = Ytrain ~ .,
        data = cbind(Ytrain, Xtrain),
        distribution = "bernoulli",
        n.trees = 1000,
        shrinkage = hyper_grid$learning_rate[k],
        interaction.depth = hyper_grid$interaction_depth[k],
        cv.folds = 10,
        verbose=FALSE,
      )
    })

  hyper_grid$error[k]  = min(fit$cv.error)
  hyper_grid$trees[k] = which.min(fit$cv.error)
  hyper_grid$time[k]  = train_time[["elapsed"]]

  }

  best_choices = hyper_grid %>% arrange(error) %>%  head(10)
  best_choice = best_choices[1,]

  set.seed(1610)
  gbm_tuned = gbm(Ytrain~., data=cbind(Ytrain,Xtrain), interaction.depth = best_choice$interaction_depth,n.trees = best_choice$trees, shrinkage=best_choice$learning_rate, distribution="bernoulli" )


  Ypred = predict(gbm_tuned, newdata=Xtest, type="response")
  Ypred_01 = ifelse(Ypred < 0.5, 0, 1)

  AUC[i] = auc(Ytest, Ypred)
  conf_table = table(Ytest, Ypred_01)
  Accuracy[i] = sum(diag(conf_table))/sum(conf_table)
}

