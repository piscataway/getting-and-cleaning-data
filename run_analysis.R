## Getting and Cleaning Data Course Project 
## Review Criteria: 
## The submitted data set is tidy. 
## The Github repo contains the required scripts.
## GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
## The README that explains the analysis files is clear and understandable.

# load libraries 
library(data.table)
library(reshape2)
library(dplyr)
library(plyr)
library(tidyr)

# download and store data
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
datasetinfo <- 'http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones'
filename <- "HARdata.zip"

if (!file.exists(filename)) {
  download.file(url, destfile = "HARdata.zip")
}

# unzip dataset 
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# read in training data 
subjecttrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
activitytrain <- read.table("UCI HAR Dataset/train/y_train.txt")
featurestrain <- read.table("UCI HAR Dataset/train/x_train.txt")

# read in test data  
subjecttest <- read.table("UCI HAR Dataset/test/subject_test.txt")
activitytest <- read.table("UCI HAR Dataset/test/y_test.txt")
featurestest <- read.table("UCI HAR Dataset/test/x_test.txt")

# Merge training and test data 
subjectmerge <- rbind(subjecttrain, subjecttest)
activitymerge <- rbind(activitytrain, activitytest)
featuresmerge <- rbind(featurestrain, featurestest)
allmerged <- cbind(subjectmerge, activitymerge, featuresmerge)

# Load metadata: features and activity labels 
featurenames <- read.table("UCI HAR Dataset/features.txt")
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")

# extract only the measurements on the mean and standard deviation for each measurement
extractFeatures <- grep(".*mean.*|.*std.*", featurenames[,2])
extractFeaturesNames <- featurenames[extractFeatures,2]

# clean column names to increase readabilty 
extractFeaturesNames <- gsub("-mean", "Mean", extractFeaturesNames)
extractFeaturesNames <- gsub("-std", "Std", extractFeaturesNames)
extractFeaturesNames <- gsub("[-()]", "", extractFeaturesNames)
extractFeaturesNames <- gsub("^t", "Time", extractFeaturesNames)
extractFeaturesNames <- gsub("^f", "Frequency", extractFeaturesNames)

# add cleaned labels to merged dataset
colnames(allmerged) <- c("subject", "activity", extractFeaturesNames)

# convert activities and subjects to factors
allmerged$Activity <- factor(allmerged$activity, levels = activitylabels[,1], labels = activitylabels[,2])
allmerged$Subject <- as.factor(allmerged$subject)

# generate tidy data set and output txt file
tidydata <- aggregate(. ~subject + activity, allmerged, mean)
tidydata <- tidydata[order(tidydata$subject,tidydata$activity),]
write.table(tidydata, "tidydata.txt", row.name=FALSE)

