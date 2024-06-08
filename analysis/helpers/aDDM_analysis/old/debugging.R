##############################################################################
# Preamble
##############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)

#------------- Things you should edit at the start -------------
.dataset = "2024.04.05-18.22/Stage3"
.colors = list(Gain="Green4", Loss="Red3")
#---------------------------------------------------------------

.codedir = getwd()
.datadir = file.path(paste0("../../outputs/temp/model_fitting/", .dataset))
.cfrdir = file.path("../../../data/processed_data")
load(file.path(.cfrdir, "ecfr.RData"))
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

Study1_subjects = unique(ecfr$subject[ecfr$studyN==1])
Study2_subjects = unique(ecfr$subject[ecfr$studyN==2])


##############################################################################
# Load Data
##############################################################################

getData = function(folder, subjectList) {
  gain_posterior = list()
  loss_posterior = list()
  
  for (i in subjectList) {
    gain_posterior[[i]] = read.csv(file = file.path(folder, paste0("Gain_modelPosteriors_", i, ".csv")))
    loss_posterior[[i]] = read.csv(file = file.path(folder, paste0("Loss_modelPosteriors_", i, ".csv")))
    gain_posterior[[i]]$subject = i
    loss_posterior[[i]]$subject = i
  }
  gp = do.call("rbind", gain_posterior)
  lp = do.call("rbind", loss_posterior)
  
  gp$condition = "Gain"
  lp$condition = "Loss"
  posteriors = rbind(gp, lp)
  
  posteriors$likelihood_fn = factor(
    posteriors$likelihood_fn,
    levels=c("aDDM_likelihood","AddDDM_likelihood","RaDDM_likelihood"),
    labels=c("aDDM","AddDDM","RaDDM")
  )
  
  return(posteriors)
}

Study1 = getData(file.path(.datadir,"Study1E"), Study1_subjects)
Study2 = getData(file.path(.datadir,"Study2E"), Study2_subjects)


##############################################################################
# Combine and clean the data for plotting
##############################################################################

# Study N
Study1$study = 1
.data = Study1

# Factor
.data$study = factor(.data$study, levels=c(1,2), labels=c("1","2"))

# Limit to just RaDDM
.data = .data[.data$likelihood_fn=="AddDDM",]

# Get best fitting parameters for each subject
.data = .data %>%
  group_by(study, subject, condition) %>%
  mutate(best_fitting = posterior==max(posterior))
data = .data[.data$best_fitting==1,]

# Check uniqueness based on study-subject-condition.
.duplicate_rows = duplicated(data[,c("study","subject","condition")]) | duplicated(data[,c("study","subject","condition")], fromLast=T)
if (sum(.duplicate_rows) != 0) {
  warning("You have some duplicate study-subject-condition observations.")  
} else {
  print("You don't have any duplicate observations. It's safe to continue!")
}

view(data)
