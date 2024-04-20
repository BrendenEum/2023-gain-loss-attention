#File: cleanFix.R
#Programmer: Stephen A. Gonzalez
#Date Created: 01/3/2022
#Purpose: Clean up fixation data


# ------------------- Load packages and Work space Setup --------------------------------
rm(list = ls())
library(tidyverse)
start_time <- Sys.time()
#setwd('/Users/sgonzalez/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/code/data_processing_code/csvdata_output/')
setwd('/Users/sgonzalez/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data')

# subject list
SIDs = c(9390,9440)


#======================================================================================


# ------------------- Functions --------------------------------
extract_trial_fix <- function(data) {
  ## extracts and organizes fixations for a single trial
  ## INPUTS:
  ## data = tibble with raw fixation data for single trial
  ## OUTPUT:
  ## tibble with one fixation p/ row (ordered)
  
  # step 1: drop initial observations until first left/middle/right ROI recorded
  # (dropped observations associated with initial fixation cross and latency
  #  to first fixation)
  data <- data %>%
    mutate(
      itemFix = location %in% c(1,2),
      cummItemFix = cumsum(itemFix),
      idX = row_number()
    ) %>%
    filter(cummItemFix > 0) %>%
    select(-cummItemFix)
  
  # step 2: fix noise in fixation data, when applicable
  # ++ itemX none/FC ... none/FC itemX to itemX itemX .... itemX itemX
  prev_itemLoc <- function(idNum) {
    ## returns last item location previous to raw fix idNum
    temp <- filter(data, idX < idNum & location %in% c(1,2))$location
    if (length(temp) > 0) {
      return(last(temp))
    } else {
      return(-1)
    }
  }
  
  next_itemLoc <- function(idNum) {
    ## returns first item location after raw fix idNum
    temp <- filter(data, idX > idNum & location %in% c(1,2))$location
    if (length(temp) > 0) {
      return(temp[1])
    } else {
      return(-1)
    }
  }
  
  rows_toFix <- filter(data, location %in% c(0,3,4))$idX
  for (id in rows_toFix) {
    if (prev_itemLoc(id) != -1 & next_itemLoc(id) != -1 &
        prev_itemLoc(id) == next_itemLoc(id)) {
      data$location[data$idX == id] = prev_itemLoc(id)
    }
  }
  
  # step 3: drop none/fixCross observation in raw data set
  # (attibutable to saccades between items)
  data <- data %>%
    filter(location %in% c(1,2))
  
  # step 4: build fixation number counter
  if (nrow(data) == 0) {
    return(data)
  }
  
  data <- data %>%
    mutate(
      loc_change = location != lag(location, default = -1),
      fix_num = cumsum(loc_change)
    ) %>%
    group_by(fix_num) %>%
    summarize(
      subject_ID = unique(subject_ID),
      trial_number = unique(trial_number),
      location = unique(location),
      fix_start = min(timeStamp),
      fix_end   = max(timeStamp),
      fix_dur = max(timeStamp) - min(timeStamp)
    ) %>%
    mutate(
      fix_num_rev = max(fix_num) - fix_num
    ) %>%
    select(subject_ID, trial_number, location, fix_num, fix_num_rev, fix_start, fix_end, fix_dur)
  
  return(data)
}

#======================================================================================


# ------------------- Generate WIN dataset --------------------------------
for (s in 1:length(SIDs)) {
  # initialize the data frame as a tibble
  dataFix <- tibble(
    subject = integer(),
    trial = integer(),
    location = integer(),
    fix_num = integer(),
    fix_num_rev = integer(),
    fix_start = double(),
    fix_end = double(),
    fix_dur = double()
  )
  print(paste("processing subject Win: ", SIDs[s]))

  file_name <- paste(getwd(), '/', SIDs[s], '/raw_fixations_', SIDs[s], '_win_corr.csv', sep="" )

  data <- read_csv(file_name, col_types = cols())

  trials <- unique(data$trial_number)
  for (t in trials) {
    dataTrial <- extract_trial_fix(filter(data, trial_number == t))
    if (nrow(dataTrial) > 0) {
      dataFix <- rbind(dataFix, dataTrial)
    }
  }

  # save as .csv
  write_csv(dataFix, paste(getwd(), '/', SIDs[s], '/cleanFix_', SIDs[s],'_win_corr.csv',sep=""))
}


# ------------------- Generate Loss dataset --------------------------------
for (s in 1:length(SIDs)) {
  # initialize the data frame as a tibble
  dataFix <- tibble(
    subject = integer(),
    trial = integer(),
    location = integer(),
    fix_num = integer(),
    fix_num_rev = integer(),
    fix_start = double(),
    fix_end = double(),
    fix_dur = double()
  )
  print(paste("processing subject Loss: ", SIDs[s]))
  
  file_name <- paste(getwd(), '/', SIDs[s], '/raw_fixations_', SIDs[s], '_loss_corr.csv', sep="" )
  
  data <- read_csv(file_name, col_types = cols())
  
  trials <- unique(data$trial_number)
  for (t in trials) {
    dataTrial <- extract_trial_fix(filter(data, trial_number == t))
    if (nrow(dataTrial) > 0) {
      dataFix <- rbind(dataFix, dataTrial)
    }
  }
  
  # save as .csv
  write_csv(dataFix, paste(getwd(), '/', SIDs[s], '/cleanFix_', SIDs[s],'_loss_corr.csv',sep=""))
}
end_time <- Sys.time()
end_time - start_time
#======================================================================================