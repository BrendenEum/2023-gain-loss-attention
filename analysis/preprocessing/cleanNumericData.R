# ##################################################################################################
# This script will read the data exported from PsychoPy and clean it into a dataset ready for
# analysis. This Psychopy data already includes ROI ET data, so there is no need to process the EDF
# or ASC files. This script also combines every subject's cleaned data into one merged dataset,
# ready for analysis.
# Author: Brenden Eum (2023)
#
# Dependencies:
#
#
# Input:
# - *.csv file from PsychoPy
#
# Output:
# - dropped_trials_[subject number].Rdata
# - cfr.Rdata
#
# One observation in cfr dataset is a subject-trial-fixation.
#
# Variables:
#   trial: trial Number
#   Participant: Participant Number
#   Condition: Gain or Loss
#   choice: 1 is left, 0 is right
#   rt: Response time in seconds
#   vDiff: Left expected value minus right expected value
#   vL: Left expected value
#   vR: Right expected value
#   LProb: Left probability of win
#   LAmt: Left amount if win
#   RProb: Right probability of win
#   RAmt: Right amount if win
#   Correct: 1 if choice equals CorrectAnswer, 0 otherwise
#   CorrectAnswer: The side with the higher expected value (1 left, 0 right)
#   Sanity: Was this a sanity check trial? (Sanity checks are very easy trials meant to check attentiveness.)
#   FixCrossLoc: What part of the screen was the fixation cross on? (1 left, 0 right, 2 center)
#   fix_num: Which fixation was this in the trial? (first, second, third, etc...)
#   fix_start: When did the fixation start with respect to the lotteries being presented? In seconds.
#   fix_end: When did the fixatoin end wrt the lotteries being presented? In seconds.
#   Location: Where was the fixation? (1 left, 0 right, 3 neither).
#   fix_dur: How long did the fixation go? In seconds.
#
# Notes:
# - "! ! !" indicates lines of code that you need to change
# ##################################################################################################

# Preamble.
library(tidyverse)
rawdatadir <- file.path("../../data/raw_data/good/numeric")
edatadir <- file.path(rawdatadir, "../../../processed_data/numeric/e")
cdatadir <- file.path(rawdatadir, "../../../processed_data/numeric/c")
jdatadir <- file.path(rawdatadir, "../../../processed_data/numeric/j")
experimentdir = file.path("../../experiment/numeric/recruitment")

# Get each subject that passed quality control.

raw_subs <- list.dirs(path = rawdatadir, full.names = F, recursive = F)
exploratory_subs <- raw_subs[1:25]#raw_subs[1:floor(length(raw_subs)/2)]
confirmatory_subs <- raw_subs[26:50]
joint_subs <- raw_subs

# Get the order of blocks
blockOrder <- read.csv(file.path(experimentdir, "numeric_subject_blockOrder.csv"))

# Helpful functions before running loop.

CombineAndSortFixations <- function(LeftData, RightData) { # Feed in On times only or Off times only.
  Ldt <- data.frame(time = LeftData)
  try(Ldt$loc <- 1) # need this in case subject only looked at one roi. dropped trial if subject didnt look at either roi.
  Rdt <- data.frame(time = RightData)
  try(Rdt$loc <- 0)
  fixData <- rbind(Ldt, Rdt)
  return( fixData[order(fixData$time),] )
}

# Placeholders

cfr_list <- list()
list_counter <- 1


make_cfr = function(data_directory, list_of_subjects) {

  # Loop through each directory (subject) in that folder.
  
  for (subject_id in list_of_subjects) {
    
    print(subject_id)
    
    subject_id <- as.integer(subject_id)
    fixfilename <- paste0(toString(subject_id), "/", toString(subject_id), "_GainLossTask_")
    fixfilename1 <- paste0(fixfilename, "gain1.csv")
    fixfilename2 <- paste0(fixfilename, "gain2.csv")
    fixfilename3 <- paste0(fixfilename, "loss1.csv")
    fixfilename4 <- paste0(fixfilename, "loss2.csv")
    gain1 <- read.csv(file.path(data_directory, fixfilename1), fileEncoding="UTF-8-BOM")
    gain2 <- read.csv(file.path(data_directory, fixfilename2), fileEncoding="UTF-8-BOM")
    loss1 <- read.csv(file.path(data_directory, fixfilename3), fileEncoding="UTF-8-BOM")
    loss2 <- read.csv(file.path(data_directory, fixfilename4), fileEncoding="UTF-8-BOM")
    
    # Trim the dataset down to the variables and observations that you want. Merge gains and losses.
    
    voi <- c(
      "participant",
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
    gain1 <- gain1[,voi]
    gain2 <- gain2[,voi]
    loss1 <- loss1[,voi]
    loss2 <- loss2[,voi]
    rawdata <- do.call("rbind", list(gain1, gain2, loss1, loss2))
    data <- rawdata[rawdata$TrialType == "Trial", voi]
    data <- data %>% rename(
      "subject" = "participant",
      "choice" = "Response.keys",
      "rt" = "Response.rt",
      "condition" = "Condition",
      "fixCrossLoc" = "FixCrossLoc",
      "sanity" = "Sanity"
    )
    
    # Drop sanity check trials.
    
    data = data[data$sanity==0,]
    
    
    ####################################################
    ## Make New Variables or Transform Old Ones
    ####################################################
    
    # Add trial number
    
    data <- data %>% mutate(trial = row_number())
    
    # choice (1 = L, 0 = R)
    
    data$choice[data$choice == "left"] <- 1
    data$choice[data$choice == "right"] <- 0
    data$choice[data$choice == "None"] <- NA
    data$choice <- as.integer(data$choice)
    
    # Drop trials with missing data. Record which trials (and how many) were dropped.
    
    #list_of_dropped_trials_choice_missing <- data[is.na(data$choice),][,c('trial')]
    #data = na.omit(data)
    #filename = paste0("dropped_trials_choice_missing_", subject_id, ".RData")
    #save(list_of_dropped_trials_choice_missing, file=file.path(outdir, filename))
    
    # Turn Condition into a factor
    
    data$condition <- data$condition %>%
      factor(
        levels = c("gain","loss"),
        labels = c("Gain","Loss")
      )
    
    # Fixation Cross Location (left = 1, right = 0, center = 2)
    
    data$fixCrossLoc <- data$fixCrossLoc %>%
      factor(
        levels = c("[-0.5, 0]","[0, 0]","[0.5, 0]"),
        labels = c("Left","Center","Right")
      )
    
    # Expected values
    
    data$vL <- data$LProb * data$LAmt
    data$vR <- data$RProb * data$RAmt
    
    # Difference in expected values (L-R)
    
    data$vDiff <- round(data$vL - data$vR,3)
    breaks <- seq(-10.5,10.5,1)
    tags   <- seq(-10,10,1)
    data$nvDiff <- as.numeric(as.character(cut(data$vDiff, breaks, labels=tags)))/4
    
    # Difficulty
    
    data$difficulty <- abs(data$vDiff)
    data$ndifficulty = abs(data$nvDiff)
    
    # Corrected choice
    
    data <- data %>%
      group_by(subject, condition, vDiff) %>%
      mutate(
        choice.corr = choice - mean(choice)
      ) %>%
      ungroup() %>%
      group_by(subject, condition, nvDiff) %>%
      mutate(
        nchoice.corr = choice - mean(choice)
      )
    
    # What's the correct answer and was the choice correct?
    
    data$correctAnswer <- as.integer(data$vL >= data$vR) %>%
      factor( 
        levels=c(1,0), 
        labels=c("Left","Right")
      )
    data$correct <- as.integer(data$correctAnswer == data$choice)
    
    # Block order
    #data = merge(data, blockOrder, by="subject")
    #data$blockOrder = factor(data$blockOrder, levels=c("gl","lg"), labels=c("Gain-Loss", "Loss-Gain"))
    
    
    ####################################################
    ## Transform ET data from list to long data. Clean it.
    ####################################################
    ## See methods section of Eum, Dolbier, Rangel (2023) for cleaning.
    ## If you see two separate fixations to the same ROI in a row, convert this to one fixation.
    
    # Combine and sort the fixation data.
    
    etdataraw <- data[,c("LROI.timesOn", "LROI.timesOff", "RROI.timesOn", "RROI.timesOff")]
    
    Lon <- strsplit(etdataraw$LROI.timesOn, split = ",")
    Loff <- strsplit(etdataraw$LROI.timesOff, split = ",")
    Ron <- strsplit(etdataraw$RROI.timesOn, split = ",")
    Roff <- strsplit(etdataraw$RROI.timesOff, split = ",")
    
    etdata <- data.frame()
    list_of_dropped_trials_et_missing <- list()
    
    for (i in 1:nrow(etdataraw)) {
      
      Lon[[i]] <- gsub("[^0-9.<>]", "", Lon[[i]])
      Loff[[i]] <- gsub("[^0-9.<>]", "", Loff[[i]])
      Ron[[i]] <- gsub("[^0-9.<>]", "", Ron[[i]])
      Roff[[i]] <- gsub("[^0-9.<>]", "", Roff[[i]])
      
      if (length(Lon[[i]])==0 & length(Ron[[i]])==0) {
        list_of_dropped_trials_et_missing <- append(list_of_dropped_trials_et_missing, i)
      } else {
        temp.1 = CombineAndSortFixations(Lon[[i]], Ron[[i]])
        temp.2 = CombineAndSortFixations(Loff[[i]], Roff[[i]])
        temp.3 = data.frame(
          trial = i,
          fix_start = temp.1$time,
          fix_end = temp.2$time,
          location = temp.1$loc
        )
        etdata <- rbind(etdata, temp.3)
      }
    }
    
    # Save list of trials that were skipped cuz Eye tracking data missing
    
    #filename = paste0("dropped_trials_et_missing_", subject_id, ".RData")
    #save(list_of_dropped_trials_et_missing, file=file.path(outdir, filename))
    
    # Turn location into a factor variable
    
    etdata$location <- factor(
      etdata$location,
      levels = c(1,0),
      labels = c("Left","Right")
    )
    
    # Get fixation number (keep in mind there are consecutive fixations to the same ROI, so you shouldn't count as two different fixations)
    
    etdata <- etdata %>%
      group_by(trial) %>%
      mutate(
        fix_num = with(rle(as.numeric(location)), rep(seq_along(lengths), lengths))
      )
    
    # Combine those consecutive fixations into one fixation.
    
    etdata <- etdata %>%
      group_by(trial, fix_num) %>%
      summarize(
        fix_start = first(fix_start),
        fix_end = last(fix_end),
        location = last(location)
      )
    
    # Convert to numeric data.
    
    etdata$fix_start <- etdata$fix_start %>% as.numeric()
    etdata$fix_end <- etdata$fix_end %>% as.numeric()
    
    
    ####################################################
    ## Combine choice and fixation data and save.
    ## Some final cleaning, which required data from the choices dataset.
    ####################################################
    
    # Merge.
    
    voi = c(
      "subject",
      "trial",
      "condition",
      "choice",
      "choice.corr",
      "nchoice.corr",
      "rt",
      "vDiff",
      "nvDiff",
      "difficulty",
      "ndifficulty",
      "vL",
      "vR",
      "LProb",
      "LAmt",
      "RProb",
      "RAmt",
      "correct",
      "correctAnswer",
      "sanity",
      "fixCrossLoc"
      #"blockOrder"
    )
    choicedata = data[, voi]
    
    subject_cfr = merge(choicedata, etdata, by = "trial")
    
    # It is possible for response time to be before ROI start or end times. Cut out observations where
    # rt is before ROI fixation starts. After that, replace ROI end times with rt if rt < fix_end.
    # The reason why this is needed is because the ROI's in PsychoPy don't turn off until the start of the
    # next screen. So technically the ROI is still being recorded after a choice has been made.
    
    subject_cfr$drop <- F
    for (i in 1:nrow(subject_cfr)) {
      if (!is.na(subject_cfr$rt[i])) { # drop trials w missing RT since it means participant failed to respond in time
        if (subject_cfr$rt[i] < subject_cfr$fix_start[i]) {
          subject_cfr$drop[i] = T
        }
      } else {
        subject_cfr$drop[i] = T
      }
    }
    subject_cfr = subject_cfr[!subject_cfr$drop,]
    for (i in 1:nrow(subject_cfr)) {
      if (subject_cfr$rt[i] < subject_cfr$fix_end[i]) {
        subject_cfr$fix_end[i] = subject_cfr$rt[i]
      }
    }
    
    # IF YOU'RE WORRIED ABOUT DROPPING TRIALS, LOOK AT THIS. WE'RE ONLY DROPPING AT MOST 5 TRIALS, FOR ONE SUBJECT.
    #worry = cfr %>% group_by(subject, trial ) %>% summarize(trial=first(trial))
    #worrycount = cfr %>% group_by(subject) %>% summarize(N = n())
    #hist(worrycount$N)
    
    # Fixation duration.
    
    subject_cfr$fix_dur <- subject_cfr$fix_end - subject_cfr$fix_start
    
    # First, middle, and last fixations.
    
    subject_cfr <- subject_cfr %>%
      group_by(trial) %>%
      mutate(firstFix = (fix_num==min(fix_num)))
    subject_cfr <- subject_cfr %>%
      group_by(trial) %>%
      mutate(middleFix = ((fix_num!=min(fix_num)) & (fix_num !=max(fix_num))) )
    subject_cfr <- subject_cfr %>%
      group_by(trial) %>%
      mutate(lastFix = (fix_num==max(fix_num)))
    
    # Net fixation (L-R).
    
    numericLocation = -as.numeric(subject_cfr$location) + 2
    subject_cfr$temp_fix_dur <- subject_cfr$fix_dur * (numericLocation*2-1) # Makes L positive and R negative
    subject_cfr <- subject_cfr %>%
      group_by(condition, trial) %>%
      mutate(net_fix = sum(temp_fix_dur)) %>%
      ungroup()
    
    # First seen chosen.
    
    subject_cfr <- subject_cfr %>%
      group_by(trial) %>%
      mutate(firstSeenChosen = ((as.numeric(first(location))-1)==first(choice))) %>%
      ungroup()
    subject_cfr <- subject_cfr %>%
      group_by(vDiff) %>%
      mutate(firstSeenChosen.corr = firstSeenChosen - mean(firstSeenChosen)) %>%
      ungroup()
    
    # Last other value difference
    
    firstLastOtherCfr <- subject_cfr %>%
      group_by(condition, trial) %>%
      mutate(
        lastFixLoc = last(location),
        vLast = ifelse(lastFixLoc=="Left", vL, vR),
        vLastOther = ifelse(lastFixLoc=="Left", vR, vL),
        lastOtherVDiff = round(vLast - vLastOther, 3),
        firstFixLoc = first(location),
        vFirst = ifelse(firstFixLoc=="Left", vL, vR),
        vFirstOther = ifelse(firstFixLoc=="Left", vR, vL),
        firstOtherVDiff = round(vFirst - vFirstOther, 3)
      )
    subject_cfr$lastOtherVDiff <- firstLastOtherCfr$lastOtherVDiff 
    subject_cfr$firstOtherVDiff <- firstLastOtherCfr$firstOtherVDiff 
    breaks <- seq(-10.5,10.5,1)
    tags   <- seq(-10,10,1)
    subject_cfr$nlastOtherVDiff <- as.numeric(as.character(cut(subject_cfr$lastOtherVDiff, breaks, labels=tags)))/4
    subject_cfr$nfirstOtherVDiff <- as.numeric(as.character(cut(subject_cfr$firstOtherVDiff, breaks, labels=tags)))/4
    
    # Latency to first fix
    subject_cfr$latency = NA
    subject_cfr$latency[subject_cfr$firstFix==T] = subject_cfr$fix_start[subject_cfr$firstFix==T]
    
    # Transition durations
    subject_cfr$transition = NA
    for (obs in c(1:nrow(subject_cfr))){
      if (subject_cfr$firstFix[obs]==F) {
        subject_cfr$transition[obs] = subject_cfr$fix_start[obs]-subject_cfr$fix_end[obs-1]
      }
    }
    
    # Drop some columns
    
    subject_cfr <- subject_cfr[, !(colnames(subject_cfr) %in% c("drop", "temp_fix_dur"))]
    
    # Save.
    
    subject_cfr <- subject_cfr[order(subject_cfr$trial, subject_cfr$fix_num),]
    cfr_list[[list_counter]] <- subject_cfr
    list_counter <- list_counter + 1
    
  }
  
  # Save one cfr file with everyone's data
  
  cfr <- do.call("rbind", cfr_list)
  cfr$study <- "numeric"
  cfr$studyN = "2"
  
  return(cfr)
}

#####################
# Exploratory
#####################

cfr_numeric = make_cfr(rawdatadir, exploratory_subs)
save(cfr_numeric, file=file.path(edatadir, "cfr_numeric.Rdata"))

#####################
# Confirmatory
#####################

cfr_numeric = make_cfr(rawdatadir, confirmatory_subs)
save(cfr_numeric, file=file.path(cdatadir, "cfr_numeric.Rdata"))

#####################
# Joint
#####################

cfr_numeric = make_cfr(rawdatadir, joint_subs)
save(cfr_numeric, file=file.path(jdatadir, "cfr_numeric.Rdata"))