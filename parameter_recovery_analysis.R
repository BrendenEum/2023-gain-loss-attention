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

Add_subjects = c(1:20)
Ref_subjects = c(1:36)

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
    levels=c("AddDDM_likelihood","RaDDM_likelihood","MaxMin_likelihood", "StatusQuo_likelihood"),
    labels=c("AddDDM","RaDDM","MMaDDM", "SQaDDM")
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
  geom_line(aes(group=subject), color="grey", alpha=.2) +
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



######################################################
# RaDDM Parameter Recovery
######################################################

# Function to get parameter posteriors
getRaDDMParameterPosteriors = function(folder, condition, subjectList) {
  
  subj = c()
  prob = c()
  posteriors_df = data.frame()
  
  for (i in 1:length(subjectList)) {
    s = subjectList[i]
    
    true_values = read.csv(file = file.path(folder, "sim_grid.csv"))
    d_true = true_values[i, "d"]
    s_true = true_values[i, "sigma"]
    t_true = true_values[i, "theta"]
    r_true = true_values[i, "ref"]
    
    posteriors = read.csv(file = file.path(folder, paste0("posteriors_df_", s, ".csv")))
    posteriors = posteriors[posteriors$likelihood_fn == "RaDDM_likelihood", ]
    posteriors$posterior = posteriors$posterior / sum(posteriors$posterior)
    
    d_df = posteriors %>%
      group_by(d) %>%
      summarize(variable = "d", value = first(d), marg_posterior = sum(posterior), true = d_true)
    s_df = posteriors %>%
      group_by(sigma) %>%
      summarize(variable = "sigma", value = first(sigma), marg_posterior = sum(posterior), true = s_true)
    t_df = posteriors %>%
      group_by(theta) %>%
      summarize(variable = "theta", value = first(theta), marg_posterior = sum(posterior), true = t_true)
    r_df = posteriors %>%
      group_by(ref) %>%
      summarize(variable = "ref", value = first(ref), marg_posterior = sum(posterior), true = r_true)
    
    marg_posterior_df = do.call(bind_rows, list(d_df, s_df, t_df, r_df))
    marg_posterior_df$subject = s
    marg_posterior_df$condition = condition
    
    posteriors_df = rbind(posteriors_df, marg_posterior_df)
  }
  
  return(posteriors_df)
}

RefG = getRaDDMParameterPosteriors(RaDDM_Gain_dir, "Gain", Ref_subjects)
RefL = getRaDDMParameterPosteriors(RaDDM_Loss_dir, "Loss", Ref_subjects)

## Plot marginal posteriors

pdata = bind_rows(RefG, RefL)
pdata$value = factor(pdata$value)
pdata$true = factor(pdata$true)

for (sim in Ref_subjects) {
  
  pd = pdata[pdata$subject == sim, ]

  plt = ggplot(data=pd, aes(x=value, y=marg_posterior)) +
    myPlot +
    geom_hline(yintercept=.5, color="lightgrey") +

    geom_bar(aes(fill=condition), stat="identity", alpha=.7) +
    geom_vline(aes(xintercept=true, group=condition), linewidth=3.5, color="black", linetype="dashed") +

    labs(
      y = "Marginal Posterior Probability"
    ) +
    facet_grid(rows=vars(condition), cols=vars(variable), scales="free", space="free") +
    scale_y_continuous(limits = c(0,1), breaks=c(0, .5, 1), expand=c(0,0)) +
    theme(
      axis.title.x=element_blank(),
      strip.text.x = element_text(size = 20),
      strip.background = element_blank(),
      strip.text.y = element_blank(),
      panel.spacing = unit(1, "lines")
    )

  fn = paste0("Sim", sim, "_MarginalPosteriors.pdf")
  ggsave(file.path(paste0("parameter_recovery_",pr_trials) , fn), plot=plt, width = 21.5, height = 6)
}