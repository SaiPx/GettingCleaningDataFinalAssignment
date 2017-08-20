library(data.table)
library(stringr)
library(dplyr)


## Download data file to local folder and unzip contents
if (!file.exists("getdata projectfiles UCI HAR Dataset.zip")) {
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile = "getdata projectfiles UCI HAR Dataset.zip", mode="wb"
        )
        dateDownloaded <- date()
        
        unzip(zipfile="getdata projectfiles UCI HAR Dataset.zip", exdir="./data")
}

## Read training data:
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

## Read test data:
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Append (X,Y)-Training, (X,Y) - Testing and Subject datasets
fullX <- rbind(xTrain, xTest)
fullY <- rbind(yTrain, yTest)
fullSubject <- rbind(subjectTrain, subjectTest)

## Merge X, Y and Subject
## Used cbind which is fast, but issue is cannot decipher "V1" source
## hence renaming "V1" for fullY and fullSubject
colnames(fullY) <- "activityID"
colnames(fullSubject) <- "subjectID"

## Rename columns of X data from features file
## Read features List:
featuresLst <- read.table('./data/UCI HAR Dataset/features.txt')
colnames(fullX) <- featuresLst[,2]

completeDataset <- cbind(fullY, fullSubject, fullX)

## Get all the Mean and Std Dev columns from this dataset
filteredOuput <- completeDataset[grepl("activityID|subjectID|-std|-mean", 
                                       colnames(completeDataset))==TRUE]

## Find Mean down each Activity-Subject combo
aggregateOut <- aggregate(. ~subjectID + activityID, filteredOuput, mean)

## Reading labels of each activity:
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

## Rename the columns of activity labels
colnames(activityLabels) <-c("activityID","activity")

## Create Descriptive Features meaningful using Activity Names
finalOut <- merge(aggregateOut, activityLabels,all.x=TRUE, by="activityID")

## Re-order the columns for readability
setcolorder(finalOut, c("activity",colnames(finalOut)[!(colnames(finalOut)
                                                        %in% c("activity"))]))

## Export the Output to a Text File
write.table(finalOut, "IndependentTidyDataset.txt", row.name=FALSE)

##           -------   End    -------------
