################
# Preamble
################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(ggplot2)
library(ggsci)
figdir = "../../outputs/figures"
fitdir = "../../outputs/temp"
datadir = "../../../data/processed_data"
source("get_estimates_likelihoods.R")

M = 8 # number of models


################
# Get BICs
################

# Standard aDDM

dots_aDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="aDDM", dataset="e", parameterCount=4)
numeric_aDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="aDDM", dataset="e", parameterCount=4)

# Unbounded aDDM

dots_UaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="UaDDM", dataset="e", parameterCount=4)
numeric_UaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="UaDDM", dataset="e", parameterCount=4)

# Additive Attentional Model

dots_AddDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="AddDDM", dataset="e", parameterCount=4)
numeric_AddDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="AddDDM", dataset="e", parameterCount=4)

# Divisive Normalization

dots_DNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="DNaDDM", dataset="e", parameterCount=4)
numeric_DNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="DNaDDM", dataset="e", parameterCount=4)

# Goal-Dependent

dots_GDaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="GDaDDM", dataset="e", parameterCount=4)
numeric_GDaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="GDaDDM", dataset="e", parameterCount=4)

# Range Normalization

dots_RNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="RNaDDM", dataset="e", parameterCount=4)
numeric_RNaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="RNaDDM", dataset="e", parameterCount=4)

# Range Normalization with Additive Constant

dots_RNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="RNPaDDM", dataset="e", parameterCount=5)
numeric_RNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="RNPaDDM", dataset="e", parameterCount=5)

# Dynamic Range Normalization (Within-Context History Dependent) with Additive Constant

dots_DRNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="dots", model="DRNPaDDM", dataset="e", parameterCount=5)
numeric_DRNPaDDM_IC = getIC(datadir=datadir, fitdir=fitdir, study="numeric", model="DRNPaDDM", dataset="e", parameterCount=5)


################
# Get BIC-Approximated Posterior Model Probabilities (see Hawkins et al 2015)
################

## DOTS

dots_m_hat = data.frame(matrix(data=NA, nrow=(nrow(dots_aDDM_IC$BIC)), ncol=M))
dots_ppm = dots_m_hat

dots_m_hat[,1] = exp(-.5*dots_aDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,2] = exp(-.5*dots_UaDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,3] = exp(-.5*dots_AddDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,4] = exp(-.5*dots_DNaDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,5] = exp(-.5*dots_GDaDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,6] = exp(-.5*dots_RNaDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,7] = exp(-.5*dots_RNPaDDM_IC$BIC) %>% apply(1,sum)
dots_m_hat[,8] = exp(-.5*dots_DRNPaDDM_IC$BIC) %>% apply(1,sum)

dots_m_hat_rowsums = apply(dots_m_hat, 1, sum)
for (row in c(1:nrow(dots_m_hat))) {
  for (col in c(1:ncol(dots_m_hat))) {
    dots_ppm[row,col] = round(dots_m_hat[row,col] / dots_m_hat_rowsums[row], 3)
  }
}

## NUMERIC

numeric_m_hat = data.frame(matrix(data=NA, nrow=(nrow(numeric_aDDM_IC$BIC)), ncol=M))
numeric_ppm = numeric_m_hat

numeric_m_hat[,1] = exp(-.5*numeric_aDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,2] = exp(-.5*numeric_UaDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,3] = exp(-.5*numeric_AddDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,4] = exp(-.5*numeric_DNaDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,5] = exp(-.5*numeric_GDaDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,6] = exp(-.5*numeric_RNaDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,7] = exp(-.5*numeric_RNPaDDM_IC$BIC) %>% apply(1,sum)
numeric_m_hat[,8] = exp(-.5*numeric_DRNPaDDM_IC$BIC) %>% apply(1,sum)

numeric_m_hat_rowsums = apply(numeric_m_hat, 1, sum)
for (row in c(1:nrow(numeric_m_hat))) {
  for (col in c(1:ncol(numeric_m_hat))) {
    numeric_ppm[row,col] = round(numeric_m_hat[row,col] / numeric_m_hat_rowsums[row], 3)
  }
}


################
# Plot it
################

# Dots pdata

dots_addm_ppm = data.frame(subject=c(1:length(dots_ppm[,1])), ppm_aDDM=dots_ppm[,1], ppm_AddDDM=dots_ppm[,3], ppm_GDaDDM=dots_ppm[,5])
dots_addm_ppm = dots_addm_ppm[order(-dots_addm_ppm$ppm_aDDM,-dots_addm_ppm$ppm_AddDDM, -dots_addm_ppm$ppm_GDaDDM),]

pdata_subject = c(1:(nrow(dots_ppm)*ncol(dots_ppm)))
pdata_model = c(1:(nrow(dots_ppm)*ncol(dots_ppm)))
pdata_ppm = c(1:(nrow(dots_ppm)*ncol(dots_ppm)))
i = 1
for (row in c(1:nrow(dots_addm_ppm))) {
  for (col in c(1:ncol(dots_ppm))) {
    subject = dots_addm_ppm$subject[row]
    pdata_subject[i] = row
    pdata_model[i] = col
    pdata_ppm[i] = dots_ppm[subject,col]
    i=i+1
  }
}
dots_pdata = data.frame(subject=pdata_subject, model=pdata_model, ppm=pdata_ppm)
dots_pdata$model = factor(dots_pdata$model, levels=c(1:M), labels=c("aDDM","UaDDM","AddDDM","DNaDDN","GDaDDM","RNaDDM","RNPaDDM","DRNPaDDM"))
dots_pdata = dots_pdata[order(dots_pdata$model, dots_pdata$ppm),]
dots_pdata$study = "Study 1"

# Numeric pdata

numeric_addm_ppm = data.frame(subject=c(1:length(numeric_ppm[,1])), ppm_aDDM=numeric_ppm[,1], ppm_AddDDM=numeric_ppm[,3], ppm_GDaDDM=numeric_ppm[,5])
numeric_addm_ppm = numeric_addm_ppm[order(-numeric_addm_ppm$ppm_aDDM,-numeric_addm_ppm$ppm_AddDDM, -numeric_addm_ppm$ppm_GDaDDM),]

pdata_subject = c(1:(nrow(numeric_ppm)*ncol(numeric_ppm)))
pdata_model = c(1:(nrow(numeric_ppm)*ncol(numeric_ppm)))
pdata_ppm = c(1:(nrow(numeric_ppm)*ncol(numeric_ppm)))
i = 1
for (row in c(1:nrow(numeric_addm_ppm))) {
  for (col in c(1:ncol(numeric_ppm))) {
    subject = numeric_addm_ppm$subject[row]
    pdata_subject[i] = row
    pdata_model[i] = col
    pdata_ppm[i] = numeric_ppm[subject,col]
    i=i+1
  }
}
numeric_pdata = data.frame(subject=pdata_subject, model=pdata_model, ppm=pdata_ppm)
numeric_pdata$model = factor(numeric_pdata$model, levels=c(1:M), labels=c("aDDM","UaDDM","AddDDM","DNaDDN","GDaDDM","RNaDDM","RNPaDDM","DRNPaDDM"))
numeric_pdata = numeric_pdata[order(numeric_pdata$model, numeric_pdata$ppm),]
numeric_pdata$study = "Study 2"

# Combine and plot

pdata = rbind(dots_pdata, numeric_pdata)

plt.ppm = ggplot(data=pdata, aes(x=subject, y=ppm)) +
  theme_bw() +
  geom_bar(aes(fill=model), stat="identity", width=.95) +
  labs(x = "Participant", y = "Posterior Model Probability", fill="Model") +
  theme(
    legend.position = "right",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.1, 'cm'),
    legend.spacing.y = unit(0.1, 'cm'),
    plot.title = element_text(size = 22),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12),
    panel.spacing = unit(2, "lines")
  ) +
  coord_cartesian(expand=F) +
  scale_fill_npg() +
  scale_y_continuous(breaks=c(0,.25,.5,.75,1)) +
  scale_x_continuous(breaks=c(1,25,36)) +
  facet_grid(. ~ study, scales="free", space="free")

ggsave(
  file.path(figdir, paste0("posterior_model_probabilities.pdf")), 
  plot=plt.ppm, width=8, height=4, units="in")
