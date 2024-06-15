##############
# Preamble
##############

rm(list=ls())
set.seed(4)
library(tidyverse)
library(ggalluvial)
library(plotrix)
library(gridExtra)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)

#------------- Things you should edit at the start -------------
dataset = "e"
colors = list(Gain="Green4", Loss="Red3")
nTrials = "146_trials"
#---------------------------------------------------------------

codedir = getwd()
datadir = file.path(paste0("../aDDM_fitting/results_", nTrials))
cfrdir = file.path("../../../data/processed_data/datasets")
load(file.path(cfrdir, paste0(dataset, "cfr.RData")))
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))

study1G_folder = file.path(datadir, "study1G/model_comparison/")
study1L_folder = file.path(datadir, "study1L/model_comparison/")
study2G_folder = file.path(datadir, "study2G/model_comparison/")
study2L_folder = file.path(datadir, "study2L/model_comparison/")

study1_subjects = unique(ecfr$subject[ecfr$studyN==1])
study2_subjects = unique(ecfr$subject[ecfr$studyN==2])


##############
# Load and Clean Data
##############

getData = function(folder, studyN, condition, subjectList) {
  
  subj = c()
  prob = c()
  posteriors_df = data.frame()
  
  for (i in 1:length(subjectList)) {
    s = subjectList[i]
    posteriors = read.csv(file = file.path(folder, paste0("combdf_", s, ".csv")))
    posteriors$studyN = studyN
    posteriors$subject = s
    posteriors$condition = condition
    posteriors_df = rbind(posteriors_df, posteriors)
  }
  
  posteriors_df$likelihood_fn = factor(
    posteriors_df$likelihood_fn,
    levels=c("AddDDM_likelihood","RaDDM_likelihood","MaxMin_likelihood", "StatusQuo_likelihood"),
    labels=c("AddDDM","RaDDM","MMaDDM", "SQaDDM")
  )

  posteriors_df$study = factor(posteriors_df$studyN, levels=c(1,2), labels=c("Study 1","Study 2"))
  
  return(posteriors_df)
}

study1G = getData(study1G_folder, 1, "Gain", study1_subjects)
study1L = getData(study1L_folder, 1, "Loss", study1_subjects)
study2G = getData(study2G_folder, 2, "Gain", study2_subjects)
study2L = getData(study2L_folder, 2, "Loss", study2_subjects)

# Combine
posteriors = do.call(rbind, list(study1G, study1L, study2G, study2L))

# Get best-fitting model by study-subject-condition
bestFits = posteriors %>%
  arrange(study, subject, condition, desc(posterior_sum)) %>%
  group_by(study, subject, condition) %>%
  summarize(
    likelihood_fn = first(likelihood_fn)
  ) %>% ungroup() %>%
  group_by(study, subject) %>%
  summarize(
    likelihood_gain = first(likelihood_fn), # gain then loss, because of arrange
    likelihood_loss = last(likelihood_fn)
  )

# Turn into Alluvian data
pdata = bestFits %>%
  group_by(study, likelihood_gain, likelihood_loss) %>%
  summarize(
    freq = n()
  )

##############
# Plot
##############

plt = ggplot(pdata, aes(y = freq, axis1 = likelihood_gain, axis2 = likelihood_loss)) +
  myPlot + 
  
  geom_alluvium(aes(fill=likelihood_gain)) +
  geom_stratum(width = 1/6, alpha = .8) +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  
  scale_x_discrete(limits = c("Gain", "Loss"), expand = c(.05, .05)) +
  scale_fill_brewer(type = "qual", palette = "Set1") +
  labs(y = "Participants") +
  theme(
    panel.spacing = unit(1.2, "lines")
  ) +
  
  facet_grid(rows = vars(study), scales = "free_y")
  
  
plot(plt)
ggsave(file.path(figdir, "aDDM_SameModelAcrossConditions.pdf"), plot=plt, width = 7, height = 9)
