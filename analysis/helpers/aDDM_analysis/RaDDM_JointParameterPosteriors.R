##############################################################################
# Preamble
##############################################################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(grid)
library(gridtext)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)

#------------- Things you should edit at the start -------------
.dataset = "e"
.timestamp = "2024.04.06-11.22-bounded-free-refpt/Stage3"
.colors = list(Gain="Green4", Loss="Red3")
#---------------------------------------------------------------

.codedir = getwd()
.datadir = file.path(paste0("../../outputs/temp/model_fitting/", .timestamp))
.cfrdir = file.path("../../../data/processed_data")
load(file.path(.cfrdir, paste0(.dataset, "cfr.RData")))
.figdir = file.path("../../outputs/figures")
.optdir = file.path("../plot_options/")
source(file.path(.optdir, "GainLossColorPalette.R"))
source(file.path(.optdir, "MyPlotOptions.R"))

.Study1_folder = file.path(.datadir, "Study1E")
.Study2_folder = file.path(.datadir, "Study2E")

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

Study1 = getData(.Study1_folder, Study1_subjects)
Study2 = getData(.Study2_folder, Study2_subjects)

Study1G = Study1[Study1$likelihood_fn=="RaDDM" & Study1$condition=="Gain",]
Study2G = Study2[Study2$likelihood_fn=="RaDDM" & Study1$condition=="Gain",]
Study1L = Study1[Study1$likelihood_fn=="RaDDM" & Study1$condition=="Loss",]
Study2L = Study2[Study2$likelihood_fn=="RaDDM" & Study1$condition=="Loss",]

##############################################################################
# Marginal posteriors
##############################################################################

parameters = c("d", "sigma", "eta", "bias", "likelihood_fn", "posterior", "theta", "reference", "subject", "condition")
column_number = c(1, 2, 4, 7, 8) # this is the corresponding column number for the variable

PlotMarginalPosterior = function(data, subject, variable_number) {
  tmp = data[data$subject==subject, ]
  pdata = data.frame(x=tmp[,variable_number], posterior=tmp$posterior)
  plt = ggplot(data=pdata) +
    
    geom_col(aes(x=x, y=posterior)) +
    
    labs(x = parameters[variable_number], y = "posterior") +
    theme_bw()
  return(plt)
}


##############################################################################
# Joint posteriors
##############################################################################

parameters = c("d", "sigma", "eta", "bias", "likelihood_fn", "posterior", "theta", "reference", "subject", "condition")
column_number = c(1, 2, 4, 7, 8) # this is the corresponding column number for the variable

PlotJointPosterior = function(data, subject, x_number, y_number) {
  tmp = data[data$subject==subject, ]
  pdata = data.frame(x=tmp[,x_number], y=tmp[,y_number], posterior=tmp$posterior)
  plt = ggplot(data=pdata) +
    
    geom_tile(aes(x=x, y=y, fill=posterior)) +
    scale_fill_distiller(palette = "Oranges") +
    
    labs(x = parameters[x_number], y = parameters[y_number]) +
    theme_bw()
  return(plt)
}


##############################################################################
# Plot all study-conditions
##############################################################################

PlotCorrelationMatrix = function(data, subject_list, study_string)
for (s in subject_list) {
  margPlt = list()
  margInd = 0
  jointPlt = list()
  jointInd = 0
  for (i in column_number) {
    margInd = margInd + 1
    margPlt[[margInd]] = PlotMarginalPosterior(data, s, i)
    for (j in column_number) {
      if (i < j) {
        jointInd = jointInd + 1
        jointPlt[[jointInd]] = PlotJointPosterior(data, s, i, j)
      }
    }
  }
  JointPosteriors = grid.arrange(
    margPlt[[1]], NULL, NULL, NULL, NULL,
    jointPlt[[1]], margPlt[[2]], NULL, NULL, NULL,
    jointPlt[[2]], jointPlt[[5]], margPlt[[3]], NULL, NULL,
    jointPlt[[3]], jointPlt[[6]], jointPlt[[8]], margPlt[[4]], NULL,
    jointPlt[[4]], jointPlt[[7]], jointPlt[[9]], jointPlt[[10]], margPlt[[5]],
    nrow = 5
  )
  fn = paste0("RaDDM_JointPosteriors/", study_string, "_", s, "_JointPosteriors.pdf")
  ggsave(file.path(.figdir, fn), JointPosteriors, height=7.5, width=16, units="in")
}

PlotCorrelationMatrix(Study1G, Study1_subjects, "Study1G")
PlotCorrelationMatrix(Study1L, Study1_subjects, "Study1L")
PlotCorrelationMatrix(Study2G, Study2_subjects, "Study2G")
PlotCorrelationMatrix(Study2L, Study2_subjects, "Study2L")


