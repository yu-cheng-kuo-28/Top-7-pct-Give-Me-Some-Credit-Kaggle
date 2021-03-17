 
# (1) LR: Input ---------------------------------------------------------

#### 1. Paste on your own directory ####
setwd("D:\\G02_2\\business_R\\FINAL\\FINAL")


#### 2. Input ####
cs_all_cart = read.table("cs_all_cart.csv", sep=",", quote = "\"",header = T)
train_ans = read.table("train_ans.csv", sep=",", quote = "\"",header = T)

training_cart = cbind(cs_all_cart[1:150000,], train_ans)
test_cart = cs_all_cart[150001:251503,]

Credit = training_cart
str(Credit)


# _______________________ -------------------------------------------------------------------------
# (2) LR: EDA -------------------------------------------------------------------

#### 1. Histogram ####
par(mfrow = c(3, 2))
hist(Credit$RevolvingUtilizationOfUnsecuredLines, breaks = 20, main = "RevolvingUtilizationOfUnsecuredLines", border="darkorange", col="dodgerblue")
hist(Credit$age, breaks = 20, main = "age", border="darkorange", col="dodgerblue")
hist(Credit$DebtRatio, breaks = 20, main = "DebtRatio", border="darkorange", col="dodgerblue")
hist(Credit$MonthlyIncome, breaks = 20, main = "MonthlyIncome", border="darkorange", col="dodgerblue")
hist(Credit$NumberOfOpenCreditLinesAndLoans, breaks = 20, main = "NumberOfOpenCreditLinesAndLoans", border="darkorange", col="dodgerblue")
hist(Credit$NumberRealEstateLoansOrLines, breaks = 20, main = "NumberRealEstateLoansOrLines", border="darkorange", col="dodgerblue")

par(mfrow = c(3, 2))
hist(Credit$NumberOfDependents, breaks = 20, main = "NumberOfDependents", border="darkorange", col="dodgerblue")
hist(Credit$NumberOfTime30.59DaysPastDueNotWorse, breaks = 20, main = "NumberOfTime30.59DaysPastDueNotWorse", border="darkorange", col="dodgerblue")
hist(Credit$NumberOfTime60.89DaysPastDueNotWorse, breaks = 20, main = "NumberOfTime60.89DaysPastDueNotWorse", border="darkorange", col="dodgerblue")
hist(Credit$NumberOfTimes90DaysLate, breaks = 20, main = "NumberOfTimes90DaysLate", border="darkorange", col="dodgerblue")
hist(Credit$SeriousDlqin2yrs, breaks = 20, main = "SeriousDlqin2yrs", border="darkorange", col="dodgerblue")


#### 2. Correlation matrix ####
library(ggcorrplot)
# names(housing_train)
cor01 = cor(Credit) #; cor01
ggcorrplot(cor01, 
           hc.order = TRUE, 
           type = "full", # "lower"
           lab = TRUE)


#### 3. Piechart ####

barplot(table(Credit$SeriousDlqin2yrs))


library(ggplot2)
library(scales)
pie + scale_fill_brewer("Blues") +
  theme(axis.text.x=element_blank())+
  geom_text(aes(y = value/3 + c(0, cumsum(value)[-length(value)]), 
                label = percent(value/100)), size=5)

head(PlantGrowth)
ggplot(PlantGrowth, aes(x=factor(1), fill=group))+
  geom_bar(width = 1)+
  coord_polar("y")


data <- data.frame(
  group=LETTERS[1:5],
  value=c(13,7,9,21,2)
)

# Compute the position of labels
data <- data %>% 
  arrange(desc(group)) %>%
  mutate(prop = value / sum(data$value) *100) %>%
  mutate(ypos = cumsum(prop)- 0.5*prop )

head(data)

# Basic piechart
ggplot(data, aes(x="", y=prop, fill=group)) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void() + 
  theme(legend.position="none") +
  
  geom_text(aes(y = ypos, label = group), color = "white", size=6) +
  scale_fill_brewer(palette="Set1")

# _______________________ -------------------------------------------------------------------------
# (3) LR: Feature Engineering -------------------------------------------------------------------


#### 1. RevolvingUtilizationOfUnsecuredLines ####
Credit$BaLim_ratio = Credit$RevolvingUtilizationOfUnsecuredLines
hist(Credit$BaLim_ratio)
Credit$BaLim_ratio[Credit$BaLim_ratio > 1.2] = 1.2
hist(Credit$BaLim_ratio)
# Credit$BL_ratio_log = log(Credit$BaLim_ratio+10)
# Credit$BL_ratio_1 = Credit$BaLim_ratio + 1


#### 2. age ####
Credit$age_2 = Credit$age
Credit$age_2[Credit$age_2 == 0 ] = 20
hist(Credit$age_2)


#### 3. MonthlyIncome ####
Credit$Income = Credit$MonthlyIncome
hist(Credit$Income)
Credit$Income[Credit$Income > 23300] = 23300
Credit$Income_log = log(Credit$Income + 10)
hist(Credit$Income_log)

Credit$Income_bool = Credit$MonthlyIncome
Credit$Income_bool[Credit$Income_bool ==1 ] = 0
Credit$Income_bool[Credit$Income_bool !=0 ] = 1
length(Credit$Income_bool[Credit$Income_bool ==0])
# [1] 24516
length((Credit$SeriousDlqin2yrs[Credit$Income_bool ==0])[Credit$SeriousDlqin2yrs ==0])
# [1] 10026
length(Credit$SeriousDlqin2yrs[Credit$SeriousDlqin2yrs ==1])
# [1] 10026
length((Credit$SeriousDlqin2yrs[Credit$Income_bool ==0])[Credit$SeriousDlqin2yrs ==1])


#### 4. NumberOfDependents ####
Credit$Dep = Credit$NumberOfDependents
Credit$Dep[Credit$Dep > 2] = 2


#### 5. DebtRatio ####
Credit$D_Ratio = Credit$DebtRatio
Credit$D_Ratio[Credit$D_Ratio >= 1200] = 3.7
Credit$D_Ratio[Credit$D_Ratio >4 ] = 5 #7
Credit$D_Ratio[Credit$D_Ratio == 3.7 ] = 6 #10

#### 6. NumberOfOpenCreditLinesAndLoans ####
Credit$OCLAL = log(Credit$NumberOfOpenCreditLinesAndLoans + 1)

#### 7. NumberRealEstateLoansOrLines ####
Credit$REOL = Credit$NumberRealEstateLoansOrLines
Credit$REOL[Credit$REOL > 5] = 5


#### 8. NumberOfTime30.59DaysPastDueNotWorse ####
Credit$Num_30.59 = Credit$NumberOfTime30.59DaysPastDueNotWorse
Credit$Num_30.59[Credit$Num_30.59 > 3] = 3

#### 9. NumberOfTime60.89DaysPastDueNotWorse ####
Credit$Num_60.89 = Credit$NumberOfTime60.89DaysPastDueNotWorse
Credit$Num_60.89[Credit$Num_60.89 > 2] = 2

#### 10. NumberOfTimes90DaysLate ####
Credit$Num_90 = Credit$NumberOfTimes90DaysLate
Credit$Num_90[Credit$Num_90 > 2] = 2
# Credit$Num_90[Credit$Num_90 > 3] = 3


#### 11. Histogram after feature engineering ####
str(Credit)

par(mfrow = c(3, 2))
hist(Credit$age_2, breaks = 20, main = "age_2", border="darkorange", col="dodgerblue")
hist(Credit$Income_log, breaks = 20, main = "Income_log", border="darkorange", col="dodgerblue")
hist(Credit$D_Ratio, breaks = 20, main = "D_Ratio", border="darkorange", col="dodgerblue")
hist(Credit$Income_bool, breaks = 20, main = "Income_bool", border="darkorange", col="dodgerblue")
hist(Credit$BaLim_ratio, breaks = 20, main = "BaLim_ratio", border="darkorange", col="dodgerblue")
hist(Credit$OCLAL, breaks = 20, main = "OCLAL", border="darkorange", col="dodgerblue")

par(mfrow = c(3, 2))
hist(Credit$Dep, breaks = 20, main = "Dep", border="darkorange", col="dodgerblue")
hist(Credit$REOL, breaks = 20, main = "REOL", border="darkorange", col="dodgerblue")
hist(Credit$Num_30.59, breaks = 20, main = "NumberOfTime60.89DaysPastDueNotWorse", border="darkorange", col="dodgerblue")
hist(Credit$Num_60.89, breaks = 20, main = "NumberOfTimes90DaysLate", border="darkorange", col="dodgerblue")
hist(Credit$Num_90, breaks = 20, main = "SeriousDlqin2yrs", border="darkorange", col="dodgerblue")


#### 12. Correlation matrix after feature engineering ####
str(Credit)
names(Credit)
cor02 = cor(Credit[c(11,12,13,15,16,17,18,19,20,21,22,23)]) #; cor01
ggcorrplot(cor02, 
           hc.order = TRUE, 
           type = "full", # "lower"
           lab = TRUE)


#### 13. as.factor( ) ####
Credit$Dep = as.factor(Credit$Dep)
Credit$REOL = as.factor(Credit$REOL)
Credit$Num_30.59 = as.factor(Credit$Num_30.59)
Credit$Num_60.89 = as.factor(Credit$Num_60.89)
Credit$Num_90 = as.factor(Credit$Num_90)
Credit$Income_bool = as.factor(Credit$Income_bool)



# _______________________ -------------------------------------------------------------------------
# (4) LR: Prediction : k-fold LR -------------------------------------------------------------------------

library(rBayesianOptimization)
library(randomForest, quietly = T)
library(rpart)
library(rpart.plot)

library(tidyverse)
library(caret)
library(dplyr)
library(pROC)
library(regclass)

# kfold_num = 10
kfold_num = 10


if(kfold_num == 5){
  
  # k = 5
  kfold01 = KFold(1:150000, nfolds = 5, stratified = F, seed = 66) 
  
  AUC_train = rep(NA, 5)
  AUC_valid = rep(NA, 5)
  AUC_test = rep(NA, 5)
  
  
  # 3-way validation & k-fold
  
  for (i in 1:5){
    
    # i = 1
    
    Credit_test <- Credit[unlist(kfold01[i]),]
    
    if( i == 5 ) { t = 1 }else{ t = i+1 } 
    
    Credit_valid <- Credit[unlist(kfold01[t]),]
    
    index = unlist(c(kfold01[i],kfold01[t])); # index; str(index)
    
    
    Credit_train <- Credit[(1:150000)[-index], ]; #Titanic_train
    
    # nullmodel <- glm(SeriousDlqin2yrs ~ age_2 + Income_log + I(Income_log**2) + I(Income_log**3) +
    #                    D_Ratio + I(D_Ratio**2) + I(D_Ratio**3) + BL_ratio_log + OCLAL + I(OCLAL**2) + 
    #                    Dep + REOL + Num_30.59 + Num_60.89 + Num_90 , 
    #                  data = Credit_train, family = binomial(link = "logit"))
    # #fullmodel =  glm( SeriousDlqin2yrs ~ age_2 + Income_log + D_Ratio + BaLim_ratio + Dep + OCLAL + REOL +
    # #                   Num_30.59 + Num_60.89 + Num_90 , data = Credit_train, family = binomial(link = "logit"))
    # 
    # fullmodel =  glm( SeriousDlqin2yrs ~ age_2 + Income_log + I(Income_log**2) + I(Income_log**3) +
    #                     D_Ratio + I(D_Ratio**2) + I(D_Ratio**3) + BL_ratio_log + OCLAL + I(OCLAL**2) + 
    #                     Dep + REOL + Num_30.59 + Num_60.89 + Num_90 +
    #                     age_2:Income_log + age_2:D_Ratio + age_2:BL_ratio_log + age_2:OCLAL + age_2:Dep + age_2:REOL + age_2:Num_30.59 + age_2:Num_60.89 + age_2:Num_90 +
    #                     Income_log:D_Ratio + Income_log:BL_ratio_log + Income_log:OCLAL + Income_log:Dep + Income_log:REOL + Income_log:Num_30.59 + Income_log:Num_60.89 + Income_log:Num_90 +
    #                     D_Ratio:BL_ratio_log + D_Ratio:OCLAL + D_Ratio:Dep + D_Ratio:REOL + D_Ratio:Num_30.59 + D_Ratio:Num_60.89 + D_Ratio:Num_90 +
    #                     OCLAL:Dep + OCLAL:REOL + OCLAL:Num_30.59 + OCLAL:Num_60.89 + OCLAL:Num_90 +
    #                     Dep:REOL + Dep:Num_30.59 + Dep:Num_60.89 + Dep:Num_90 +
    #                     REOL:Num_30.59 + REOL:Num_60.89 + REOL:Num_90 + 
    #                     Num_30.59:Num_60.89 + Num_30.59:Num_90 + 
    #                     Num_60.89:Num_90, data = Credit_train, family = binomial(link = "logit"))
    # 
    # housestep <- step(nullmodel, 
    #                   scope=list(lower=nullmodel, upper=fullmodel),
    #                   direction="both", criterion = "BIC")
    # summary(housestep)
    
    
    model <- glm(formula = SeriousDlqin2yrs ~ age_2 + Income_log + I(Income_log^2) + 
                   I(Income_log^3) + D_Ratio + I(D_Ratio^2) + I(D_Ratio^3) + Income_bool +
                   BaLim_ratio + OCLAL + I(OCLAL^2) + Dep + REOL + Num_30.59 + 
                   Num_60.89 + Num_90 + Num_30.59:Num_90 + Num_30.59:Num_60.89 + 
                   age_2:Num_90 + Num_60.89:Num_90 + age_2:Num_60.89 + D_Ratio:BaLim_ratio + 
                   REOL:Num_90 + age_2:Num_30.59 + age_2:Dep + age_2:D_Ratio + 
                   REOL:Num_60.89 + Income_log:Num_30.59 + age_2:REOL + Income_log:REOL, 
                 family = binomial(link = "logit"), data = Credit_train)
    
    summary(model)
    AIC(model); BIC(model)
    
    # [1] 32313.02 [1] 33112.66
    
    # [1] 32359.03 [1] 33158.68
    # [1] 32490.87 [1] 32867.17
    
    # [1] 32348.06 [1] 32997.18
    # [1] 32349.88 [1] 32999
    # [1] 32352.93 [1] 33020.87
    # [1] 32360.82 [1] 33094.61
    # [1] 32365.48 [1] 33212.16
    
    # [1] 32701.27 [1] 32955.27
    # [1] 32499    [1] 32950.56
    # [1] 32365.48 [1] 33212.16
    # [1] 32372.05 [1] 33293.99
    
    probabilities <- predict(model, Credit_train,  type = "response") # type = "response"
    AUC_train[i] = auc(Credit_train$SeriousDlqin2yrs, probabilities)
    
    # even the level  !!!
    common <- intersect(names(Credit_train), names(Credit_valid)) 
    for (p in common) { 
      if (class(Credit_train[[p]]) == "factor") { 
        levels(Credit_valid[[p]]) <- levels(Credit_train[[p]]) } }
    
    probabilities <- model %>% predict(Credit_valid,  type = "response") # type = "response"
    AUC_valid[i] = auc(Credit_valid$SeriousDlqin2yrs, probabilities)
    
    
    # even the level  !!!
    common <- intersect(names(Credit_train), names(Credit_test)) 
    for (p in common) { 
      if (class(Credit_train[[p]]) == "factor") { 
        levels(Credit_test[[p]]) <- levels(Credit_train[[p]])} }
    
    probabilities <- model %>% predict(Credit_test,  type = "response") # type = "response"
    AUC_test[i] = auc(Credit_test$SeriousDlqin2yrs, probabilities)
    
    print(i)
  }
  
  
} else if (kfold_num == 10){
  
  
  # k = 10
  kfold01 = KFold(1:150000, nfolds = 10, stratified = F, seed = 66) 
  
  AUC_train = rep(NA, 10)
  AUC_valid = rep(NA, 10)
  AUC_test = rep(NA, 10)
  
  
  # 3-way validation & k-fold
  
  for (i in 1:10){
    
    # i = 3
    
    Credit_test <- Credit[unlist(kfold01[i]),]
    
    if( i == 10 ) { t = 1 }else{ t = i+1 } 
    
    Credit_valid <- Credit[unlist(kfold01[t]),]
    
    index = unlist(c(kfold01[i],kfold01[t])); # index; str(index)
    
    
    Credit_train <- Credit[(1:150000)[-index], ]; #Titanic_train
    
    model <- glm(formula = SeriousDlqin2yrs ~ age_2 + Income_log + I(Income_log^2) + 
                   I(Income_log^3) + D_Ratio + I(D_Ratio^2) + I(D_Ratio^3) + Income_bool +
                   BaLim_ratio + OCLAL + I(OCLAL^2) + Dep + REOL + Num_30.59 + 
                   Num_60.89 + Num_90 + Num_30.59:Num_90 + Num_30.59:Num_60.89 + 
                   age_2:Num_90 + Num_60.89:Num_90 + age_2:Num_60.89 + D_Ratio:BaLim_ratio + 
                   REOL:Num_90 + age_2:Num_30.59 + age_2:Dep + age_2:D_Ratio + 
                   REOL:Num_60.89 + Income_log:Num_30.59 + age_2:REOL + Income_log:REOL, 
                 family = binomial(link = "logit"), data = Credit_train)
    
    # summary(model)
    # AIC(model); BIC(model)
    
    probabilities <- predict(model, Credit_train,  type = "response") # type = "response"
    AUC_train[i] = auc(Credit_train$SeriousDlqin2yrs, probabilities)
    
    # even the level  !!!
    #common <- c("NumberOfTime60.89DaysPastDueNotWorse","NumberOfDependents")
    #for (p in common) { 
    #  if (class(Credit_train[[p]]) == "factor") { 
    #    levels(Credit_valid[[p]]) <- levels(Credit_train[[p]]) } }
    
    probabilities <- model %>% predict(Credit_valid,  type = "response") # type = "response"
    AUC_valid[i] = auc(Credit_valid$SeriousDlqin2yrs, probabilities)
    
    
    # even the level  !!!
    #common <- intersect(names(Titanic_train), names(Titanic_test)) 
    #for (p in common) { 
    #  if (class(Titanic_train[[p]]) == "factor") { 
    #    levels(Titanic_test[[p]]) <- levels(Titanic_train[[p]])} }
    
    probabilities <- model %>% predict(Credit_test,  type = "response") # type = "response"
    AUC_test[i] = auc(Credit_test$SeriousDlqin2yrs, probabilities)
    
    print(i)
  }
  
}



# _______________________ -------------------------------------------------------------------------
# (5) LR: Output for Github ---------------------------------------------------------------------

AUC_train02 = c(AUC_train, mean(AUC_train))
AUC_valid02 = c(AUC_valid, mean(AUC_valid))
AUC_test02 = c(AUC_test, mean(AUC_test))

AUC_valid02; AUC_test02
# [1] 0.8629371 0.8607473 0.8652665 0.8677317 0.8587191 0.8630803
# [1] 0.8591835 0.8630683 0.8606185 0.8654143 0.8670733 0.8630716
#
# [1] 0.8620901 0.8599668 0.8645145 0.8669721 0.8580295 0.8623146
# [1] 0.8585100 0.8620813 0.8597772 0.8645787 0.8663438 0.8622582


if (kfold_num == 5){
  
  set = c("fold1","fold2","fold3","fold4","fold5","ave.")
  out_data = data.frame(set = set, training = round(AUC_train02 , digits = 2) , 
                        validation= round(AUC_valid02, digits = 2) ,	test= round(AUC_test02, digits = 2))
  #getwd()
  write.table(out_data, "Output_5_fold.csv" , row.names = F ,  quote = F, sep =",") #output.filename
  
  
} else if (kfold_num == 10) {
  
  set = c("fold1","fold2","fold3","fold4","fold5","fold6","fold7","fold8","fold9","fold10","ave.")
  out_data = data.frame(set = set, training = round(AUC_train02 , digits = 2) , 
                        validation= round(AUC_valid02, digits = 2) ,	test= round(AUC_test02, digits = 2))
  #getwd()
  write.table(out_data, "output/Output_LR_10_fold.csv" , row.names = F ,  quote = F, sep =",") #output.filename
}



# _______________________ -------------------------------------------------------------------------
# (6) LR: Output LR for Kaggle -------------------------------------------------------------------------

kaggle_test = test_cart

#### 1. Feature engineering ####

# RevolvingUtilizationOfUnsecuredLines
kaggle_test$BaLim_ratio = kaggle_test$RevolvingUtilizationOfUnsecuredLines
kaggle_test$BaLim_ratio[kaggle_test$BaLim_ratio > 1.2] = 1.2
kaggle_test$BL_ratio_log = log(kaggle_test$BaLim_ratio+10)
kaggle_test$BL_ratio_1 = kaggle_test$BaLim_ratio + 1

# age
kaggle_test$age_2 = kaggle_test$age
kaggle_test$age_2[kaggle_test$age_2 == 0 ] = 20

# MonthlyIncome
kaggle_test$Income = kaggle_test$MonthlyIncome
kaggle_test$Income[kaggle_test$Income > 23300] = 23300
kaggle_test$Income_log = log(kaggle_test$Income + 10)

kaggle_test$Income_bool = kaggle_test$MonthlyIncome
kaggle_test$Income_bool[kaggle_test$Income_bool !=0 ] = 1

# NumberOfDependents
kaggle_test$Dep = kaggle_test$NumberOfDependents
kaggle_test$Dep[kaggle_test$Dep > 2] = 2

# DebtRatio
kaggle_test$D_Ratio = kaggle_test$DebtRatio
kaggle_test$D_Ratio[kaggle_test$D_Ratio >= 1200] = 3.7
kaggle_test$D_Ratio[kaggle_test$D_Ratio >4 ] = 5 #7
kaggle_test$D_Ratio[kaggle_test$D_Ratio == 3.7 ] = 6 #10

# NumberOfOpenCreditLinesAndLoans
kaggle_test$OCLAL = log(kaggle_test$NumberOfOpenCreditLinesAndLoans + 1)

# NumberRealEstateLoansOrLines
kaggle_test$REOL = kaggle_test$NumberRealEstateLoansOrLines
kaggle_test$REOL[kaggle_test$REOL > 5] = 5

# NumberOfTime30.59DaysPastDueNotWorse
kaggle_test$Num_30.59 = kaggle_test$NumberOfTime30.59DaysPastDueNotWorse
kaggle_test$Num_30.59[kaggle_test$Num_30.59 > 3] = 3

# NumberOfTime60.89DaysPastDueNotWorse
kaggle_test$Num_60.89 = kaggle_test$NumberOfTime60.89DaysPastDueNotWorse
kaggle_test$Num_60.89[kaggle_test$Num_60.89 > 2] = 2

# NumberOfTimes90DaysLate
kaggle_test$Num_90 = kaggle_test$NumberOfTimes90DaysLate
kaggle_test$Num_90[kaggle_test$Num_90 > 2] = 2
# kaggle_test$Num_90[kaggle_test$Num_90 > 3] = 3

# as.factor
kaggle_test$Dep = as.factor(kaggle_test$Dep)
kaggle_test$REOL = as.factor(kaggle_test$REOL)
kaggle_test$Num_30.59 = as.factor(kaggle_test$Num_30.59)
kaggle_test$Num_60.89 = as.factor(kaggle_test$Num_60.89)
kaggle_test$Num_90 = as.factor(kaggle_test$Num_90)
kaggle_test$Income_bool = as.factor(kaggle_test$Income_bool)

#### 2. Output csv ####
kaggle_probabilities = model %>% predict(kaggle_test,  type = "response")
kaggle_probabilities02 = data.frame( Id = 1:101503 , probability = kaggle_probabilities)
write.csv(kaggle_probabilities02, "output/Kaggle_LR.csv",  row.names = F)
