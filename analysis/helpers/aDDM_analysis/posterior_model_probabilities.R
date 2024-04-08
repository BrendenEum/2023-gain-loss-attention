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

#------------- Things you should edit at the start -------------
dataset = "e"
datafolder = "2024.04.06-11.22/Stage3"
colors = list(Gain="Green4", Loss="Red3")
#---------------------------------------------------------------

codedir = getwd()
datadir = file.path(paste0("../../outputs/temp/model_fitting/", datafolder))
cfrdir = file.path("../../../data/processed_data/datasets")
load(file.path(cfrdir, paste0(dataset, "cfr.RData")))
figdir = file.path("../../outputs/figures")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))

Study1_folder = file.path(datadir, "Study1E")
Study2_folder = file.path(datadir, "Study2E")

Study1_subjects = unique(ecfr$subject[ecfr$studyN==1])
Study2_subjects = unique(ecfr$subject[ecfr$studyN==2])


##############
# Load and Clean Data
##############

getData = function(folder, subjectList) {
  gain_compare = list()
  loss_compare = list()
  gain_posterior = list()
  loss_posterior = list()
  
  for (i in subjectList) {
    gain_compare[[i]] = read.csv(file = file.path(folder, paste0("Gain_modelComparison_", i, ".csv")))
    loss_compare[[i]] = read.csv(file = file.path(folder, paste0("Loss_modelComparison_", i, ".csv")))
    gain_posterior[[i]] = read.csv(file = file.path(folder, paste0("Gain_modelPosteriors_", i, ".csv")))
    loss_posterior[[i]] = read.csv(file = file.path(folder, paste0("Loss_modelPosteriors_", i, ".csv")))
    gain_compare[[i]]$subject = i
    loss_compare[[i]]$subject = i
    gain_posterior[[i]]$subject = i
    loss_posterior[[i]]$subject = i
  }
  gc = do.call("rbind", gain_compare)
  lc = do.call("rbind", loss_compare)
  gp = do.call("rbind", gain_posterior)
  lp = do.call("rbind", loss_posterior)
  
  gc$condition = "Gain"
  lc$condition = "Loss"
  gp$condition = "Gain"
  lp$condition = "Loss"
  compare = rbind(gc, lc)
  posteriors = rbind(gp, lp)
  
  compare$likelihood_fn = factor(
    compare$likelihood_fn,
    levels=c("aDDM_likelihood","AddDDM_likelihood","RaDDM_likelihood"),
    labels=c("aDDM","AddDDM","RaDDM")
  )
  posteriors$likelihood_fn = factor(
    posteriors$likelihood_fn,
    levels=c("aDDM_likelihood","AddDDM_likelihood","RaDDM_likelihood"),
    labels=c("aDDM","AddDDM","RaDDM")
  )
  
  return(list(compare = compare, posteriors = posteriors))
}

Study1 = getData(Study1_folder, Study1_subjects)
Study2 = getData(Study2_folder, Study2_subjects)

# Study N
Study1$compare$study = 1
Study2$compare$study = 2

# Combine
pdata = rbind(Study1$compare, Study2$compare)

# Factor
pdata$study = factor(pdata$study, levels=c(1,2), labels=c("Study 1","Study 2"))

##############
# Plot
##############

plt = ggplot(pdata, aes(x=likelihood_fn, y=posterior_sum)) +
  myPlot + 
  
  geom_hline(yintercept=.33, color="lightgrey") +
  geom_boxplot(aes(fill=condition), width=.4) +
  geom_dotplot(binaxis="y", stackdir="center", dotsize=1, fill="white") +
  
  labs(
    y = "Posterior Model Probability",
    x = "Model",
    fill = "Condition"
  ) +
  scale_y_continuous(breaks=c(0, .33, 1)) +
  facet_grid(rows=vars(condition), cols=vars(study)) +
  theme(
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines"),
    legend.position = c(.165,.88)
  )
plot(plt)
ggsave(file.path(figdir, "aDDM_modelComparison.pdf"), plot=plt, width = 12, height = 5)
