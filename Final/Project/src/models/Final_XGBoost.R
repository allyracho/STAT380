#- Ally Racho
#- STAT 380
#- Final Project
# - XGBoost
######################
library(xgboost)

#- split master into test/train
train <- combined[result != 11]
test <- combined[result == 11]

train_y <- train$result
train_id <- train$id
test_id <- test$id

#- subset out columns not needed in model
drops <- c('id', 'result')

#- create new data table with only columns to model
train_mod <- train[, !drops, with = FALSE]
test_mod <- test[, !drops, with = FALSE]


#- XGBoost
x.train <-as.matrix(train_mod)
x.test <-as.matrix(test_mod)

dtrain <- xgb.DMatrix(x.train, label = train_y, missing = NA)
dtest <- xgb.DMatrix(x.test, missing = NA)

hyper_parm_tune <- NULL

# for loop for hyper-tuning
# found eta = .01, max depth 6 to be best
eta <- c(.01, .001, .0001, .02, .05)
max_depth <- c(6, 10, 15, 20, 25, 30)

for (i in eta){
  for (j in max_depth){
    param <- list(objective = "multi:softprob",
              gamma = .02, 
              booster = "gbtree", 
              eval_metric = "mlogloss",
              eta = i, 
              max_depth = j,
              min_child_weight = 1,
              subsample = 1, 
              colsample_bytree = 1.0, 
              tree_method = "hist", 
              num_class = 10
)
XGBfit <- xgb.cv(params = param,
                 nfold = 4,
                 nrounds = 100000, 
                 missing = NA,
                 data = dtrain,
                 print_every_n = 1,
                 early_stopping_rounds = 25)

best_tree_n <- unclass(XGBfit)$best_iter
new_row <- data.table(t(param))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_mlogloss_mean
new_row$test_error <- test_error
hyper_parm_tune <- rbind(new_row, hyper_parm_tune)
}
}
watchlist <- list(train = dtrain)

XGBfit <- xgb.train(params = param,
                    nrounds = best_tree_n, 
                    missing = NA,
                    data = dtrain,
                    watchlist = watchlist,
                    print_every_n = 1)

test_mod$id <- test_id

#- predict fit
result <- matrix(predict(XGBfit, newdata = dtest), ncol = 10, nrow = 20555, byrow = TRUE)
submit <- cbind(result,test_id)

submit <- data.table(submit)
names(submit)[names(submit) == 'V1'] <- "subredditcars"
names(submit)[names(submit) == 'V2'] <- "subredditCooking"
names(submit)[names(submit) == 'V3'] <- "subredditMachineLearning"
names(submit)[names(submit) == 'V4'] <- "subredditmagicTCG"
names(submit)[names(submit) == 'V5'] <- "subredditpolitics"
names(submit)[names(submit) == 'V6'] <- "subredditReal_Estate"
names(submit)[names(submit) == 'V7'] <- "subredditscience"
names(submit)[names(submit) == 'V8'] <- "subredditStockMarket"
names(submit)[names(submit) == 'V9'] <- "subreddittravel"
names(submit)[names(submit) == 'V10'] <- "subredditvideogames"
names(submit)[names(submit) == 'test_id'] <- "id"


#- save model
saveRDS(XGBfit, "./project/volume/models/xgboost_model.R")


#- create submit table and save
fwrite(submit, "./project/volume/data/processed/submit_model.csv")
