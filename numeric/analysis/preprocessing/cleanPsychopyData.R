# ##################################################################################################
# This script will read the data exported from PsychoPy and clean it into a dataset ready for
# analysis. This Psychopy data already includes ROI ET data, so there is no need to process the EDF
# or ASC files.
# Author: Brenden Eum (2023)
#
# Dependencies:
#
#
# Input:
# - *.csv file from PsychoPy
#
# Output:
# - cfr.Rdata
#
# One observation in this dataset is a subject-trial-fixation.
#
# Variables:
#   Trial: Trial Number
#   Participant: Participant Number
#   Session: Session Number
#   Condition: Gain or Loss
#   Choice: 1 is left, 0 is right
#   RT: Response time in seconds
#   LRdiff: Left expected value minus right expected value
#   Lev: Left expected value
#   Rev: Right expected value
#   LProb: Left probability of win
#   LAmt: Left amount if win
#   RProb: Right probability of win
#   RAmt: Right amount if win
#   Correct: 1 if Choice equals CorrectAnswer, 0 otherwise
#   CorrectAnswer: The side with the higher expected value (1 left, 0 right)
#   Sanity: Was this a sanity check trial? (Sanity checks are very easy trials meant to check attentiveness.)
#   FixCrossLoc: What part of the screen was the fixation cross on? (1 left, 0 right, 2 center)
#   FixNum: Which fixation was this in the trial? (first, second, third, etc...)
#   FixStart: When did the fixation start with respect to the lotteries being presented? In seconds.
#   FixEnd: When did the fixatoin end wrt the lotteries being presented? In seconds.
#   FixLoc: Where was the fixation? (1 left, 0 right, 3 neither).
#   FixDur: How long did the fixation go? In seconds.
#
# Notes:
# - "! ! !" indicates lines of code that you need to change
# ##################################################################################################

# Preamble.

rm(list=ls())
library(dplyr)
library(tidyr)
library(data.table)
datadir <- "D:/OneDrive - California Institute of Technology/PhD/Rangel Lab/2023-gain-loss-attention/numeric/experiment/code/data" # ! ! !
outdir <- datadir

# Input data.
# Each line in the datatable is one row in the .asc file, as a single string.

fixfilename <- "123456_GainLossTask_2023-06-07_14h08.33.756"                                        # ! ! !
fixfilename <- paste0(fixfilename, ".csv")
subject_id <- as.integer(substr(fixfilename,1,6))
rawdata <- read.csv(file.path(datadir, fixfilename))

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
  "LLottery.timesOn",
  "LLottery.timesOff",
  "RLottery.timesOn",
  "RLottery.timesOff",
  "Sanity"
)
data <- rawdata[rawdata$TrialType == "Trial", voi]
data <- rename(
  data,
  Participant = participant,
  Session = session,
  Choice = Response.keys,
  RT = Response.rt
)


####################################################
## Make New Variables or Transform Old Ones
####################################################

# Add trial number

data <- data %>% mutate(Trial = row_number())

# Choice (1 = L, 0 = R)

data$Choice[data$Choice == "left"] <- 1
data$Choice[data$Choice == "right"] <- 0
data$Choice[data$Choice == "None"] <- NA
data$Choice <- as.integer(data$Choice)

# Drop trials with missing data. Record which trials (and how many) were dropped.

list_of_dropped_trials <- data[is.na(data$Choice),][,c('Trial')]
data = na.omit(data)

# Fixation Cross Location (left = 1, right = 0, center = 2)

data$FixCrossLoc[data$FixCrossLoc == "[0.5, 0]"] <- 0
data$FixCrossLoc[data$FixCrossLoc == "[-0.5, 0]"] <- 1
data$FixCrossLoc[data$FixCrossLoc == "[0, 0]"] <- 2
data$FixCrossLoc <- as.integer(data$FixCrossLoc)

# Expected values

data$Lev <- data$LProb * data$LAmt
data$Rev <- data$RProb * data$RAmt

# Difference in expected values (L-R)

data$LRdiff <- data$Lev - data$Rev

# What's the correct answer and was the choice correct?

data$CorrectAnswer <- as.integer(data$Lev >= data$Rev)
data$Correct <- as.integer(data$CorrectAnswer == data$Choice)


####################################################
## Transform ET data from list to long data. Clean it.
####################################################
## See methods section of Eum, Dolbier, Rangel (2023) for cleaning.
## If you see two separate fixations to the same ROI in a row, convert this to one fixation.

# Combine and sort the fixation data.

etdataraw <- data[,c("LLottery.timesOn", "LLottery.timesOff", "RLottery.timesOn", "RLottery.timesOff")]

CombineAndSortFixations <- function(LeftData, RightData) { # Feed in On times only or Off times only.
  Ldt <- data.table(time = LeftData)
  Ldt$loc <- 1
  Rdt <- data.table(time = RightData)
  Rdt$loc <- 0
  fixData <- rbind(Ldt, Rdt)
  return( fixData[order(fixData$time),] )
}

Lon <- strsplit(etdataraw$LLottery.timesOn, split = ",")
Loff <- strsplit(etdataraw$LLottery.timesOff, split = ",")
Ron <- strsplit(etdataraw$RLottery.timesOn, split = ",")
Roff <- strsplit(etdataraw$RLottery.timesOff, split = ",")

etdata <- data.table()

for (i in 1:nrow(etdataraw)) {

  Lon[[i]] <- gsub("[^0-9.<>]", "", Lon[[i]])
  Loff[[i]] <- gsub("[^0-9.<>]", "", Loff[[i]])
  Ron[[i]] <- gsub("[^0-9.<>]", "", Ron[[i]])
  Roff[[i]] <- gsub("[^0-9.<>]", "", Roff[[i]])

  temp.1 = CombineAndSortFixations(Lon[[i]], Ron[[i]])
  temp.2 = CombineAndSortFixations(Loff[[i]], Roff[[i]])
  temp.3 = data.table(
    Trial = i,
    FixStart = temp.1$time,
    FixEnd = temp.2$time,
    FixLoc = temp.1$loc
  )

  etdata <- rbind(etdata, temp.3)

}

# Get fixation number (keep in mind there are consecutive fixations to the same ROI, so you shouldn't count as two different fixations)

etdata <- etdata %>%
  group_by(Trial) %>%
  mutate(
    FixNum = with(rle(as.numeric(FixLoc)), rep(seq_along(lengths), lengths))
  )

# Combine those consecutive fixations into one fixation.

etdata <- etdata %>%
  group_by(Trial, FixNum) %>%
  summarize(
    FixStart = first(FixStart),
    FixEnd = last(FixEnd),
    FixLoc = last(FixLoc)
  )

# Convert to numeric data.

etdata$FixStart <- etdata$FixStart %>% as.numeric()
etdata$FixEnd <- etdata$FixEnd %>% as.numeric()


####################################################
## Combine choice and fixation data and save.
## Some final cleaning, which required data from the choices dataset.
####################################################

# Merge.

voi = c(
  "Participant",
  "Session",
  "Trial",
  "Condition",
  "Choice",
  "RT",
  "LRdiff",
  "Lev",
  "Rev",
  "LProb",
  "LAmt",
  "RProb",
  "RAmt",
  "Correct",
  "CorrectAnswer",
  "Sanity",
  "FixCrossLoc"
)
choicedata = data[, voi]

cfr = merge(choicedata, etdata, by = "Trial")

# It is possible for response time to be before ROI start or end times. Cut out observations where
# RT is before ROI fixation starts. After that, replace ROI end times with RT if RT < FixEnd.
# The reason why this is needed is because the ROI's in PsychoPy don't turn off until the start of the
# next screen. So technically the ROI is still being recorded after a choice has been made.

cfr$drop <- F
for (i in 1:nrow(cfr)) {
  if (cfr$RT[i] < cfr$FixStart[i]) {
    cfr$drop[i] = T
  }
}
cfr = cfr[!cfr$drop,]
for (i in 1:nrow(cfr)) {
  if (cfr$RT[i] < cfr$FixEnd[i]) {
    cfr$FixEnd[i] = cfr$RT[i]
  }
}

# Fixation duration.

cfr$FixDur <- cfr$FixEnd - cfr$FixStart

# First, middle, and last fixations.

cfr <- cfr %>%
  group_by(Trial) %>%
  mutate(FirstFix = (FixNum==min(FixNum)))
cfr <- cfr %>%
  group_by(Trial) %>%
  mutate(MiddleFix = ((FixNum!=min(FixNum)) & (FixNum !=max(FixNum))) )
cfr <- cfr %>%
  group_by(Trial) %>%
  mutate(LastFix = (FixNum==max(FixNum)))

summary(cfr$FixDur[cfr$FirstFix])
summary(cfr$FixDur[cfr$MiddleFix])
summary(cfr$FixDur[cfr$LastFix])

# Save.

cfr <- cfr[order(cfr$Trial, cfr$FixNum),]
filename = paste0("cfr_", subject_id, ".RData")
save(cfr, file=file.path(outdir, filename))
