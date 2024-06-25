##############
# Preamble
##############

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)
library(ggnewscale)



#------------- Things you should edit at the start -------------
dataset = "e"
nTrials = "146_trials"
fn = "aDDM_modelComparison_E.pdf"

cfrdir = file.path("../../../data/processed_data/datasets")
load(file.path(cfrdir, paste0(dataset, "cfr.RData")))
cfr = ecfr
#---------------------------------------------------------------

codedir = getwd()
datadir = file.path(paste0("../aDDM_fitting/results"))#_", nTrials))
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
colors = list(Gain="Green4", Loss="Red3")

study1G_folder = file.path(datadir, "study1G/model_comparison/")
study1L_folder = file.path(datadir, "study1L/model_comparison/")
study2G_folder = file.path(datadir, "study2G/model_comparison/")
study2L_folder = file.path(datadir, "study2L/model_comparison/")

study1_subjects = unique(cfr$subject[cfr$studyN==1])
study2_subjects = unique(cfr$subject[cfr$studyN==2])


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
pdata = do.call(rbind, list(study1G, study1L, study2G, study2L))
#pdata$dataset = ""
#pdata$dataset[(pdata$subject<=36) | (pdata$subject>200 & pdata$subject<300)] = "e"
#pdata$dataset[(pdata$subject>36 & pdata$subject<200) | (pdata$subject>300)] = "c"
#pdata$dataset = factor(pdata$dataset, levels = c("e","c"), labels = c("Exploratory","Confirmatory"))

##############
# Plot
##############

plt = ggplot(pdata, aes(x=likelihood_fn, y=posterior_sum)) +
  myPlot + 
  
  geom_hline(yintercept=.5, color="lightgrey") +
  geom_line(aes(group=subject), color="grey", alpha=.4) +
  geom_boxplot(aes(fill=condition), width=.4, show.legend = T) +
  geom_dotplot(binaxis="y", stackdir="center", dotsize = .85, fill = 'white') +
  
  labs(
    y = "Posterior Model Probability",
    x = "Model",
    fill = "Condition"
  ) +
  scale_y_continuous(breaks=c(0, .5, 1)) +
  facet_grid(rows=vars(condition), cols=vars(study)) +
  theme(
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines"),
    legend.position = c(.375,.88)
  ) 

plot(plt)
ggsave(file.path(figdir, fn), plot=plt, width = 16.5, height = 5.5)
  
