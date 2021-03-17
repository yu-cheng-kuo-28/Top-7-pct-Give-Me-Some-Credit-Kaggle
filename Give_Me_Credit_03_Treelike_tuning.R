# (1) Treelike_tuning : Input ---------------------------------------------------------

#### 1. Paste on your own directory ####
setwd("D:\\G02_2\\business_R\\FINAL\\FINAL")


#### 2. Input ####
train_ans = read.table("train_ans.csv", sep=",", quote = "\"",header = T)
cs_all_cart = read.table("cs_all_cart.csv", sep=",", quote = "\"",header = T)

credit_all = cbind(cs_all_cart[1:150000,], train_ans)
dim(credit_all) # [1] 150000     12

index_sample = sample(1:150000, 10000, replace = FALSE, prob = NULL)
credit_raw = credit_all[index_sample, ]
dim(credit_raw) # [1] 10000    11

credit_raw$SeriousDlqin2yrs = as.factor(credit_raw$SeriousDlqin2yrs)

index_sample02 = sample(1:10000, 7000, replace = FALSE, prob = NULL)
train_01 = credit_raw [index_sample02, ]
test_01 = credit_raw [-index_sample02, ]
dim(train_01) # [1] 7000   11
dim(test_01) # [1] 3000   11

str(train_01)
length(train_01$SeriousDlqin2yrs)
sum(is.na(train_01$SeriousDlqin2yrs))
sum(as.numeric(train_01$SeriousDlqin2yrs)) # [1] 462
sum(is.na(train_01[-11]))

Credit = train_01


# _______________________ -------------------------------------------------------------------------
# (2) Treelike_tuning : Treelike models tuning -------------------------------------------------------------------

library(rBayesianOptimization)
library(randomForest, quietly = T)
library(rpart)
library(rpart.plot)

library(tidyverse)
library(caret)
library(dplyr)
library(pROC)
library(regclass)

library(ROCR)
library(xgboost)
library(nnet)
library(keras)


{
  # k = 5 OR 10
  k = 10
  kfold01 = KFold(1:7000, nfolds = k, stratified = F, seed = 66) 
  
  AUC_train = rep(NA, k)
  # AUC_valid = rep(NA, 5)
  AUC_test = rep(NA, k)
  
  
  
  # 3-way validation & k-fold
  
  for (i in 1:10){
    
    # i = 1
    
    Credit_test <- Credit[unlist(kfold01[i]),]
    
    if( i == 10 ) { t = 1 }else{ t = i+1 } 
    
    # Credit_valid <- Credit[unlist(kfold01[t]),]
    # index = unlist(c(kfold01[i],kfold01[t])); 
    index = unlist(c(kfold01[i])); 
    
    Credit_train <- Credit[(1:7000)[-index], ]; #Titanic_train
    
    
    # model <- glm(formula = SeriousDlqin2yrs ~ ., 
    #              family = binomial(link = "logit"), data = Credit_train)
    # summary(model)
    # AIC(model); BIC(model)
    
    
    # #### 1. RF ####
    # model = randomForest(formula = SeriousDlqin2yrs ~ . ,
    #                       data = Credit_train, ntree = 2000, mtry = 3 , importance = F)
    # # plot(model)
    # # tuneRF(Credit_train[,-11], Credit_train[,11])
    # 
    # probabilities <- predict(model, Credit_train,  type = "prob")[,2] # type = "response"
    # rf_pr_train <- prediction(probabilities, Credit_train$SeriousDlqin2yrs)
    # r_auc_train <- performance(rf_pr_train, measure = "auc")@y.values[[1]]
    # AUC_train[i] = r_auc_train
    # 
    # # probabilities <- predict(model, Credit_valid,  type = "prob")[,2] # type = "response"
    # # rf_pr_valid <- prediction(probabilities, Credit_valid$SeriousDlqin2yrs)
    # # r_auc_valid <- performance(rf_pr_valid, measure = "auc")@y.values[[1]] 
    # # AUC_valid[i] = r_auc_valid 
    # 
    # probabilities <- predict(model, Credit_test,  type = "prob")[,2] # type = "response"
    # rf_pr_test <- prediction(probabilities, Credit_test$SeriousDlqin2yrs)
    # r_auc_test <- performance(rf_pr_test, measure = "auc")@y.values[[1]] 
    # AUC_test[i] = r_auc_test 
    
    
    
    #### 2. XGBT ####
    data_train_nn = cbind(Credit_train[,-11] )
    data_test_nn = cbind(Credit_test[,-11])
    
    dtrain = xgb.DMatrix(data = as.matrix(data_train_nn),
                         label = as.integer(Credit_train$SeriousDlqin2yrs)-1)
    dtest = xgb.DMatrix(data = as.matrix(data_test_nn),
                        label = as.integer(Credit_test$SeriousDlqin2yrs)-1)
    
    # 2. set xgb.params
    
    xgb.params = list(
      # col sampling proportion. Higher -> complexity up
      colsample_bytree = 0.5,
      # row sampling proportion. Higher -> complexity up
      subsample = 0.5,
      booster = "gbtree",
      # max depth of a tree. Higher -> complexity up
      max_depth = 4, # 4
      # boosting would increase the weight of wrong classification. Higher -> complexity down
      eta = 0.03, # 0.03
      # 'mae' is ok
      eval_metric = "auc",  # rmse or mae
      objective = "binary:logistic",
      # Higher -> complexity down
      gamma = 0)
    
    # 3. xgb.cv(). Fine tune the best "nrounds" 
    cv.model = xgb.cv(
      params = xgb.params,
      data = dtrain,
      nfold = 5,     # 5-fold cv
      nrounds= 130,   # test 1-100  # 130
      # If when nrounds < x ,there exists overfitting, then the function stops here.
      early_stopping_rounds = 20,
      print_every_n = 1000 # display results every 20 units
    )
    
    tmp = cv.model$evaluation_log
    
    plot(x=1:nrow(tmp), y= tmp$train_rmse_mean, col='red', xlab="nround", ylab="rmse", main="Avg.Performance in CV")
    points(x=1:nrow(tmp), y= tmp$test_rmse_mean, col='blue')
    legend("topright", pch=1, col = c("red", "blue"),
           legend = c("Train", "Test") )
    
    # Get best nround
    best.nrounds = cv.model$best_iteration
    # best.nrounds
    
    # 4. Building model by xgb.train()
    xgb.model = xgb.train(paras = xgb.params,
                          data = dtrain,
                          nrounds = best.nrounds)
    
    # Plot all the dicision trees in xgb 
    # xgb.plot.tree(model = xgb.model)
    
    
    # prediction
    GBT_train = predict(xgb.model, dtrain ) # , type = "prob"
    GBT_test = predict(xgb.model, dtest)
    
    AUC_train[i] = auc(Credit_train$SeriousDlqin2yrs, GBT_train)
    AUC_test[i] = auc(Credit_test$SeriousDlqin2yrs, GBT_test)
    
    
    # common <- intersect(names(dtrain), names(dtest)) 
    # for (p in common) { 
    #   if (class(dtrain[[p]]) == "factor") { 
    #     levels(dtest[[p]]) <- levels(dtrain[[p]])} }
    
    # head(probabilities)
    # AUC_train[i] = auc(Credit_train$SeriousDlqin2yrs, probabilities)
    # 
    # model$votes[,2]
    #     
    # require(pROC)
    # rf.roc<-roc(iris$Species,iris.rf$votes[,2])
    # plot(rf.roc)
    # auc(rf.roc)
    # 
    # predict = factor(predict(model, newdata = Credit_train , type = 'class', levels = levels(Credit_train$SeriousDlqin2yrs)))
    # confusion = table(Credit_train$SeriousDlqin2yrs, predict) ; confusion
    # 
    # correctness = sum(confusion[row(confusion) == col(confusion)]) / sum(confusion) ; correctness
    # 
    # result_rf_valid[i] = f1_correct_valid
    # 
    # # even the level  !!!
    # common <- intersect(names(Credit_train), names(Credit_valid)) 
    # for (p in common) { 
    #   if (class(Credit_train[[p]]) == "factor") { 
    #     levels(Credit_valid[[p]]) <- levels(Credit_train[[p]]) } }
    # 
    # probabilities <- model %>% predict(Credit_valid,  type = "response") # type = "response"
    # AUC_valid[i] = auc(Credit_valid$SeriousDlqin2yrs, probabilities)
    # 
    # 
    # # even the level  !!!
    # common <- intersect(names(Credit_train), names(Credit_test)) 
    # for (p in common) { 
    #   if (class(Credit_train[[p]]) == "factor") { 
    #     levels(Credit_test[[p]]) <- levels(Credit_train[[p]])} }
    # 
    # probabilities <- model %>% predict(Credit_test,  type = "response") # type = "response"
    # AUC_test[i] = auc(Credit_test$SeriousDlqin2yrs, probabilities)
    
    print(i)
  }
}



AUC_train02 = c(AUC_train, mean(AUC_train))
# AUC_valid02 = c(AUC_valid, mean(AUC_valid))
AUC_test02 = c(AUC_test, mean(AUC_test))
AUC_train02; AUC_test02 # AUC_valid02  # top line = 0.860 ~ 0.863

#### XGBT
# nrounds= 130 # 
# [1] 0.9772677 0.9998356 0.9773626 0.9889172 0.9998871 0.9693067 0.9414543 0.9900199 0.9822277 0.9437578 0.9770037
# [1] 0.8150243 0.7811135 0.7737500 0.7709560 0.7307126 0.8566776 0.8396921 0.8183474 0.8188240 0.7801858 0.7985283


# nrounds= 130
# [1] 0.9735440 0.9758801 0.9930602 0.9704630 0.9997507 0.9825396
# [1] 0.8083030 0.7950642 0.7869465 0.8457356 0.7356808 0.7943460

# [1] 0.9999815 0.9989344 0.9832996 0.9999853 1.0000000 0.9964402
# [1] 0.7714442 0.7672201 0.8110125 0.7792372 0.7173615 0.7692551

# [1] 0.9999815 0.9999437 0.9997324 0.9997982 0.9999688 0.9998849
# [1] 0.7714442 0.7626818 0.7657974 0.7718284 0.7284231 0.7600350

# [1] 0.9999815 0.9992270 0.9996891 0.9999853 0.9999919 0.9997750
# [1] 0.7714442 0.7622692 0.7664872 0.7776994 0.7273077 0.7610415

# nrounds= 130
# [1] 0.9982447 0.9993524 0.9846793 0.9998111 0.9999392 0.9964053
# [1] 0.7938259 0.7622994 0.8176273 0.7719189 0.7280308 0.7747405



#### ntree = 2000, mtry = 3  # k-fold = 5  # -NumberOfDependents
# [1] 1 1 1 1 1 1
# [1] 0.8617179 0.8444649 0.8384563 0.8434504 0.8311001 0.8438379


#### ntree = 2000, mtry = 3  # k-fold = 6
# [1] 1 1 1 1 1 1 1
# [1] 0.8591445 0.8547715 0.8193947 0.8371701 0.8335879 0.8300075 0.8390127


#### ntree = 2500, mtry = 3
# [1] 1 1 1 1 1 1
# [1] 0.8651131 0.8463622 0.8384860 0.8441574 0.8288957 0.8446029


#### ntree = 2500, mtry = 3
# [1] 1 1 1 1 1 1
# [1] 0.8656891 0.8476483 0.8380407 0.8444490 0.8285326 0.8448719


#### ntree = 2000, mtry = 4
# [1] 1 1 1 1 1 1
# [1] 0.8616529 0.8427714 0.8353265 0.8392127 0.8294908 0.8416909


#### ntree = 2000, mtry = 3  # k-fold = 5
# [1] 1 1 1 1 1 1
# [1] 0.8652171 0.8457031 0.8378838 0.8452598 0.8302206 0.8448569

# [1] 1 1 1 1 1 1
# [1] 0.8652171 0.8457031 0.8378838 0.8452598 0.8302206 0.8448569


#### ntree = 1400, mtry = 3

# [1] 1 1 1 1 1 1 1 1 1 1 1
# [1] 0.8851860 0.8400811 0.8549654 0.8346395 0.8281425 0.8293978 0.8377107
# [8] 0.8354005 0.8444420 0.8182868 0.8408252

# [1] 1 1 1 1 1 1
# [1] 0.8666548 0.8471730 0.8408906 0.8450121 0.8264404 0.8452342


#### ntree = 1000, mtry = 3
# [1] 1 1 1 1 1 1 1 1 1 1 | 1
# [1] 0.8854574 0.8379371 0.8575184 0.8368109 0.8343172 0.8366921 0.8471184
# [8] 0.8379816 0.8404798 0.8234177 | 0.8437730

# [1] 1 1 1 1 1 | 1
# [1] 0.8679194 0.8449283 0.8355428 0.8435183 0.8329416 | 0.8449701


#### ntree = 200, mtry = 3
# [1] 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000
# [8] 1.0000000 1.0000000 0.9999998 | 1.0000000
# [1] 0.8762122 0.8417431 0.8500408 0.8353181 0.8243596 0.8468872 0.8394765
# [8] 0.8186669 0.8434289 0.8050232 | 0.8381156

# [1] 1 1 1 1 1 | 1
# [1] 0.8579849 0.8396201 0.8345208 0.8414534 0.8135091 | 0.8374176


#### ntree = 500, mtry = 2
# [1] 0.9999178 0.9999406 0.9999569 0.9999833 0.9999614 0.9999749 0.9999786
# [8] 0.9999696 0.9999569 0.9999503 | 0.9999590
# [1] 0.8807172 0.8351283 0.8539684 0.8307549 0.8161323 0.8472604 0.8376959
# [8] 0.8343611 0.8430308 0.8043947 | 0.8383444

# [1] 0.9999250 0.9999901 0.9999757 0.9999497 0.9999742 | 0.9999629
# [1] 0.8575128 0.8378667 0.8326039 0.8464021 0.8246551 | 0.8398081


####  ntree = 500, mtry = 3
# [1] 1 1 1 1 1 1 1 1 1 1 | 1
# [1] 0.8838110 0.8488565 0.8592858 0.8278202 0.8350806 0.8373876 0.8484538
# [8] 0.8290085 0.8444963 0.8040483 | 0.8418249

# [1] 1 1 1 1 1 | 1
# [1] 0.8658667 0.8437260 0.8387701 0.8438099 0.8212005 | 0.8426747

#### 

# [1] 0.8464300 0.8572615 0.8380492 0.8082103 0.8355725 0.8356927 0.8412555
# [8] 0.8340751 0.8076144 0.8822912 | 0.8386453
# [1] 0.8464300 0.8572615 0.8380492 0.8082103 0.8355725 0.8356927 0.8412555
# [8] 0.8340751 0.8076144 0.8822912 | 0.8386453
# [1] 0.8875380 0.8398650 0.8514155 0.8181679 0.8268363 0.8248685 0.8383784
# [8] 0.8346729 0.8433746 0.8008030 | 0.8365920

# [1] 0.8497452 0.8283249 0.8421843 0.8207065 0.8578116 | 0.8397545
# [1] 0.8497452 0.8283249 0.8421843 0.8207065 0.8578116 | 0.8397545
# [1] 0.8673651 0.8346474 0.8384351 0.8469772 0.8212454 | 0.8417341


