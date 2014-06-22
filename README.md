#Getting-and-Cleaning-Data 


### Course Project Instructions
>The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to >prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions >related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github >repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and >any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a  >README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

>One of the most exciting areas in all of data science right now is wearable computing - see for example this article . >Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.  >The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S  >smartphone. A full description is available at the site where the data was obtained: 

>http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

>Here are the data for the project: 

>https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

>You should create one R script called run_analysis.R that does the following. 
>Merges the training and the test sets to create one data set.
>Extracts only the measurements on the mean and standard deviation for each measurement. 
>Uses descriptive activity names to name the activities in the data set
>Appropriately labels the data set with descriptive variable names. 
>Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
>Good luck!

### My problem restatement and high level notes on my approach to solving this assignment
Problem:
In the original data set, the X_[test|train].txt files contains the main facts or measures, but it does not identify what each activity was, or which subject was performing the activity. Additionally, it does not contain a column header that explains what each column is. We need to combine the data to tidy it up.

####Step 0 - Clean up the Column Names to Prepare for Combination with Data:

The features.txt file contains the column headers/names for the X_[test|train].txt file,but the column names are listed down the rows. Once we load this file in, we can pass the second column of this data frame to the col.names parameter of read.table when we read in the X_[test|train].txt sets. Before we can do this, however, we need to substitue potentially problematic characters in the column names to ease future programmatic utility as well as enhance human readability. A "t" character at the beginning of a variable name represents "time", according to the features_info.txt file, so we will replace that with "time_". An "f" character at the beginning of a var name indicates "frequency", so we will replace the beginning "f" with "frequency_".


####Step 1 - Load Main Data and Indicate as Test or Train:
We need to load the X_test.txt and X_train.txt data sets in separately, and then add a column to each identifying it as test or train, so that when they are later combined into a single data set, we can subset them apart. This column will contain factor values "TEST" or "TRAIN", and will be called "SET_INDICATOR".

####Step 2 - Add Subject and Activity IDs:
Additionally, before combining the sets, we will add additional columns to identify each row with it's activity and subject. The subject information is in the subject[test|train].txt file, and the activity information is in the y_[test|train].txt. However, the activity labels are in the activity_lables.txt file, which identifies the IDs as WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING.

For subject, we can just add the column to the X_[test|train] set using variable creation, but for the activity, it would be more useful to have the name of the activity, rather than the meaningless integer, so after adding the integer column representing the activity, we merge (join) the  y_[test|train] sets with the activity_labels, so we will have the more useful information along with the id. We have to add the ID onto the X sets first, because if we do the merge first, it destroys the order of the ids, which is the only information we have to map them to the correct X set observation/row. 

####Step 3 - Combine Train and Test Sets:
Next we combine the train and test data using rbind


####Step 4 - Get Mean and Std Columns with ID Columns:
Next, we subset just the columns whose names contain the text "mean" or "std" along with the SUBJECT_ID, ACTIVITY_LABEL, and the SET_INDICATOR, using the matchcols function from the gdata package. The Activity ID is not important in the end. We will save the tidy data set as a csv file "tidy.csv"


####Step 5 - Take Average of Every Measure by Subject and Activity:
Finally, we need to take the average of every variable for each activity and subject. This requires the melt function from the reshape2 package, and the ddply function from the plyr package.
