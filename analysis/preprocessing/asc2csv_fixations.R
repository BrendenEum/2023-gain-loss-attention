# ##################################################################################################
# This script will convert .asc files for Eyelink eye-tracker data into .csv
# files with fixation data ready for analysis.
# Author: Brenden Eum (2023)
#
# Dependencies:
# - GetItem.R (should be located in the same folder as this script)
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
datadir <- "D:/OneDrive - California Institute of Technology/PhD/Rangel Lab/2023-gain-loss-attention/task/data" # ! ! !
outdir <- datadir

# Input data.
# Each line in the datatable is one row in the .asc file, as a single string.

filename <- "123456_GainLossTask_2023-06-07_14h08.33.756"                                               # ! ! !
filename <- paste0(filename, ".asc")
subject_id <- as.integer(substr(filename,1,6))
rawdata <- readLines(file.path(datadir, filename)) %>% data.table()

# Get a datatable with only fixation and saccade data for each trial.

cond1 <- rawdata$. %like% "FIX"
cond2 <- rawdata$. %like% "SACC"
cond3 <- rawdata$. %like% "TRIAL"
data <- rawdata[cond1 | cond2 | cond3, ]

# Drop everything before the first trial (trial numbers with neg or 0 are practice).

trial_start_index <- which(data$. %like% "TRIALSTART 1")
data <- data[trial_start_index:length(data$.),]
