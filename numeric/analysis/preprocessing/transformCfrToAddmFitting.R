# ##############################################################################
# This script will read in the processed data called "cfr.RData". 
# It will convert cfr into 3 datasets that can be used to estimate the aDDM:
# - expdata.csv, which contains [parcode, trial, rt, choice, item_left, item_right]
# - fixations.csv, which contains [parcode, trial, fix_item, fix_time]
# - trial_conditions.csv, [value_left, value_right]
# Details about each variable and dataset will be below.
# Author: Brenden Eum (2023)
#
# Dependencies:
#
#
# Input:
# - cfr.RData from processed_data folder
#
# Output:
# - expdata.csv
# - fixations.csv
# - trial_conditions.csv
#
# Notes:
# - "! ! !" indicates lines of code that you need to change
# ##############################################################################

# Preamble.

rm(list=ls())
library(plyr)
library(tidyverse)

# Note this will be run in docker container so make sure paths are mounted and defined in the env

datadir = "../../data/processed_data/e"

# Load data

load(file.path(datadir, "cfr.RData"))

# Odd trials only!!! We fit the aDDM using odd trials and use even trials for out-sample testing.

odd_trials <- cfr$trial %% 2 == 1
cfr <- cfr[odd_trials,]

# Split data into gain and loss datasets since we will estimate these separately.

cfrGain <- cfr[cfr$Condition=='Gain',]
cfrLoss <- cfr[cfr$Condition=='Loss',]

# ##############################################################################
# expdata.csv
# [parcode, trial, rt, choice, item_left, item_right]
# Each observation is a parcode-trial.
# 
# parcode: subject number
# trial: trial number
# rt: rt in ms (rounded to nearest ms)
# choice: -1 for left, 1 for right
# item_left: value of left item
# item_right: value of right item
# ##############################################################################

# Function to make the dataframe

make_expdata <- function(data) {
  expdata = data.frame(
    parcode = data$subject,
    trial = data$trial,
    rt = round(data$rt*1000,0),
    choice = ifelse(data$choice==1, -1, 1),
    item_left = data$vL,
    item_right = data$vR
  )
  expdata = expdata[!duplicated(expdata),]
  return(expdata)
}


# Save gain and loss
expdataGain <- make_expdata(cfrGain)
write.csv(expdataGain, file=file.path(datadir, "expdataGain.csv"), row.names=F, quote=F)

expdataLoss <- make_expdata(cfrLoss)
write.csv(expdataLoss, file=file.path(datadir, "expdataLoss.csv"), row.names=F, quote=F)


# ##############################################################################
# fixations.csv
# [parcode, trial, fix_item, fix_time]
# Each observation is a unique fixation during a parcode's trial.
# 
# parcode: subject number
# trial: trial number
# fix_item: item currently being fixated (0=blank, 1=left, 2=right)
# fix_time: how long was this fixation
# ##############################################################################

make_fixations <- function(data) {
  
  # cfr.RData does not include fixations to blank (latency to first fixation, saccades). Using fixation start and end times, make observations for fixations to blank.
  
  .data = data[,c("subject","trial","fix_start","fix_end","Location","fix_dur", "FirstFix", "MiddleFix","LastFix")]
  .data$fix_start = (.data$fix_start*1000) %>% round_any(1)
  .data$fix_end = (.data$fix_end*1000) %>% round_any(1)
  .data$fix_dur = (.data$fix_dur*1000) %>% round_any(1)
  .data$fix_start[.data$fix_start<3] = 0 # Psychopy is about 1 ms slow in recording initial fix.
  .data$Location = as.numeric(.data$Location) #1=L, 2=R
  
  .prefix = data.frame()
  for (i in 1:nrow(.data)) {
    
    # Latency to first fixation (if applicable) and first fixation.
    if (.data[i,"FirstFix"]==T){
      if (.data[i,"fix_start"]==0) {
        .prefix = rbind(.prefix, .data[i,])
      } else {
        .latency_start = 0
        .latency_end = max(as.numeric(.data[i,"fix_start"])-1,0)
        row = data.frame(subject=.data[i,"subject"], trial=.data[i,"trial"], 
                         fix_start=.latency_start, fix_end=.latency_end, 
                         Location=0, fix_dur=.latency_end, 
                         FirstFix=F, MiddleFix=F, LastFix=F)
        .prefix = rbind(.prefix, row)
        .prefix = rbind(.prefix, .data[i,])
      }
    }
    
  # Saccades, middle fixations, and last fixations. (Some trials only have one fixation. If so, then LastFix and FirstFix are true at the same time. Don't include a saccade for those, so treat them as FirstFix only.)
    if (.data[i, "MiddleFix"]==T | (.data[i, "LastFix"]==T & .data[i, "FirstFix"]==F)){
      .saccade_start = as.numeric(.data[i-1, "fix_end"]) + 1
      .saccade_end = as.numeric(.data[i, "fix_start"]) - 1
      .saccade_duration = .saccade_end - .saccade_start %>% round_any(1)
      # if saccade is less than a ms, don't include it and raise a warning...     ! ! !
      if (.saccade_start>=.saccade_end) { 
        print("=================================")
        print("Error: saccade duration is <= 0.")
        print(.data[i,c('subject','trial')])
        print(.saccade_start)
        print(.saccade_end)
      } else { # otherwise, put the saccade in
        row = data.frame(subject=.data[i,"subject"], trial=.data[i,"trial"], 
                         fix_start=.saccade_start, fix_end=.saccade_end, 
                         Location=0, fix_dur=.saccade_duration, 
                         FirstFix=F, MiddleFix=F, LastFix=F)
        .prefix = rbind(.prefix, row)
      }
      .prefix = rbind(.prefix, .data[i,]) # put the fixation in
    }
  }
  
  # Make the dataframe
  
  fixations = data.frame(
    parcode = .prefix$subject,
    trial = .prefix$trial,
    fix_item = .prefix$Location,
    fix_time = .prefix$fix_dur
  )

  return(fixations)
}

# Save gains and losses
fixationsGain <- make_fixations(cfrGain)
write.csv(fixationsGain, file=file.path(datadir, "fixationsGain.csv"), row.names=F, quote=F)

fixationsLoss <- make_fixations(cfrLoss)
write.csv(fixationsLoss, file=file.path(datadir, "fixationsLoss.csv"), row.names=F, quote=F)


# ##############################################################################
# trial_conditions.csv
# [value_left, value_right]
# Each observation is a unique trial condition to be used for simualtions.
# 
# value_left: value of the left item
# value_right: value of the right item
# ##############################################################################

# Make the dataframe

.vals = c(cfr$vL, cfr$vR) %>% round_any(1) %>% unique() %>% sort()
.combination = expand.grid(.vals, .vals)
trial_conditions = data.frame(
  value_left = .combination$Var1,
  value_right = .combination$Var1
)

# Save it

save(trial_conditions, file=file.path(datadir, "trial_conditions.RData"))
write.csv(trial_conditions, file=file.path(datadir, "trial_conditions.csv"), row.names=F, quote=F)