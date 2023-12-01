# ##################################################################################################
# This script will read the data exported from PsychoPy and check if the subject passed our set of
# quality checks. It will print out the results of these checks. The checks:
#
# 1. Correctly answered >90% of sanity checks.
# 2. Has responded on >90% of all non-sanity check data (i.e. real data).
# 3. Has eyetracking data for >90% of all real data.
#
# Author: Brenden Eum (2023)
#
# Dependencies:
#
#
# Input:
# - *.csv file
#
# Output:
# - print to console
#
# Notes:
# - "! ! !" indicates lines of code that you need to change
# ##################################################################################################

# Preamble.

rm(list=ls())
library(plyr)
library(dplyr)
library(data.table)
datadir <- "/Users/brenden/Downloads" # ! ! !
outdir <- datadir

# Input data.
# Each line in the datatable is one row in the .asc file, as a single string.

subject_id <- 324
fixfilename <- paste0(toString(subject_id), "/", toString(subject_id), "_GainLossTask_")
fixfilename1 <- paste0(fixfilename, "gain1.csv")
fixfilename2 <- paste0(fixfilename, "gain2.csv")
fixfilename3 <- paste0(fixfilename, "loss1.csv")
fixfilename4 <- paste0(fixfilename, "loss2.csv")
gain1 <- read.csv(file.path(datadir, fixfilename1))
gain2 <- read.csv(file.path(datadir, fixfilename2))
loss1 <- read.csv(file.path(datadir, fixfilename3))
loss2 <- read.csv(file.path(datadir, fixfilename4))
rawdata <- do.call("rbind.fill", list(gain1, gain2, loss1, loss2))

# Trim the dataset down to the variables and observations that you want.

voi <- c(
  "participant",
  "session",
  "TrialType",
  "Condition",
  "LProb",
  "LAmt",
  "RProb",
  "RAmt",
  "Response.keys",
  "Response.rt",
  "FixCrossLoc",
  "LROI.timesOn",
  "LROI.timesOff",
  "RROI.timesOn",
  "RROI.timesOff",
  "Sanity"
)
data <- rawdata[rawdata$TrialType == "Trial", voi]

####################################################
## Quality Checks
####################################################

# Correctly answered 90% of sanity checks.

sanity.checks <- data[data$Sanity==1,]
sanity.checks$correctResponse <- ifelse(sanity.checks$LAmt > sanity.checks$RAmt, "left", "right")
sanity.checks$correct <- ifelse(sanity.checks$correctResponse == sanity.checks$Response.keys, 1, 0)
if (mean(sanity.checks$correct) > 0.9) {
  accuracy.check <- T
} else {
  accuracy.check <- F
  print("SANITY CHECK ACCURACY <90%!")
}

# Has responded in more than 90% of non-sanity check ("real") data.

real.data <- data[data$Sanity==0,]
real.data$responseLogged <- real.data$Response.keys != "None"
if (mean(real.data$responseLogged) > 0.9) {
  responseRate.check <- T
} else {
  responseRate.check <- F
  print("RESPONSE RATE <90%!")
}

# Has eyetracking data for more than 90% of real trials.

real.data <- data[data$Sanity==0,]
real.data$ET.L <- !(real.data$LROI.timesOn=="") & !(real.data$LROI.timesOff=="")
real.data$ET.R <- !(real.data$RROI.timesOn=="") & !(real.data$RROI.timesOff=="")
cond <- real.data$ET.L | real.data$ET.R
if (mean(cond) > 0.9) {
  et.check <- T
} else {
  et.check <- F
  print("EYE TRACKING DATA <90%!")
}

# Output the results of all tests so it's easier to see later.

if (!(accuracy.check & responseRate.check & et.check)) {
  print("ONE OF THE TESTS FAILED. GO CHECK, THEN EXCLUDE THIS PARTICIPANT!")
} else {
  print("PARTICIPANT PASSED ALL QUALITY CHECKS.")
}
