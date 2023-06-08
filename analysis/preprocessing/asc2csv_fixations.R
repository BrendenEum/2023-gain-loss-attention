# ##################################################################################################
# This script will convert .asc files for Eyelink eye-tracker data into .csv
# files with fixation data ready for analysis.
# Author: Brenden Eum (2023)
#
# Dependencies:
# - processFixationData.R (should be located in the same folder as this script)
#
# Input:
# - *.asc file (converted from EDF file using EDF2ASC by Eyelink)
#
# Output:
# - *.csv file
#
# subject_id    =   Isn't it obvious?
# trial_number  =   See description above.
# fix_loc       =   Location of fixation (1=L, 2=R, 4=Neither L or R)
# fix_num       =   Which fixation in the trial (first, second, third, ...)?
# fix_start     =   The start time (ms) of this fixation, with respect to stimulus onset.
# fix_end       =   The end time (ms) of this fixation, with respect to stimulus onset.
# fix_dur       =   The duration of the fixation (ms).
#
# Notes:
# - "! ! !" indicates lines of code that you need to change
# ##################################################################################################

# Preamble.

rm(list=ls())
library(dplyr)
library(data.table)
library(eyelinker)
datadir <- "D:/OneDrive - California Institute of Technology/PhD/Rangel Lab/2023-gain-loss-attention/experiment/code/data" # ! ! !
outdir <- datadir

# Input data.
# Each line in the datatable is one row in the .asc file, as a single string.

fixfilename <- "123456_GainLossTask_2023-06-07_14h08.33.756"                                        # ! ! !
fixfilename <- paste0(fixfilename, ".asc")
subject_id <- as.integer(substr(fixfilename,1,6))
rawdata <- readLines(file.path(datadir, fixfilename)) %>% data.table()

# Get a datatable with only fixation and saccade data for each trial.

cond1 <- rawdata$. %like% "FIX"
cond2 <- rawdata$. %like% "SACC"
cond3 <- rawdata$. %like% "TRIAL"
data <- rawdata[cond1 | cond2 | cond3, ]

# Drop everything before the first trial (trial numbers with neg or 0 are practice).

trial_start_index <- which(data$. %like% "TRIALSTART 1")
data <- data[trial_start_index[1]:length(data$.),]

# Split the strings into multiple columns.

fixList <- data$. %>% strsplit(split="\\s+|\t")

data$trial <- NA # Trial number
data$event <- "" # Eyetracker event (e.g. message, SFIX [start fix], EFIX [end fix], ...)
data$timestart <- NA # Timestamp for the eyetracker event start time
data$timeend <- NA # Timestamp for the eyetracker event end time, only for E events (end)
data$duration <- NA # Duration of event, only for E events (end)
data$xPos <- NA # X coordinate of fixation event
data$yPos <- NA # Y coordinate of fixation event
data$pupil <- NA # Pupil area or diameter (check experiment, I don't remember rn)

for (obs in 1:length(data$.)) {

  data$event[obs] <- fixList[[obs]][1]

  if (fixList[[obs]][3] == "TRIALSTART") {
    trial_number <- as.integer(fixList[[obs]][4])
  } else if (fixList[[obs-1]][3] == "TRIALEND") {
    trial_number <- NA
  }
  data$trial[obs] <- trial_number

  if (fixList[[obs]][2] == "L") {
    data$timestart[obs] <- as.integer(fixList[[obs]][3])
  } else {
    data$timestart[obs] <- as.integer(fixList[[obs]][2])
  }

  if (data$event[obs] %like% "E") {
    data$timeend[obs] <- as.integer(fixList[[obs]][4])
    data$duration[obs] <- as.integer(fixList[[obs]][5]) # For some reason, this is 4ms longer than timeend-timestart.
    data$xPos[obs] <- as.numeric(fixList[[obs]][6])
    data$yPos[obs] <- as.numeric(fixList[[obs]][7])
    data$pupil[obs] <- as.integer(fixList[[obs]][8])
  }

}

# Get rid of all observations that arent within a trial.
# Hint: I defined data$trial to only have a numeric value when within TRIALSTART to TRIALEND.

data <- data[!is.na(data$trial),]

# Process this fixation data into the output file described above, one trial at a time.
# Uses processFixationData.R.

source("processFixationData.R")
output <- data.table()

for (t in unique(data$trial)) {

  tdata <- data[data$trial == t, ]

}