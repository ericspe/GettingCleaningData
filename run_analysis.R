#install libraries if needed and load
if(!"plyr" %in% installed.packages()) install.packages("plyr")
if(!"tidyr" %in% installed.packages()) install.packages("tidyr")
library(plyr)
library(tidyr)

#read the zip file and unzip
datafiles <- unzip("getdata-projectfiles-UCI HAR Dataset.zip")

#extract the relevant files from the zip archive
features <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/features.txt")])
activity_labels <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/activity_labels.txt")])
y_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/y_test.txt")])
x_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/X_test.txt")])
subjects_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/subject_test.txt")])
y_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/y_train.txt")])
x_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/X_train.txt")])
subjects_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/subject_train.txt")])
#rename the columns in activity_labels
names(activity_labels) <- c("activity_code", "activity_label")

#Merges the training and the test sets to create one data set.
x_full <- rbind(x_test, x_train)
y_full <- rbind(y_test, y_train)
subjects_full <- rbind(subjects_test, subjects_train)
#rename the columns in y_full and subjects_full
names(y_full) <- c("activity_code")
names(subjects_full) <- c("subjects")

#Extracts only the measurements on the mean and standard deviation for each measurement. 
#find column indexes for both type of measurments (mean and std)
mean_idx <- grep("mean()+", features[,2])
std_idx <- grep("std()+", features[,2])
#merge the indexes of the columns to retain in a single vector
extract_idx <- sort(c(mean_idx,std_idx))
#create the data frame with only the relevant columns based on the vector of indexes
x_extract <-  x_full[,extract_idx]

#Appropriately labels the data set with descriptive variable names. 
#the labels for the variables are taken from the features
names(x_extract)<- features[extract_idx, 2]

#Uses descriptive activity names to name the activities in the data set
#the activity names are taken fron the activity_label data frame
x_merged <- subset(merge(activity_labels,cbind(subjects_full,y_full, x_extract), by = "activity_code"), select= -activity_code)

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#create a wide data set with the means
x_tidy <- ddply(x_merged[,3:length(names(x_merged))], .(subject=x_merged$subjects, activity_label=x_merged$activity_label), function(x) apply(x,2,mean))
#transform into a long data set
x_tidy_long <- gather(x_tidy, feature, mean, 3:length(names(x_tidy)))
#write tidy data file to the working directory as csv file
write.table(data_long, file='x_tidy.txt', row.names = FALSE, sep='\t')