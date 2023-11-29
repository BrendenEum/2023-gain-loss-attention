# ##################################################################################################
# This script is responsible for cleaning and processing all the data from the
# dots task.
# Author: Brenden Eum (2023)
#
# Dependencies:
#
#
# Input:
# - *.csv files
#
# Output:
# - dropped_trials_[subject number].Rdata
# - cfr.Rdata (choices and fixations combined across subjects-trial)
#
# ##################################################################################################


# Preamble

library(tidyverse)
rawdatadir <- file.path("../../data/raw_data/good/dots")
edatadir <- file.path(rawdatadir, "../../../processed_data/dots/e")
cdatadir <- file.path(rawdatadir, "../../../processed_data/dots/c")
jdatadir <- file.path(rawdatadir, "../../../processed_data/dots/j")

# Get list of exploratory and confirmatory subjects

raw_subs <- list.files(path=rawdatadir)
exploratory_subs <- raw_subs[1:floor(length(raw_subs)/2)]
confirmatory_subs <- raw_subs[(floor(length(raw_subs)/2)+1):length(raw_subs)]
joint_subs <- raw_subs


#####################
# Functions
#####################

# Function to make raw choice and fixation datasets

read_choices_and_fixations_data <- function(data_directory, list_of_subjects) {
  
  choices_gain   <- data.frame()
  choices_loss   <- data.frame()
  fixations_gain <- data.frame()
  fixations_loss <- data.frame()
  
  for (raw_sub in raw_subs[1:length(list_of_subjects)]) {
    choices_gain = rbind(
      choices_gain, 
      read.csv(file.path(data_directory,raw_sub,paste0("choice_",raw_sub,"_win.csv")))
    )
    choices_loss = rbind(
      choices_loss, 
      read.csv(file.path(data_directory,raw_sub,paste0("choice_",raw_sub,"_loss.csv")))
    )
    fixations_gain = rbind(
      fixations_gain, 
      read.csv(file.path(data_directory,raw_sub,paste0("cleanFix_",raw_sub,"_win_corr.csv")))
    )
    fixations_loss = rbind(
      fixations_loss, 
      read.csv(file.path(data_directory,raw_sub,paste0("cleanFix_",raw_sub,"_loss_corr.csv")))
    )
  }
  fixations_gain$condition <- "win" #fixations are missing condition variable
  fixations_loss$condition <- "loss"
  
  choices   <- rbind(choices_gain, choices_loss)
  fixations <- rbind(fixations_gain, fixations_loss)
  
  return(list(choices=choices, fixations=fixations))
}

# Clean choices dataset

clean.choices <- function(choices) {
  choices <- choices %>%
    mutate(
      subject = subject_ID,
      trial = trial_number,
      condition = factor(
        ifelse(trial_type == "win", 1, 0),
        levels = c(0, 1),
        labels = c("Loss", "Gain")
      ),
      LProb = p_left/100,
      LAmt = ifelse(condition=="Gain", 10, -10),
      RProb = p_right/100,
      RAmt = ifelse(condition=="Gain", 10, -10),
      vL = LProb*LAmt,
      vR = RProb*RAmt,
      vDiff = round(vL-vR, 1),
      difficulty= abs(vDiff),
      choice = ifelse(choice == "left", 1, 0),
      correctAnswer = factor(
        ifelse(vDiff>=0, 1, 0), 
        levels=c(1,0), 
        labels=c("Left","Right")
      ),
      correct = ifelse(choice==correctAnswer, 1, 0),
      better_option = factor(
        ifelse(vDiff<0, 0, 1),
        levels=c(0,1),
        labels=c("Right","Left")
      ),
      rt = RT,
      sanity = 0, #to match numeric data
      fixCrossLoc = "Center"
    ) %>%
    group_by(subject, condition, vDiff) %>%
    mutate(
      choice.corr = choice - mean(choice)
    ) %>%
    subset(select = c(
      subject,
      trial,
      condition,
      vL,
      vR,
      LProb,
      LAmt,
      RProb,
      RAmt,
      vDiff,
      difficulty,
      choice,
      rt,
      choice.corr,
      correctAnswer,
      correct,
      sanity,
      fixCrossLoc
    ))
  return(choices)
}

# Clean fixations dataset

clean.fixations <- function(fixations) {
  fixations <- fixations %>%
    mutate(
      subject = subject_ID,
      trial = trial_number,
      condition = factor(
        ifelse(condition == "win", 1, 0),
        levels = c(0, 1),
        labels = c("Loss", "Gain")
      ),
      location = factor(
        location, 
        levels=c(1,2), 
        labels=c("Left","Right")
      ),
      fix_dur = fix_dur/1000,
      firstFix = ifelse(fix_num == 1, 1, 0),
    ) %>%
    group_by(subject, trial, condition) %>%
    mutate(
      middleFix = ifelse(fix_num > 1 & fix_num != max(fix_num), 1, 0),
      lastFix = ifelse(fix_num == max(fix_num) & fix_num > 1, 1, 0),
      net_fix = sum( fix_dur * ifelse(location=="Left",1,-1) )
    ) %>%
    ungroup() %>%
    mutate(
      fix_type = factor(
        1*firstFix + 2*middleFix + 3*lastFix,
        levels = c(1,2,3),
        labels = c("First","Middle","Last")
      )
    ) %>%
    subset(
      select = c(
        subject,
        trial,
        condition,
        location,
        net_fix,
        fix_num,
        fix_dur,
        fix_start,
        fix_end,
        fix_type
      )
    )
  return(fixations)
}

# Combine choices and fixations

make.cfr <- function(choices, fixations) {
  cfr <- merge(choices, fixations, by=c("subject","trial","condition"))
  cfr <- cfr[order(cfr$subject,cfr$trial,cfr$condition,cfr$fix_num),]
  cfr <- cfr %>%
    mutate(
      subject = as.integer(factor(subject)),
      dataset = "dots",
      trial = ifelse(condition=="Loss", trial+200, trial) # just doing this out of convenience
    ) %>%
    group_by(subject, condition, trial) %>%
    mutate(
      firstSeenChosen = first(location)==correctAnswer,
    ) %>%
    group_by(vDiff) %>%
    mutate(firstSeenChosen.corr = firstSeenChosen - mean(firstSeenChosen))
  
  
  
  return(cfr)
}


#####################
# Exploratory
#####################

choices_and_fixations = read_choices_and_fixations_data(rawdatadir, exploratory_subs)
choices = clean.choices(choices_and_fixations$choices)
fixations = clean.fixations(choices_and_fixations$fixations)
cfr_dots = make.cfr(choices, fixations)
cfr_even = cfr_dots[cfr_dots$trial%%2==0,]
cfr_odd = cfr_dots[cfr_dots$trial%%2!=0,]
save(cfr_dots, file = file.path(edatadir, "cfr_dots.RData"))
#save(cfr_even, file = file.path(edatadir, "cfr_even.RData"))
#save(cfr_odd, file = file.path(edatadir, "cfr_odd.RData"))


#####################
# Confirmatory
#####################

choices_and_fixations = read_choices_and_fixations_data(rawdatadir, confirmatory_subs)
choices = clean.choices(choices_and_fixations$choices)
fixations = clean.fixations(choices_and_fixations$fixations)
cfr_dots = make.cfr(choices, fixations)
cfr_even = cfr_dots[cfr_dots$trial%%2==0,]
cfr_odd = cfr_dots[cfr_dots$trial%%2!=0,]
save(cfr_dots, file = file.path(cdatadir, "cfr_dots.RData"))
#save(cfr_even, file = file.path(cdatadir, "cfr_even.RData"))
#save(cfr_odd, file = file.path(cdatadir, "cfr_odd.RData"))

#####################
# Joint
#####################

choices_and_fixations = read_choices_and_fixations_data(rawdatadir, joint_subs)
choices = clean.choices(choices_and_fixations$choices)
fixations = clean.fixations(choices_and_fixations$fixations)
cfr_dots = make.cfr(choices, fixations)
cfr_even = cfr_dots[cfr_dots$trial%%2==0,]
cfr_odd = cfr_dots[cfr_dots$trial%%2!=0,]
save(cfr_dots, file = file.path(jdatadir, "cfr_dots.RData"))
#save(cfr_even, file = file.path(jdatadir, "cfr_even.RData"))
#save(cfr_odd, file = file.path(jdatadir, "cfr_odd.RData"))
