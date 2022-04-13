#- Ally Racho
#- STAT 380
#- Final Project
# - Feature Engineering
######################

rm(list = ls())
library(data.table)

train <- fread("./Project/volume/data/raw/train_data.csv")
test <- fread("./Project/volume/data/raw/test_file.csv")
train_emb <- fread("./Project/volume/data/raw/train_emb.csv")
test_emb <- fread("./Project/volume/data/raw/test_emb.csv")
examp <- fread("./Project/volume/data/raw/example_sub.csv")


train <- melt(train, id.vars = c("id"), measure.vars = c("subredditcars", "subredditCooking",
                                                      "subredditMachineLearning", "subredditmagicTCG","subredditpolitics", 
                                                      "subredditReal_Estate", "subredditscience", "subredditStockMarket", 
                                                      "subreddittravel", "subredditvideogames"), variable.name = "subreddit")
train <- train[value==1] 
train$result <- 0

train[subreddit == 'subredditcars']$result = 0
train[subreddit == 'subredditCooking']$result = 1
train[subreddit == 'subredditMachineLearning']$result = 2
train[subreddit == 'subredditmagicTCG']$result = 3
train[subreddit == 'subreddipolitics']$result =4
train[subreddit == 'subredditReal_Estate']$result = 5
train[subreddit == 'subredditscience']$result = 6
train[subreddit == 'subredditStockMarket']$result =7
train[subreddit == 'subreddittravel']$result = 8
train[subreddit == 'subredditvideogames']$result = 9


test$result <- 11


#- Master 
train <- cbind(train, train_emb)
test <- cbind(test, test_emb)

test$text <-NULL
subreddit <- train$subreddit
train$subreddit <-NULL
train$value <-NULL


master <- data.table(rbind(train, test))

# save new data tables
## these files were removed from submission due to being too large
fwrite(train,"./project/volume/data/interim/train.csv")
fwrite(test,"./project/volume/data/interim/test.csv")
