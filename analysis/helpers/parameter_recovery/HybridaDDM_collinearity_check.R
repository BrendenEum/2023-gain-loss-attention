######################################################
# Preamble
######################################################

# Libraries
rm(list=ls())
set.seed(4)
library(tidyverse)
library(plotrix)
library(gridExtra)
library(patchwork)
library(ggpubr)
library(ggsci)
library(readr)
library(latex2exp)
options(dplyr.summarise.inform = FALSE)

# ------------------------------------------------------------------------
# Things to change
.nTrials = 146
.most_recent_run_G = "2024.07.05.18.22" # Gain
.most_recent_run_L = "2024.07.09.0.31" # Loss
# ------------------------------------------------------------------------

# Directories
figdir = file.path("../../outputs/figures/")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
HybridaDDM_Gain_dir = file.path("results_HybridaDDM_Gain", .most_recent_run_G)
HybridaDDM_Loss_dir = file.path("results_HybridaDDM_Loss", .most_recent_run_L)

H_subjects = c(1:81)


######################################################
# Get Posteriors
######################################################

# Function to get parameter posteriors
getHybridaDDMParameterPosteriors = function(folder, condition, subjectList, .nTrials) {
  
  subj = c()
  prob = c()
  posteriors_df = data.frame()
  
  for (i in 1:length(subjectList)) {
    s = subjectList[i]
    
    true_values = read.csv(file = file.path(folder, "sim_grid.csv"))
    d_true = true_values[i, "d"]
    s_true = true_values[i, "sigma"]
    t_true = true_values[i, "theta"]
    e_true = true_values[i, "eta"]
    
    posteriors = read.csv(file = file.path(folder, paste0("posteriors_df_", s, ".csv")))
    
    te_df = posteriors %>%
      group_by(theta, eta) %>%
      summarize(
        t_value = first(theta), 
        e_value = first(eta), 
        posterior = sum(posterior), 
        t_true = t_true,
        e_true = e_true
      )

    te_df$subject = s
    te_df$condition = condition
    
    posteriors_df = rbind(posteriors_df, te_df)
  }
  
  return(posteriors_df)
}

HybridG = getHybridaDDMParameterPosteriors(HybridaDDM_Gain_dir, "Gain", H_subjects, .nTrials)
HybridL = getHybridaDDMParameterPosteriors(HybridaDDM_Loss_dir, "Loss", H_subjects, .nTrials)

# Only keep veraibles of interest
voi = c("subject", "condition", "t_value", "e_value", "posterior", "t_true", "e_true")
data = bind_rows(HybridG[,voi], HybridL[,voi])


######################################################
# Get analytical correlations
######################################################

t_sds = c()
e_sds = c()
covariances = c()
correlations = c()

for (s in unique(data$subject)) {
  for (c in c("Gain", "Loss")) {
    
    sub_data = data[data$subject==s & data$condition==c, ]
    
    # expected values of marginals
    t_ev = sum(sub_data$t_value * sub_data$posterior)
    e_ev = sum(sub_data$e_value * sub_data$posterior)
    
    # standard deviations of marginals
    t_sd = sqrt(sum((sub_data$t_value - t_ev)^2 * sub_data$posterior))
    e_sd = sqrt(sum((sub_data$e_value - e_ev)^2 * sub_data$posterior))
    
    # covariance
    te_cov = sum(((sub_data$t_value - t_ev) * (sub_data$e_value - e_ev)) * sub_data$posterior)
    
    # correlations
    new_correlation = te_cov / (t_sd * e_sd)
    
    # save
    correlations = c(correlations, new_correlation)
    
  }
}

##############################################################################
# Plot
##############################################################################

plt_cor = ggplot(data = data.frame(cors = correlations)) +
  myPlot +

  geom_hline(yintercept = 5, color = "grey") +
  geom_histogram(aes(cors), binwidth = .01, color = NA, fill = "dodgerblue", alpha = .85) +

  labs(y = "Count", x = TeX("Hybrid Correlation ($\\theta$, $\\eta$)")) +
  coord_cartesian(ylim = c(0, 10), xlim = c(-0.01, 1.01), expand = F) +
  scale_y_continuous(breaks = c(0, 5, 10))

ggsave(file.path(figdir, "HybridaDDM_theta_eta_correlation.pdf"), plt_cor, height=4, width=6, units="in")
