# Problem:
# In the original data set, the X_[test|train].txt files contains the main facts or measures, but it does not identify what each activity was, or which subject was performing the activity. Additionally, it does not contain a column header that explains what each column is. We need to combine the data to tidy it up.

# Set up environment

# Create function to test for and install a package, if it isn't installed
# Fails script if install isn't successful.
# http://stackoverflow.com/questions/9341635/how-can-i-check-for-installed-r-packages-before-running-install-packages
pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}
pkgTest("gdata")
pkgTest("reshape2")
pkgTest("plyr")

setwd("~/github/local")
dir.create("Getting and Cleaning Data Course Project/data/raw")
setwd("Getting and Cleaning Data Course Project/data/raw")
if(!file.exists("FUCI HAR Dataset.zip"))
{
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="FUCI HAR Dataset.zip", method="curl")
}
unzip("FUCI HAR Dataset.zip")

# High level solution is numbered below

# Step 0 - Clean up the Column Names to Prepare for Combination with Data:
# The features.txt file contains the column headers/names for the X_[test|train].txt file,but the column names are listed down the rows. Once we load this file in, we can pass the second column of this data frame to the col.names parameter of read.table when we read in the X_[test|train].txt sets. Before we can do this, however, we need to substitue potentially problematic characters in the column names to ease future programmatic utility as well as enhance human readability. A "t" character at the beginning of a variable name represents "time", according to the features_info.txt file, so we will replace that with "time_". An "f" character at the beginning of a var name indicates "frequency", so we will replace the beginning "f" with "frequency_".
features = read.table("UCI HAR Dataset/features.txt")

features$V2 = gsub("^t", "time_", features$V2)
features$V2 = gsub("^f", "frequency_", features$V2)

# Remove all open and close parens: (), as they are superfluous; adding no useful information
features$V2 = gsub("[()]", "", features$V2)

# We also need to replace all special R characters, which are dash (minus sign), plus sign, and comma with underscores "_"
features$V2 = gsub("[-+,]", "_", features$V2)

# Step 1 - Load Main Data and Indicate as Test or Train:
# We need to load the X_test.txt and X_train.txt data sets in separately, and then add a column to each identifying it as test or train, so that when they are later combined into a single data set, we can subset them apart. This column will contain factor values "TEST" or "TRAIN", and will be called "SET_INDICATOR".
train_X = read.table("UCI HAR Dataset/train/X_train.txt", col.names=features$V2)
test_X = read.table("UCI HAR Dataset/test/X_test.txt", col.names=features$V2)

train_X$SET_INDICATOR = "TRAIN"
test_X$SET_INDICATOR = "TEST"


# Step 2:
# Additionally, before combining the sets, we will add additional columns to identify each row with it's activity and subject. The subject information is in the subject[test|train].txt file, and the activity information is in the y_[test|train].txt. However, the activity labels are in the activity_lables.txt file, which identifies the IDs as WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING.

# For subject, we can just add the column to the X_[test|train] set using variable creation, but for the activity, it would be more useful to have the name of the activity, rather than the meaningless integer, so after adding the integer column representing the activity, we merge (join) the  y_[test|train] sets with the activity_labels, so we will have the more useful information along with the id. We have to add the ID onto the X sets first, because if we do the merge first, it destroys the order of the ids, which is the only information we have to map them to the correct X set observation/row. 

# Read in subject files
train_Subject = read.table("UCI HAR Dataset/train/subject_train.txt")
test_Subject = read.table("UCI HAR Dataset/test/subject_test.txt")

# Add subject column to core data set
train_X$SUBJECT_ID = train_Subject$V1
test_X$SUBJECT_ID = test_Subject$V1

# Read in activity labels file, giving column names
activity_labels = read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("ACTIVITY_ID", "ACTIVITY_LABEL"))

# Read in activities for each observation
train_activity_ids = read.table("UCI HAR Dataset/train/y_train.txt")
test_activity_ids = read.table("UCI HAR Dataset/test/y_test.txt")

# Add ACTIVITY_ID column to the train and test sets
train_X$ACTIVITY_ID = train_activity_ids$V1
test_X$ACTIVITY_ID = test_activity_ids$V1

# Merge [train|test]_X with with activity labels
train_X = merge(train_X, activity_labels, by.x="ACTIVITY_ID", by.y="ACTIVITY_ID",all.x=TRUE)
test_X = merge(test_X, activity_labels, by.x="ACTIVITY_ID", by.y="ACTIVITY_ID", all.x=TRUE)

# Step 3: 
# Next we need to combine the train and test data
combined = rbind(train_X, test_X)

# Step 4:
# Now we need to subset just the columns whose names contain the text "mean" or "std" along with the SUBJECT_ID, ACTIVITY_LABEL, and the SET_INDICATOR. The Activity ID is not important in the end. We will save the tidy data set as a csv file "tidy.csv"
stdAndMeanCols = matchcols(combined, with=c("std", "mean"), method="or")
tidy = combined[ , c("SUBJECT_ID", "ACTIVITY_LABEL", "SET_INDICATOR", stdAndMeanCols$std, stdAndMeanCols$mean)]

write.csv(tidy, "../tidy.csv")

# Step 5:
# Finally, we need to take the average of every variable for each activity and subject. This requires 

# Get the ID column names and the fact column names in separate char vectors
idCols = matchcols(tidy, with=c("SUBJECT_ID", "ACTIVITY_LABEL"), method="or")
factCols = matchcols(tidy, without=c("SUBJECT_ID", "ACTIVITY_LABEL", "SET_INDICATOR"), method="or")

# Reshape the data, unpivoting fact columns to rows
tidyMelt = melt(tidy, id=idCols, measure.vars=factCols)

# use ddply from the plyr package to summarize the data by activity label and subject id.
tidyAvg = ddply(tidyMelt, .(SUBJECT_ID, ACTIVITY_LABEL), summarize, mean=mean(value))

write.csv(tidyAvg, "../tidyAvg.csv")

