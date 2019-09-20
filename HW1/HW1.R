## First load the dataset

setwd("E:\\Study\\Data Science for Business\\HW1\\")
housing.df = read.csv("bostonHousing.csv")
summary(housing.df)

## Since CAT..MEDV is entirely dependent on MEDV, drop this column
x = housing.df[,1:14]
summary(x)

# DecisionTree

## split the data
set.seed(1)  
train.index = sample(c(1:dim(x)[1]), dim(x)[1]*0.6) 
train.df = x[train.index, ]
valid.df = x[-train.index, ]

## build tree
library(party)
tr = ctree(MEDV ~ ., data = train.df)
plot(tr, type = "simple")
pred = predict(tr, newdata = valid.df)

###install.packages('e1071', dependencies=TRUE)

## confusion matrix
## Here, use if-statement to transform MEDV into categorical values
library(caret)
confusionMatrix(as.factor(ifelse(pred >= 30, 1, 0)), as.factor(ifelse(valid.df$MEDV >= 30, 1, 0)))
library(AUC)
r = roc(as.factor(ifelse(pred >= 30, 1, 0)), as.factor(ifelse(valid.df$MEDV >= 30, 1, 0)))
auc_tree = auc(r)
## Save the auc variable for later use
auc_tree




# KNN alogrithm

## split the data
set.seed(1)  
train.index = sample(c(1:dim(x)[1]), dim(x)[1]*0.6) 
train.df = x[train.index, ]
valid.df = x[-train.index, ]

## NORMALIZATION for KNN;
## We did train-test split first, so the validation set should be scaled using the same metric
nor_train = function(train) {(train -min(train))/(max(train)-min(train))}
nor_test = function(test,train){
  (test -min(train))/(max(train)-min(train))
}

data_norm_train.df = as.data.frame(lapply(train.df, nor_train))
data_norm_valid.df = as.data.frame(mapply(nor_test, valid.df, train.df)) 
###summary(data_norm_train.df)
###summary(data_norm_valid.df)

## Iteratively find the best hyper-parameter k 
## we use knn regression model because we are dealing with regression
enumerator = c(1,2,3,4,5,6,7,8,9,10)
maxAuc = 0
max_num = 0
for (num in enumerator)
{
  knn = knnreg(MEDV ~ ., data = data_norm_train.df,k = num)
  pred = predict(knn, newdata = data_norm_valid.df)
  ## Identification for "30" would also be normalized
  ## From "summary", we know min = 5, max = 50
  ## Therefore,(30-5)/(50-5) = 0.5555556
  thresh = (30-5)/(50-5)
  r = roc(as.factor(ifelse(pred >= thresh, 1, 0)), as.factor(ifelse(data_norm_valid.df$MEDV >= thresh, 1, 0)))
  auc_knn = auc(r)
  if (auc_knn > maxAuc){
    maxAuc = auc_knn
    max_num = num
  }
}
max_num
## The best param k is 3

## Compare AUC between DecisionTree and KNN
auc_tree
maxAuc
## We would use DecisionTree

## The prediction set
CRIM = c(0.2) 
ZN= c(0) 
INDUS = c(7) 
CHAS = c(0) 
NOX = c(0.538) 
RM = c(6) 
AGE = c(62)
DIS = c(4.7) 
RAD = c(4) 
TAX = c(307) 
PTRATIO = c(21) 
B = c(360) 
LSTAT = c(10) 

## Tune the data-type
housing_pred.df <- data.frame(CRIM = as.numeric(CRIM), 
                                 ZN = as.numeric(ZN),
                                 INDUS = as.numeric(INDUS),
                                 CHAS = as.integer(CHAS),
                                 NOX = as.numeric(NOX),
                                 RM = as.numeric(RM),
                                 AGE = as.numeric(AGE),
                                 DIS = as.numeric(DIS),
                                 RAD = as.integer(RAD),
                                 TAX = as.integer(TAX),
                                 PTRATIO = as.numeric(PTRATIO),
                                 B = as.numeric(B),
                                 LSTAT = as.numeric(LSTAT))

###str(housing_pred.df)

## Predict
pred = predict(tr, newdata = housing_pred.df)
pred
as.numeric(pred > 30)
