## This script generates the datasets for fitting the aDDM.
## expdata, fixations

rm(list=ls())
set.seed(4)
library(tidyverse)
datadir = file.path("../../../data/processed_data")
dots_datadir = file.path(datadir, "dots")
numeric_datadir = file.path(datadir, "numeric")
food_datadir = file.path(datadir, "food")


##########################################################################################
# FUNCTION: expdata [parcode, trial, rt, choice, item_left, item_right, minValue, maxValue]
# item_left/right: value of left or right item.
# min/maxValue: the min/max value seen in this condition so far.
##########################################################################################

make_expdata = function(data, studydir="error", dataset="error") {
  data = data[data$trial%%2==1,]                 # ODD TRIALS ONLY!!!
  data = data[data$firstFix==T,]         # ONLY NEED ONE OBS PER TRIAL.
  data.gain = data[data$condition=="Gain",]
  data.loss = data[data$condition=="Loss",]
  if (data.gain$trial[1]!=1) {data.gain$trial=data.gain$trial-min(data.gain$trial)+1} 
  if (data.loss$trial[1]!=1) {data.loss$trial=data.loss$trial-min(data.loss$trial)+1} 
  expdataGain = data.frame(
    parcode = data.gain$subject,
    trial = data.gain$trial,
    rt = floor(data.gain$rt*1000),
    choice = (data.gain$choice*2-1)*-1, #L:-1, R:1... Tavares toolbox.
    item_left = data.gain$vL,
    item_right = data.gain$vR,
    minValue = data.gain$minValue,
    maxValue = data.gain$maxValue)
  expdataLoss = data.frame(
    parcode = data.loss$subject,
    trial = data.loss$trial,
    rt = floor(data.loss$rt*1000),
    choice = (data.loss$choice*2-1)*-1,
    item_left = data.loss$vL,
    item_right = data.loss$vR,
    minValue = data.loss$minValue,
    maxValue = data.loss$maxValue)
  write.csv(
    expdataGain,
    file=file.path(studydir, paste0(dataset, "/expdataGain.csv")), 
    row.names=F)
  write.csv(
    expdataLoss,
    file=file.path(studydir, paste0(dataset, "/expdataLoss.csv")), 
    row.names=F)}


##########################################################################################
# FUNCTION: fixations [parcode, trial, fix_item, fix_time]
##########################################################################################

make_fixations = function(data, studydir="error", dataset="error") {
  
  #cleaning
  data = data[data$trial%%2==1,]                 # ODD TRIALS ONLY!!!
  data$rt = data$rt*1000
  data$fix_start = floor(data$fix_start*1000)
  data$fix_start[data$fix_start==1] = 0 # ET takes a ms to start rec, looks like 1 ms latency.
  data$fix_end = floor(data$fix_end*1000)
  data$location = data$location %>% as.numeric() # changes Left to 1 and Right to 2
  data.gain = data[data$condition=="Gain",]
  data.loss = data[data$condition=="Loss",]
  if (data.gain$trial[1]!=1) {data.gain$trial=data.gain$trial-min(data.gain$trial)+1} 
  if (data.loss$trial[1]!=1) {data.loss$trial=data.loss$trial-min(data.loss$trial)+1} 
  
  #FUNCTION: transform cfr into a dataset where each obs is a ms. keeps track of where subject is looking every    ms of every trial. this allows us to easily capture saccades and latency to first fixation too. mark each new    fixation with a new fix_num.
  expand_then_collapse_fixations = function(data) {
    data.fixation.ms = data.frame()
    for (j in sort(unique(data$subject))) {
      if (j%%5==0) {print(paste(j, "of", max(data$subject)))}
      .subdata = data[data$subject==j,]
      for (i in sort(unique(.subdata$trial))){
        .subtrialdata = .subdata[.subdata$trial==i,]
        .rt = floor(first(.subtrialdata$rt))
        .t = seq(0, .rt, 1)
        .location = rep(0, length(.t))
        for (k in c(1:nrow(.subtrialdata))) {
          .ind = (.subtrialdata$fix_start[k] <= .t & .t < .subtrialdata$fix_end[k])
          .location[.ind] = .subtrialdata$location[k]}
        .fix_num = rep(0, length(.t))
        .fix_num[1] = 1
        for (m in c(2:length(.location))) {
          if (.location[m] == .location[m-1]) {.fix_num[m] = .fix_num[m-1]}
          else {.fix_num[m] = .fix_num[m-1]+1}}
        
        .add.data.fixation.ms = data.frame(
          parcode = j, 
          trial = i, 
          fix_num = .fix_num, 
          t = .t, 
          fix_item = .location)
        data.fixation.ms = rbind(data.fixation.ms, .add.data.fixation.ms)}}
    
    # collapse that transformed data into one obs per subject-trial-fixation. might seem super roundabout, but       now we have a dataset like cfr... but now latency to first fixation and saccades are included!
    data.fixation = data.fixation.ms %>%
      group_by(parcode, trial, fix_num) %>%
      summarize(
        fix_item = first(fix_item),
        fix_time = n())
    
    # again, due to slow interactions between psychopy and eyelink, sometimes the final response time is a ms off     from the end of the final fixation. this leaves some extremely short final fixations... like looking at          fix_item 0 ("nothing") for 1 ms. Let's clean these up, up to 3 ms errors. I'll leave the rest, since they        could be the effects of blinking at time of response... or something else like that.
    data.fixation = data.fixation %>%
      group_by(parcode, trial) %>%
      mutate(
        max_fix_num = max(fix_num))
    
    data.fixation$keep = 1
    for (i in seq(1,3,1)) {
      data.fixation$keep[data.fixation$fix_time==i & data.fixation$fix_num==data.fixation$max_fix_num] = 0}
    drop = c("fix_num", "max_fix_num", "keep")
    data.fixation = data.fixation[data.fixation$keep==1, !(names(data.fixation) %in% drop)]
    
    return(data.fixation)}
  
  # Run the function for the gain and loss trials separately and save.
  fixationsGain = expand_then_collapse_fixations(data.gain)
  write.csv(
    fixationsGain,
    file=file.path(studydir, paste0(dataset, "/fixationsGain.csv")), 
    row.names=F)
  fixationsLoss = expand_then_collapse_fixations(data.loss)
  write.csv(
    fixationsLoss,
    file=file.path(studydir, paste0(dataset, "/fixationsLoss.csv")), 
    row.names=F)}


##########################################################################################
# Dots
##########################################################################################

load(file.path(dots_datadir, "e/cfr_dots.RData"))
make_expdata(cfr_dots, studydir = dots_datadir, dataset = "e")
make_fixations(cfr_dots, studydir = dots_datadir, dataset = "e")
load(file.path(dots_datadir, "c/cfr_dots.RData"))
make_expdata(cfr_dots, studydir = dots_datadir, dataset = "c")
make_fixations(cfr_dots, studydir = dots_datadir, dataset = "c")
load(file.path(dots_datadir, "j/cfr_dots.RData"))
make_expdata(cfr_dots, studydir = dots_datadir, dataset = "j")
make_fixations(cfr_dots, studydir = dots_datadir, dataset = "j")


##########################################################################################
# Numeric
##########################################################################################

load(file.path(numeric_datadir, "e/cfr_numeric.RData"))
make_expdata(cfr_numeric, studydir = numeric_datadir, dataset = "e")
make_fixations(cfr_numeric, studydir = numeric_datadir, dataset = "e")
load(file.path(numeric_datadir, "c/cfr_numeric.RData"))
make_expdata(cfr_numeric, studydir = numeric_datadir, dataset = "c")
make_fixations(cfr_numeric, studydir = numeric_datadir, dataset = "c")
load(file.path(numeric_datadir, "j/cfr_numeric.RData"))
make_expdata(cfr_numeric, studydir = numeric_datadir, dataset = "j")
make_fixations(cfr_numeric, studydir = numeric_datadir, dataset = "j")


##########################################################################################
# Food
##########################################################################################

load(file.path(food_datadir, "e/cfr_food.RData"))
make_expdata(cfr_food, studydir = food_datadir, dataset = "e")
make_fixations(cfr_food, studydir = food_datadir, dataset = "e")
load(file.path(food_datadir, "c/cfr_food.RData"))
make_expdata(cfr_food, studydir = food_datadir, dataset = "c")
make_fixations(cfr_food, studydir = food_datadir, dataset = "c")
load(file.path(food_datadir, "j/cfr_food.RData"))
make_expdata(cfr_food, studydir = food_datadir, dataset = "j")
make_fixations(cfr_food, studydir = food_datadir, dataset = "j")