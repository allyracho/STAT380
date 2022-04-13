#- Ally Racho
#- STAT 380
#- Final Project
# - PCA / TSNE
######################

library(data.table)
library(ClusterR)
library(Rtsne)

id <- master$id
result <- master$result

master$id<- NULL
master$result <- NULL

#- PCA 
pca <- prcomp(master)
pca_dt <- data.table(unclass(pca)$x)


# TSNE
tsne <- Rtsne(pca_dt, pca = F, preplexity = 30, check_duplicates = F, max_iter = 1000, dims = 2)
tsne_dt1 <- data.table(tsne$Y)


# TSNE
tsne <- Rtsne(pca_dt, pca = F, preplexity = 50, check_duplicates = F, max_iter = 1000, dims = 2)
tsne_dt2 <- data.table(tsne$Y)


# TSNE
tsne <- Rtsne(pca_dt, pca = F, preplexity = 70, check_duplicates = F, max_iter = 1000, dims = 2)
tsne_dt3 <- data.table(tsne$Y)

# combine pca and tsne results into new table
combined <- cbind(pca_dt, tsne_dt1, tsne_dt2, tsne_dt3)
combined$id <- id
combined$result <- result

