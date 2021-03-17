
# (1) Treelike_stacking: Input ---------------------------------------------------------

#### 1. Paste on your own directory ####
setwd("D:\\G02_2\\data_sci\\HW06\\FINAL")


#### 2. Input ####
cs_training = read.table("Data/train.csv", sep=",", quote = "\"",header = T)
cs_test = read.table("Data/test.csv", sep=",", quote = "\"",header = T)

cs_training02 = cs_training[-2]
cs_test02 = cs_test[-2]
train_default = cs_training[2]


cs_all_cart = read.table("cs_all_cart.csv", sep=",", quote = "\"",header = T)

training_cart = cbind(cs_all_cart[1:150000,], train_default)
training_cart[150000,12]
dim(training_cart)

test_cart = cs_all_cart[150001:251503,]

Credit = training_cart



# _______________________ -------------------------------------------------------------------------
# (1) Treelike_stacking: Treelike models ---------------------------------------------------------

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

set.seed(0651)
index = sample(1:150000, 10000,replace = F)
Credit_sample = Credit[index, ]


#### 1. RF ####
Credit_sample$SeriousDlqin2yrs = as.factor(Credit_sample$SeriousDlqin2yrs)

model = randomForest(formula = SeriousDlqin2yrs ~ ., family = binomial(link = "logit"),
                     data = Credit_sample, ntree = 1000, mtry = 3 , importance = T) # ntree = 500
plot(model)
importance(model)
varImpPlot(model,type=1)

probabilities <- predict(model, test_cart,  type = "prob")[,2] # type = "response"
boxplot(probabilities)
summary(probabilities)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = probabilities)
write.csv(kaggle_probabilities02, "output/Kaggle_RF.csv",  row.names = F)

####

rf_pr_train <- prediction(probabilities, test_01$SeriousDlqin2yrs)
r_auc_train <- performance(rf_pr_train, measure = "auc")@y.values[[1]]
r_auc_train
# [1] 0.8309815



#### 2. XGBT ####

data_train_nn = cbind(Credit[,-c(12)])
data_test_nn = cbind(test_cart)
str(Credit)
str(test_cart)

dtrain = xgb.DMatrix(data = as.matrix(data_train_nn),
                     label = as.integer(Credit$SeriousDlqin2yrs))
dtest = xgb.DMatrix(data = as.matrix(data_test_nn),
                    label = as.integer(rep(0,101503)))

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
GBT_train = predict(xgb.model, dtrain, type="prob") # , type = "prob"
str(GBT_train)
GBT_train
boxplot(GBT_train)
# head(GBT_train, n = 10)
GBT_test = predict(xgb.model, dtest)
str(GBT_test)
boxplot(GBT_test)

auc(Credit$SeriousDlqin2yrs, GBT_train)
# Area under the curve: 0.9012
auc(test_cart$SeriousDlqin2yrs, GBT_test)
dim(test_cart)

GBT_test[GBT_test > 1] = 1
GBT_test[GBT_test < 0] = 0

boxplot(GBT_test)
# Output
kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = GBT_test)
write.csv(kaggle_probabilities02, "output/Kaggle_XGBT.csv",  row.names = F)



#### 3. Stacking ####

#### 01
s01_dart = read.table("Kaggle_dart.csv", sep=",", quote = "\"",header = T)
s02_xgbt = read.table("Kaggle_xgbt.csv", sep=",", quote = "\"",header = T)
s03_predict = read.table("predict.csv", sep=",", quote = "\"",header = T)
s04_predict_06 = read.table("predict_06.csv", sep=",", quote = "\"",header = T)
s05_predict_05 = read.table("predict_05.csv", sep=",", quote = "\"",header = T)

stacking = (s01_dart + s02_xgbt + s03_predict + s04_predict_06 + s05_predict_05) / 5
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking.csv",  row.names = F)


#### 02
s01_dart = read.table("Kaggle_dart.csv", sep=",", quote = "\"",header = T)
s02_xgbt = read.table("Kaggle_xgbt.csv", sep=",", quote = "\"",header = T)
s03_predict = read.table("predict.csv", sep=",", quote = "\"",header = T)
s04_predict_06 = read.table("predict_06.csv", sep=",", quote = "\"",header = T)
s05_predict_05 = read.table("predict_05.csv", sep=",", quote = "\"",header = T)
s05_predict_04 = read.table("predict_04.csv", sep=",", quote = "\"",header = T)
s05_predict_03 = read.table("predict_03.csv", sep=",", quote = "\"",header = T)

stacking = (s01_dart + s02_xgbt + s03_predict + s04_predict_06 + s05_predict_05 +
              s05_predict_04 + s05_predict_03) / 7
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking02.csv",  row.names = F)



#### 03
dart = read.table("Kaggle_dart.csv", sep=",", quote = "\"",header = T)
xgbt = read.table("Kaggle_xgbt.csv", sep=",", quote = "\"",header = T)
predict = read.table("predict.csv", sep=",", quote = "\"",header = T)
predict_06 = read.table("predict_06.csv", sep=",", quote = "\"",header = T)
predict_05 = read.table("predict_05.csv", sep=",", quote = "\"",header = T)
predict_04 = read.table("predict_04.csv", sep=",", quote = "\"",header = T)
predict_03 = read.table("predict_03.csv", sep=",", quote = "\"",header = T)
predict_02 = read.table("predict_02.csv", sep=",", quote = "\"",header = T)

# stacking = read.table("stacking.csv", sep=",", quote = "\"",header = T)
# stacking02 = read.table("stacking02.csv", sep=",", quote = "\"",header = T)

Kaggle_xgbt_0 = read.table("Kaggle_xgbt_0.csv", sep=",", quote = "\"",header = T)
Kaggle_xgbt_005 = read.table("Kaggle_xgbt_005.csv", sep=",", quote = "\"",header = T)
Kaggle_xgbt_001 = read.table("Kaggle_xgbt_001.csv", sep=",", quote = "\"",header = T)


stacking = (dart + xgbt + predict + predict_06 + predict_05 + predict_04 + predict_03 + predict_02 +
              Kaggle_xgbt_0 + Kaggle_xgbt_005 + Kaggle_xgbt_001) / 11
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking03.csv",  row.names = F)



#### 04
dart = read.table("Kaggle_dart.csv", sep=",", quote = "\"",header = T)
xgbt = read.table("Kaggle_xgbt.csv", sep=",", quote = "\"",header = T)
predict = read.table("predict.csv", sep=",", quote = "\"",header = T)
predict_06 = read.table("predict_06.csv", sep=",", quote = "\"",header = T)
predict_05 = read.table("predict_05.csv", sep=",", quote = "\"",header = T)
predict_04 = read.table("predict_04.csv", sep=",", quote = "\"",header = T)
predict_03 = read.table("predict_03.csv", sep=",", quote = "\"",header = T)
predict_02 = read.table("predict_02.csv", sep=",", quote = "\"",header = T)

stacking = read.table("stacking.csv", sep=",", quote = "\"",header = T)
stacking02 = read.table("stacking02.csv", sep=",", quote = "\"",header = T)

Kaggle_xgbt_0 = read.table("Kaggle_xgbt_0.csv", sep=",", quote = "\"",header = T)
Kaggle_xgbt_005 = read.table("Kaggle_xgbt_005.csv", sep=",", quote = "\"",header = T)
Kaggle_xgbt_001 = read.table("Kaggle_xgbt_001.csv", sep=",", quote = "\"",header = T)


stacking = (dart + xgbt + predict + predict_06 + predict_05 + predict_04 + predict_03 + predict_02 +
              Kaggle_xgbt_0 + Kaggle_xgbt_005 + Kaggle_xgbt_001 + stacking + stacking02) / 13
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking04.csv",  row.names = F)



#### 05
stacking = read.table("stacking.csv", sep=",", quote = "\"",header = T)
stacking02 = read.table("stacking02.csv", sep=",", quote = "\"",header = T)
stacking03 = read.table("stacking03.csv", sep=",", quote = "\"",header = T)

stacking = (stacking + stacking02 + stacking03) / 3
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking05.csv",  row.names = F)


#### 06
Kaggle_RF_10w_ntree_1000 = read.table("Kaggle_RF_10w_ntree_1000.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_10w_ntree_1000_02 = read.table("Kaggle_RF_10w_ntree_1000_02.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_10w_ntree_1000_03 = read.table("Kaggle_RF_10w_ntree_1000_03.csv", sep=",", quote = "\"",header = T)

stacking = (Kaggle_RF_10w_ntree_1000 + Kaggle_RF_10w_ntree_1000_02 + Kaggle_RF_10w_ntree_1000_03) / 3
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking06.csv",  row.names = F)


#### 07
Kaggle_RF_5w_ntree_1000 = read.table("Kaggle_RF_5w_ntree_1000.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_7.5w_ntree_1000 = read.table("Kaggle_RF_7.5w_ntree_1000.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_7.5w_ntree_1000_02 = read.table("Kaggle_RF_7.5w_ntree_1000_02.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_10w_ntree_1000 = read.table("Kaggle_RF_10w_ntree_1000.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_10w_ntree_1000_02 = read.table("Kaggle_RF_10w_ntree_1000_02.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_10w_ntree_1000_03 = read.table("Kaggle_RF_10w_ntree_1000_03.csv", sep=",", quote = "\"",header = T)
Kaggle_RF_15w = read.table("Kaggle_RF_15w.csv", sep=",", quote = "\"",header = T)

stacking = (Kaggle_RF_5w_ntree_1000 + Kaggle_RF_7.5w_ntree_1000 + Kaggle_RF_7.5w_ntree_1000_02 +
              Kaggle_RF_10w_ntree_1000 + Kaggle_RF_10w_ntree_1000_02 + Kaggle_RF_10w_ntree_1000_03 +
              Kaggle_RF_15w) / 7
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking07.csv",  row.names = F)



#### 08
stacking = read.table("stacking.csv", sep=",", quote = "\"",header = T)
stacking02 = read.table("stacking02.csv", sep=",", quote = "\"",header = T)
stacking03 = read.table("stacking03.csv", sep=",", quote = "\"",header = T)
stacking04 = read.table("stacking04.csv", sep=",", quote = "\"",header = T)
stacking07 = read.table("stacking07.csv", sep=",", quote = "\"",header = T)

stacking = (stacking + stacking02 + stacking03 + stacking04 + stacking07) / 5
summary(stacking)

kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = stacking[2])
write.csv(kaggle_probabilities02, "output/stacking08.csv",  row.names = F)
