library(dplyr)
####### (0)loading data in R  ########
testSubject <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/test/subject_test.txt")
testX <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/test/X_test.txt")
testy <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/test/y_test.txt")

trainSubject <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/train/subject_train.txt")
trainX <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/train/X_train.txt")
trainy <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/train/y_train.txt")

features <- read.table("./Getting and Cleaning Data/project/UCI HAR Dataset/features.txt", as.is = TRUE)
#prevent features' names to be factor#

activities <- read.table( "./Getting and Cleaning Data/project/UCI HAR Dataset/activity_labels.txt")
colnames(activities) <- c("activityId", "activityLabel")

####### (1)Merge the training and the test sets to create one data set #######
humanActivity <- rbind( #bind test and train data by rows#
      cbind(trainSubject, trainX, trainy),
      cbind(testSubject, testX, testy)#bind them by columns#
)
# remove individual data tables to save memory
rm(trainSubject, trainX, trainy, 
   testSubject, testX, testy)

colnames(humanActivity) <- c("subject", features[, 2], "activity")

### (2)Extracts only the measurements on the mean and standard deviation for each measurement.###
humanActivity <- humanActivity[,grep("activity|subject|mean\\(\\)|std\\(\\)",colnames(humanActivity))]

####### (3) Use descriptive activity names to name the activities in the data set #######
humanActivity$activity <- factor(humanActivity$activity, levels = activities[, 1], labels = activities[, 2])

####### (4) Appropriately label the data set with descriptive variable names #######
humanActivityCols <- colnames(humanActivity)

humanActivityCols <- gsub("[\\(\\)-]", "", humanActivityCols)

humanActivityCols <- gsub("^f", "frequencyDomain", humanActivityCols)
humanActivityCols <- gsub("^t", "timeDomain", humanActivityCols)
humanActivityCols <- gsub("Acc", "Accelerometer", humanActivityCols)
humanActivityCols <- gsub("Gyro", "Gyroscope", humanActivityCols)
humanActivityCols <- gsub("Mag", "Magnitude", humanActivityCols)
humanActivityCols <- gsub("Freq", "Frequency", humanActivityCols)
humanActivityCols <- gsub("mean", "Mean", humanActivityCols)
humanActivityCols <- gsub("std", "StandardDeviation", humanActivityCols)

humanActivityCols <- gsub("BodyBody", "Body", humanActivityCols)

colnames(humanActivity) <- humanActivityCols

# (5) From the data set in step 4,  creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject.

humanActivityMeans <- summarise_all(group_by(humanActivity,subject, activity),mean)

# output to file "tidy_data.txt"
 write.table(humanActivityMeans, "tidy_data.txt", row.names = FALSE, quote = FALSE) 
