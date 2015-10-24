## run_analysis.R

### Introduction

The following describes the steps required to process the analysis

### Install libraries if needed and load them
```{r}
if(!"plyr" %in% installed.packages()) install.packages("plyr")
if(!"tidyr" %in% installed.packages()) install.packages("tidyr")
library(plyr)
library(tidyr)
```

### Read the zip file and unzip

* the zip file need to get downloaded first into the working directory:
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "getdata-projectfiles-UCI HAR Dataset.zip")
* the local file name is: getdata-projectfiles-UCI HAR Dataset.zip

```{r}
datafiles <- unzip("getdata-projectfiles-UCI HAR Dataset.zip")
```

### Extract the relevant files from the zip archive
 
* features
* activity_labels
* x_test
* y_test
* subject_test
* x_train
* y_train
* subject_train

the indexes of the files are found using their full name

```{r}
features <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/features.txt")])
activity_labels <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/activity_labels.txt")])
y_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/y_test.txt")])
x_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/X_test.txt")])
subjects_test <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/test/subject_test.txt")])
y_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/y_train.txt")])
x_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/X_train.txt")])
subjects_train <- read.table(datafiles[which(datafiles =="./UCI HAR Dataset/train/subject_train.txt")])
```
### Rename the columns in activity_labels

* 1 : activity_code
* 2 : activity_label

```{r}
names(activity_labels) <- c("activity_code", "activity_label")
```
### Merge the training and the test sets to create one data set

append the the train data frame to the test ones for x, y and subjects into the full data frames

* x_full : observations and variables
* y_full : activity codes for each observation
* subjects_full : subject number for each observation

```{r}
x_full <- rbind(x_test, x_train)
y_full <- rbind(y_test, y_train)
subjects_full <- rbind(subjects_test, subjects_train)
```
### Rename the columns in y_full and subjects_full

* y_full : activity_code
* subject_full : subjects

```{r}
names(y_full) <- c("activity_code")
names(subjects_full) <- c("subjects")
```
### Extract only the measurements on the mean and standard deviation for each measurement. 

find column indexes for both type of measurments mean() and std() using grep
store the indexes in the vectors:

* mean_idx : having the indexes of the columns that contain "mean" in the header text
* std_idx : having the indexes of the columns that contain "std" in the header text

the variables "meanFreq()" are excluded

```{r}
mean_idx <- grep('mean\\(',features[,2])
std_idx <- grep('std\\(',features[,2])
```

### Merge the indexes of the columns to retain in a single vector

create the concatenated vector extract_id using mean_idx and std_idx as sorted indexes of the columns to keep

```{r}
extract_idx <- sort(c(mean_idx,std_idx))
#create the data frame with only the relevant columns based on the vector of indexes
x_extract <-  x_full[,extract_idx]
```

### Appropriately labels the data set with descriptive variable names

extract the column header (labels) from the features data frame based on the indexes in extract_idx 

```{r}
#the labels for the variables are taken from the features
names(x_extract)<- features[extract_idx, 2]
```

### Uses descriptive activity names to name the activities in the data set

the activity names are taken fron the activity_label data frame
this achieved by joining on activity_code the data frames activity_labels and a by column concatenated data frame of subjects_full, y_full, x_extract

```{r}
x_merged <- subset(merge(activity_labels,cbind(subjects_full,y_full, x_extract), by = "activity_code"), select= -activity_code)
```

### From the data set x_merged, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

create a wide data set x_tidy with the means for each variable by subject and activity
the function ddply (plyr library) is used to compute the mean on all the variables of x_merged exept the 2 firsts that list the subjects and activities; these varible are renamed subject and activity:label respectively

```{r}
x_tidy <- ddply(x_merged[,3:length(names(x_merged))], .(subject=x_merged$subjects, activity_label=x_merged$activity_label), function(x) apply(x,2,mean))
```
### Transform into a long data set

the two first columns of the x_tidy data frame are kept as is, from the 3rd to the last column, the headers are mapped to the new variable "feature" and the means to "mean"
the function gather (tidyr library) gets used for this transformation 

```{r}
x_tidy_long <- gather(x_tidy, feature, mean, 3:length(names(x_tidy)))
```

### Write tidy data file to the working directory as txt file

* x_tidy.txt file (tab delimited) 

```{r}
write.table(x_tidy_long, file='x_tidy.txt', row.names = FALSE, sep='\t')
```
