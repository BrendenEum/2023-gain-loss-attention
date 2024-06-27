######################################################
# Preamble
######################################################

# Libraries
rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(patchwork)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)
options(dplyr.summarise.inform = FALSE)

# ------------------------------------------------------------------------
# Things to change
pr_trials = "146_trials"
# ------------------------------------------------------------------------

# Directories
figdir = file.path("../../outputs/figures/")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
AddDDM_Gain_dir = file.path("results_AddDDM_Gain/", pr_trials)
AddDDM_Loss_dir = file.path("results_AddDDM_Loss/", pr_trials)
RaDDM_Gain_dir = file.path("results_RaDDM_Gain/", pr_trials)
RaDDM_Loss_dir = file.path("results_RaDDM_Loss/", pr_trials)

Add_subjects = c(1:36)
Ref_subjects = c(1:27)

######################################################
# Model recovery
######################################################

getModelPosteriors = function(folder, condition, subjectList) {
  
  subj = c()
  prob = c()
  posteriors_df = data.frame()
  
  for (i in 1:length(subjectList)) {
    s = subjectList[i]
    posteriors = read.csv(file = file.path(folder, paste0("combdf_", s, ".csv")))
    posteriors$subject = s
    posteriors$condition = condition
    posteriors_df = rbind(posteriors_df, posteriors)
  }
  
  posteriors_df$likelihood_fn = factor(
    posteriors_df$likelihood_fn,
    levels=c("AddDDM_likelihood","RaDDM_likelihood"),
    labels=c("AddDDM","RaDDM")
  )
  
  return(posteriors_df)
}

AddG = getModelPosteriors(AddDDM_Gain_dir, "Gain", Add_subjects)
AddL = getModelPosteriors(AddDDM_Loss_dir, "Loss", Add_subjects)
RefG = getModelPosteriors(RaDDM_Gain_dir, "Gain", Ref_subjects)
RefL = getModelPosteriors(RaDDM_Loss_dir, "Loss", Ref_subjects)

AddG$generating = "AddDDM Sim."
AddL$generating = "AddDDM Sim."
RefG$generating = "RaDDM Sim."
RefL$generating = "RaDDM Sim."

pdata = do.call(rbind, list(AddG, AddL, RefG, RefL))
pdata$generating = factor(pdata$generating)

plt = ggplot(pdata, aes(x=likelihood_fn, y=posterior_sum)) +
  myPlot + 
  
  geom_hline(yintercept=.33, color="lightgrey") +
  geom_line(aes(group=subject), color="grey", alpha=.4) +
  geom_boxplot(aes(fill=condition), width=.4) +
  geom_dotplot(binaxis="y", stackdir="center", dotsize=1, fill="white") +
  
  labs(
    y = "Posterior Model Probability",
    x = "Model",
    fill = "Condition"
  ) +
  scale_y_continuous(breaks=c(0, .33, 1)) +
  facet_grid(rows=vars(condition), cols=vars(generating)) +
  theme(
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines"),
    legend.position = c(.55,.88)
  )
ggsave(file.path(paste0("parameter_recovery_",pr_trials) , "ModelRecovery.pdf"), plot=plt, width = 15, height = 5)
