#File: correctFeedbackScreen.R
#Programmer: Stephen A. Gonzalez
#Date Created: 5/28/2022
#Purpose: Correct for 1 Second of Feedback screen

# ------------------- Load packages and Work space Setup --------------------------------
rm(list = ls())
library(tidyverse)
start_time <- Sys.time()
#setwd('/Users/sgonzalez/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/code/data_processing_code/csvdata_output/')
setwd('/Users/sgonzalez/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data')

# subject list
#Enter Subject ID that you would like to process
SIDs = c(9390,9440)


#Process all subjects
# setwd("~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data")
# SIDs <- list.files()
# SIDs[-(which(SIDs == "bad"))] #Remove 'Bad' File Folder
# SIDs <- as.numeric(SIDs) #Change to Numeric
# SIDs <- na.omit(SIDs) #Remove NA's
# SIDs <- as.data.frame(SIDs) #Convert to Dataframe
# SIDs <- SIDs[order(SIDs),] #Order Data
#======================================================================================



# ------------------- Correct WIN  data --------------------------------
# Correct Win Data
for(s in 1:length(SIDs)){
  print(paste("processing subject Win: ", SIDs[s]))

  data.choice_win <- read_csv(paste(SIDs[s], "/choice_", SIDs[s], "_win.csv", sep = ""), col_types = cols())
  data.raw_fix_win <- read_csv(paste(SIDs[s], '/raw_fixations_', SIDs[s], '_win.csv', sep=""), col_types = cols())

  trial <- unique(data.raw_fix_win$trial_number)
  #trial_length <- data.frame()
  #for(t in trial){ #Extract trial length
  #  trial_subset <- filter(data.raw_fix_win, trial_number == t)
  #  trial_length[t,1] <- trial_subset$timeStamp[length(trial_subset$timeStamp)]
  #}

  #time_diff <- ceiling(trial_length - (data.choice_win$RT * 1000)) #calculate the time difference of the feedback screen rounding up

  corrected_data <- data.frame()
  for(t in trial){
    trial_subset <- filter(data.raw_fix_win, trial_number == t)
    trial_subset_corr <- filter(trial_subset, timeStamp <= (data.choice_win$RT[t] * 1000))

    corrected_data <- rbind(corrected_data,trial_subset_corr)
  }

  #Save data as .csv
  write_csv(corrected_data,paste(SIDs[s], '/raw_fixations_', SIDs[s], '_win_corr.csv', sep=""))
}

#======================================================================================


# ------------------- Correct LOSS data --------------------------------
# Correct Win Data
for(s in 1:length(SIDs)){
  print(paste("processing subject Loss: ", SIDs[s]))
  
  data.choice_loss <- read_csv(paste(SIDs[s], "/choice_", SIDs[s], "_loss.csv", sep = ""), col_types = cols())
  data.raw_fix_loss <- read_csv(paste(SIDs[s], '/raw_fixations_', SIDs[s], '_loss.csv', sep=""), col_types = cols())
  
  trial <- unique(data.raw_fix_loss$trial_number)
  #trial_length <- data.frame()
  #$for(t in trial){ #Extract trial length
  #  trial_subset <- filter(data.raw_fix_loss, trial_number == t)
  #  trial_length[t,1] <- trial_subset$timeStamp[length(trial_subset$timeStamp)] 
  #}
  
  #time_diff <- ceiling(trial_length - (data.choice_loss$RT * 1000)) #calculate the time difference of the feedback screen rounding up
  
  corrected_data <- data.frame()
  for(t in trial){
    trial_subset <- filter(data.raw_fix_loss, trial_number == t)
    trial_subset_corr <- filter(trial_subset, timeStamp <= (data.choice_loss$RT[t] * 1000))
    
    corrected_data <- rbind(corrected_data,trial_subset_corr)
  }
  
  #Save data as .csv
  write_csv(corrected_data,paste(SIDs[s], '/raw_fixations_', SIDs[s], '_loss_corr.csv', sep=""))
}
end_time <- Sys.time()
end_time - start_time
#======================================================================================