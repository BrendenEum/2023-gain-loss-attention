# This script will write a few text files. These files will contain info on
# average dropped trials per subject in each dataset. That allows us to 
# automatically update the document if changes occur.

library(tidyverse)
datadir = file.path("../../data/processed_data")
textdir = file.path("../outputs/text")
load(file.path(processed.datadir, "jcfr.RData"))

# 400 trials in dots task.

dotsTotalTrials = 400
.data = jcfr[jcfr$dataset=="dots",]
.data = .data %>%
  group_by(subject, trial) %>%
  summarize(choice = first(choice)) %>%
  ungroup() %>%
  group_by(subject) %>%
  summarize(trialCount = n()) %>%
  mutate(droppedTrials = dotsTotalTrials - trialCount)

dots_averageDroppedTrials = mean(.data$droppedTrials)
write(dots_averageDroppedTrials, file = file.path(textdir, "dots_averageDroppedTrials.txt"))

# 340 trials in numeric task.

numericTotalTrials = 340
.data = jcfr[jcfr$dataset=="numeric",]
.data = .data %>%
  group_by(subject, trial) %>%
  summarize(choice = first(choice)) %>%
  ungroup() %>%
  group_by(subject) %>%
  summarize(trialCount = n()) %>%
  mutate(droppedTrials = numericTotalTrials - trialCount)

numeric_averageDroppedTrials = mean(.data$droppedTrials)
write(numeric_averageDroppedTrials, file = file.path(textdir, "numeric_averageDroppedTrials.txt"))

# 2 trials in food task.

foodTotalTrials = 2
.data = jcfr[jcfr$dataset=="food",]
.data = .data %>%
  group_by(subject, trial) %>%
  summarize(choice = first(choice)) %>%
  ungroup() %>%
  group_by(subject) %>%
  summarize(trialCount = n()) %>%
  mutate(droppedTrials = foodTotalTrials - trialCount)

food_averageDroppedTrials = mean(.data$droppedTrials)
write(food_averageDroppedTrials, file = file.path(textdir, "food_averageDroppedTrials.txt"))