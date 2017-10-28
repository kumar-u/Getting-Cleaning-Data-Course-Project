README.md summarizes the project description, methodology, tidydata steps and details of the run_anlaysis.R code.

------------------------------------------------------
- Section A: Variable Selection Background
- Source: features_info.txt from the provided UCI Dataset
- Source: README.txt from the provided UCI Dataset
- Dataset URL link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
- Reference: Useful tips for completing this project; https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/
- Reference: Components of Tidy Data: https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html

----------------------------------------------------------
**Project Description and Background**

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
Review criteria 
1)The submitted data set is tidy.
2)The Github repo contains the required scripts.
3)GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, 
along with units, and any other relevant information.
4)The README that explains the analysis files is clear and understandable.
5) The work submitted for this project is the work of the student who submitted it.

**Getting and Cleaning Data Course Project**

The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. 
The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The dataset used for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Goal: create one R script called run_analysis.R that does the following.

1)Merges the training and the test sets to create one data set.
2)Extracts only the measurements on the mean and standard deviation for each measurement.
3)Uses descriptive activity names to name the activities in the data set
4)Appropriately labels the data set with descriptive variable names.
5)From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

-----------------

Code run_analysis. R that was used to convert raw data to tidy data

------------------
INPUT FILES from the provided UCI dataset needed for running the code
- X_train.txt, X_test.txt;
- subject_train.txt,subject_test.txt;
- y_train.txt, y_test.txt;
- features.txt and activity_labels.txt


OUTPUT FILES from run_analysis.R
1) tidydata.txt with the average of each variable for each activity and each subject
----------------------------------------------------

**How run_analysis.R script works:**

---loading the relevant libraries 
library(httr)
library(dplyr)
library(reshape2)

-----Original Dataset link

Dataset URL link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Step 1: Downloaded the file and unzipped the file to a directory labeled UCI-dataset

if(!file.exists("./UCI-dataset")){dir.create("./UCI-dataset")}

Step 2: Reading data sets from the train and test directories in the unzipped file
Please refer to the attached CodeBook.md for description of the test variables. Dataset also contains README.txt that gives a descriptive background for data collection

Read.table was used to read the train, test data for X, Y and subject datasets
X_train <- read.table("./UCI-dataset/train/X_train.txt")
X_test <- read.table("./UCI-dataset/test/X_test.txt")

subject_test <-read.table("./UCI-dataset/test/subject_test.txt")
subject_train <-read.table("./UCI-dataset/train/subject_train.txt")

y_train <- read.table("./UCI-dataset/train/y_train.txt")
y_test <- read.table("./UCI-dataset/test/y_test.txt")


Step 3: Reading label headers from the activity_labels and features text files in the unzipped file
Using gsub to replace the numerical strings at the end some of the variable names
variable_names<-read.table("./UCI-dataset/features.txt")
variable_names[,2]<-gsub("(-*[0-9]*,[0-9]*[0-9]*)", "", variable_names[,2])
activity_labels<-read.table("./UCI-dataset/activity_labels.txt")

Project Deliverables
--------------------------------------------------
(1) Using rbind to merge the training and the test sets to create one data set for x, y and subject sets
- x_set<- rbind(X_train, X_test)
- y_set<- rbind(y_train, y_test)
- subject_set<-rbind(subject_train, subject_test)


assigning column names to the x,y and subject sets from the provided features.txt 
- names(x_set)<-variable_names[,2]
- names(y_set)<-c("activity")
- names(subject_set)<-c("subject_ID")


creating an overall data set by column binding of subjects, x and y data sets
-all_data <-cbind(subject_set,x_set, y_set)

--------------------------------------------------

(2) Searching for mean() and std() using grep() 
there are multiple regular expressions for searching mean() or for standard deviation in the variable name. the below selected regular expression resulted in more variables than the others i looked at and since no clear information was provided on what variables to include,the below list includes all occurences of mean and std in time and frequency domain variable definitions.

- selected_id <- variable_names[grep(".*mean.*|.*std.*",variable_names[,2]),]
- x_subset_meansd <- x_set[,selected_id[,1]]


--------------------------------------------------

(3) Use descriptive activity names for the activities in the dataset by defining factors
- all_data$subject_ID <- as.factor(all_data$subject_ID)
- all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])


--------------------------------------------------

(4) Label the dataset with descriptive variable names
-names(all_data)<-c(names(subject_set), names(x_set), names(y_set))

--------------------------------------------------

(5) Create an independent tidy data set with average of each variable for each activity and each subject
using melt and dcast from the reshape2 package 
- all_data_melted <- melt(all_data,id = c("activity", "subject_ID"))
- all_data_casted <- dcast(all_data_melted, activity+subject_ID ~ variable, mean)


using write.table to output the tidydata.txt 
- write.table(all_data_casted,"./UCI-dataset/tidydata.txt", row.names=FALSE, quote=FALSE)


--------------------------------------------------


