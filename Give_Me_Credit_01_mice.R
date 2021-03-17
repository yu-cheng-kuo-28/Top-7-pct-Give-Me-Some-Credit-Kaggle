
#  Missing value implementation-------------------------------------------------------------------------

#### 1.Paste on your own directory ####
setwd("D:\\G02_2\\business_R\\FINAL\\FINAL")


#### 2. Input ####
cs_training = read.table("Data/train.csv", sep=",", quote = "\"",header = T)
cs_test = read.table("Data/test.csv", sep=",", quote = "\"",header = T)

cs_training02 = cs_training[-c(1,2)]
cs_test02 = cs_test[-c(1,2)]
train_ans = cs_training[2]


#### 3. Dealing with a weird datum ####
cs_training02[65696,3] = NA


#### 4. mice( ) ####
require(mice)

mice.data_train <- mice(cs_training02,
                        m = 1,           # 
                        maxit = 1,      # max iteration
                        method = "cart", 
                        seed = 188,
                        print= T )      

mice.data_test <- mice(cs_test02,
                       m = 1,           # 
                       maxit = 1,      # max iteration
                       method = "cart", 
                       seed = 188,
                       print= T )   

df_train <- complete(mice.data_train, 1)
df_test <- complete(mice.data_test, 1)

cs_all_cart = rbind(df_train, df_test)

write.csv(cs_all_cart, "cs_all_cart.csv",  row.names = F)
write.csv(train_ans, "train_ans.csv",  row.names = F)
