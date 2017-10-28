# Purpose of this code is to convert provided UCI data set to a tidy data set.

#---loading the relevant libraries 
library(httr)
library(dplyr)
library(reshape2)

#-----Original Dataset link
# Dataset URL link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Step 1: Downloaded the file and unzipped the file to a directory labeled UCI-dataset

if(!file.exists("./UCI-dataset")){dir.create("./UCI-dataset")}

# Step 2: Reading data sets from the train and test directories in the unzipped file

X_train <- read.table("./UCI-dataset/train/X_train.txt")
X_test <- read.table("./UCI-dataset/test/X_test.txt")

subject_test <-read.table("./UCI-dataset/test/subject_test.txt")
subject_train <-read.table("./UCI-dataset/train/subject_train.txt")

y_train <- read.table("./UCI-dataset/train/y_train.txt")
y_test <- read.table("./UCI-dataset/test/y_test.txt")


#Step 3: Reading label headers from the activity_labels and features text files in the unzipped file
# using gsub to replace the numerical strings at the end some of the variable names
variable_names<-read.table("./UCI-dataset/features.txt")
variable_names[,2]<-gsub("(-*[0-9]*,[0-9]*[0-9]*)", "", variable_names[,2])
activity_labels<-read.table("./UCI-dataset/activity_labels.txt")

# Project Deliverables
# --------------------------------------------------
#(1) Using rbind to merge the training and the test sets to create one data set for x, y and subject sets
x_set<- rbind(X_train, X_test)
y_set<- rbind(y_train, y_test)
subject_set<-rbind(subject_train, subject_test)

# assigning column names to the x,y and subject sets from the provided features.txt 
names(x_set)<-variable_names[,2]
names(y_set)<-c("activity")
names(subject_set)<-c("subject_ID")

# creating an overall data set by column binding of subjects, x and y data sets
all_data <-cbind(subject_set,x_set, y_set)
#--------------------------------------------------

#(2) Searching for mean() and std() using grep() 
# there are multiple regular expressions for searching mean() or for mean in the variable name
# the below selected regular expression resulted in more variables than the others i looked at 
# the below list includes all occurences of mean and std in time and frequency domain variables

selected_id <- variable_names[grep(".*mean.*|.*std.*",variable_names[,2]),]
x_subset_meansd <- x_set[,selected_id[,1]]

#(3) Use descriptive activity names for the activities in the dataset by defining factors
all_data$subject_ID <- as.factor(all_data$subject_ID)
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
#--------------------------------------------------

#(4) Label the dataset with descriptive variable names
names(all_data)<-c(names(subject_set), names(x_set), names(y_set))
#--------------------------------------------------

#(5) Create an independent tidy data set with average of each variable for each activity and each subject
# using melt and dcast from the reshape2 package 
all_data_melted <- melt(all_data,id = c("activity", "subject_ID"))
all_data_casted <- dcast(all_data_melted, activity+subject_ID ~ variable, mean)

# using write.table to output the tidydata.txt
write.table(all_data_casted,"./UCI-dataset/tidydata.txt", row.names=FALSE, quote=FALSE)
#--------------------------------------------------


