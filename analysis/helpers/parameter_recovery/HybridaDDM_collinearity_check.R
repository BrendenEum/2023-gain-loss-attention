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
.most_recent_run = "2024.07.05.18.22"
# ------------------------------------------------------------------------

# Directories
figdir = file.path("../../outputs/figures/")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
HybridaDDM_Gain_dir = file.path("results_HybridaDDM_Gain", .most_recent_run)

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
    
    t_df = posteriors %>%
      group_by(theta) %>%
      summarize(variable = "theta", value = first(theta), marg_posterior = sum(posterior), true = t_true)
    e_df = posteriors %>%
      group_by(eta) %>%
      summarize(variable = "eta", value = first(eta), marg_posterior = sum(posterior), true = e_true)
    
    marg_posterior_df = do.call(bind_rows, list(t_df, e_df))
    marg_posterior_df$subject = s
    marg_posterior_df$condition = condition
    
    posteriors_df = rbind(posteriors_df, marg_posterior_df)
  }
  
  return(posteriors_df)
}

HybridG = getHybridaDDMParameterPosteriors(HybridaDDM_Gain_dir, "Gain", H_subjects, .nTrials)

# Only keep veraibles of interest
voi = c("subject", "condition", "variable", "true", "value", "marg_posterior")
data = bind_rows(HybridG[,voi])


######################################################
# Get analytical correlations
######################################################

# t_sds = c()
# e_sds = c()
# covariances = c()
# analytical_correlations = c()
# 
# for (s in unique(data$subject)) {
#   
#   sub_data = data[data$subject==s, ]
#   
#   t_marginal = sub_data[sub_data$variable=="theta",]
#   e_marginal = sub_data[sub_data$variable=="eta",]
#   
#   # expected values of marginals
#   t_ev = sum(t_marginal$value * t_marginal$marg_posterior)
#   e_ev = sum(e_marginal$value * e_marginal$marg_posterior)
#   
#   # standard deviations of marginals
#   t_sd = sqrt(sum((t_marginal$value - t_ev)^2 * t_marginal$marg_posterior))
#   e_sd = sqrt(sum((e_marginal$value - e_ev)^2 * e_marginal$marg_posterior))
#   
#   # joint posterior probabilities
#   t_list = c()
#   e_list = c()
#   post_list = c()
#   ind = 1
#   for (t in unique(t_marginal$value)) {
#     for (e in unique(e_marginal$value)) {
#       t_list[ind] = t
#       e_list[ind] = e
#       post_list[ind] = as.numeric(t_marginal[t_marginal$value==t, "marg_posterior"]) * 
#         as.numeric(e_marginal[e_marginal$value==e, "marg_posterior"])
#       ind = ind + 1
#     }
#   }
#   
#   # covariance of joint
#   t_e_cov = sum((t_list - t_ev) * (e_list - e_ev) * post_list)
#   
#   # correlations
#   new_correlation = t_e_cov / (t_sd * e_sd)
#   
#   # save
#   t_sds = c(t_sds, t_sd)
#   e_sds = c(e_sds, e_sd)
#   covariances = c(covariances, t_e_cov)
#   analytical_correlations = c(correlations, new_correlation)
#   
# }


##############################################################################
# Get numerically-approximated correlations
##############################################################################

.nSamples = 100000
numerical_correlations = c()

for (s in unique(data$subject)) {
  
  sub_data = data[data$subject==s, ]
  
  t_marginal = sub_data[sub_data$variable=="theta",]
  e_marginal = sub_data[sub_data$variable=="eta",]
  
  # Sample from marginal posteriors
  t_marginal_samples = sample(t_marginal$value, .nSamples, replace = TRUE, t_marginal$marg_posterior)
  e_marginal_samples = sample(e_marginal$value, .nSamples, replace = TRUE, e_marginal$marg_posterior)
  
  # Calculate correlation using samples
  numerical_correlations = c(
    numerical_correlations,
    cor(t_marginal_samples, e_marginal_samples)
  )
  
}
numerical_correlations = data.frame(cors = numerical_correlations)

##############################################################################
# Plot
##############################################################################

plt_cor = ggplot(data = numerical_correlations) +
  myPlot +
  
  geom_vline(xintercept = 0, color = "grey50") +
  geom_histogram(aes(cors), binwidth = .001, color = NA, fill = "dodgerblue", alpha = .8) +

  labs(y = "Count", x = TeX("Numerically Approximated Correlation($\\theta$, $\\eta$)")) +
  coord_cartesian(ylim = c(0, 15), xlim = c(-0.009, 0.009), expand = F) +
  scale_x_continuous(breaks = seq(-0.008, 0.008, 0.004))

ggsave(file.path(figdir, "HybridaDDM_theta_eta_correlation.pdf"), plt_cor, height=4, width=6, units="in")
