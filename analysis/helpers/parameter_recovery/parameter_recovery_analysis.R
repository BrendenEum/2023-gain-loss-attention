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
nTrials = 146
# ------------------------------------------------------------------------

# Directories
figdir = file.path("parameter_recovery_146_trials/")
optdir = file.path("../plot_options/")
source(file.path(optdir, "GainLossColorPalette.R"))
source(file.path(optdir, "MyPlotOptions.R"))
AddDDM_Gain_dir = file.path("results_AddDDM_Gain/", pr_trials)
AddDDM_Loss_dir = file.path("results_AddDDM_Loss/", pr_trials)
RaDDM_Gain_dir = file.path("results_RaDDM_Gain/", pr_trials)
RaDDM_Loss_dir = file.path("results_RaDDM_Loss/", pr_trials)

Add_subjects = c(1:24)
Ref_subjects = c(1:36)


######################################################
# Get Posteriors
######################################################

# Function to get parameter posteriors
getRaDDMParameterPosteriors = function(folder, condition, subjectList, nTrials) {
  
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
    
    likelihoods = read.csv(file = file.path(folder, paste0("likelihoods_df_", s, ".csv")))
    
    likelihoods$posterior = NA
    likelihoods$posterior[likelihoods$trial_num==1] = 
      likelihoods$likelihood[likelihoods$trial_num==1] / sum(likelihoods$likelihood[likelihoods$trial_num==1])
    for (r in 2:nTrials) {
      # posterior from last trial becomes prior. multiply by likelihood.
      likelihoods$posterior[likelihoods$trial_num==r] = 
        likelihoods$posterior[likelihoods$trial_num==(r-1)] * likelihoods$likelihood[likelihoods$trial_num==r]
      # renormalize.
      likelihoods$posterior[likelihoods$trial_num==r] = 
        likelihoods$posterior[likelihoods$trial_num==r] / sum(likelihoods$posterior[likelihoods$trial_num==r])
    }
    posteriors = likelihoods[likelihoods$trial_num==nTrials,]
    
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

RefG = getRaDDMParameterPosteriors(RaDDM_Gain_dir, "Gain", Ref_subjects, nTrials)
RefL = getRaDDMParameterPosteriors(RaDDM_Loss_dir, "Loss", Ref_subjects, nTrials)

# Only keep veraibles of interest
voi = c("subject", "condition", "variable", "true", "value", "marg_posterior")
data = bind_rows(RefG[,voi], RefL[,voi])

# Get mean and HDI of marginal posterior
summary_data = data %>%
  group_by(subject, condition, variable, true) %>%
  mutate(
    mean = sum(marg_posterior*value),
    cdf = cumsum(marg_posterior),
    in_hdi = (cdf > .025 & cdf < .975)
  )

adjust_bool <- function(bool) {
  n <- length(bool)
  result <- bool
  for (i in 1:n) {
    # include the values that are just outside hdi since it's a discrete distrib
    if (bool[i]) {
      if (i > 1) result[i - 1] <- TRUE
      if (i < n) result[i + 1] <- TRUE
    }
  }
  return(result)
}

adjust_cdf <- function(cdf, bool) {
  n <- length(cdf)
  result <- bool
  # if mass is clustered at min
  if (cdf[1] >= .975) {
    result[1] = TRUE
  }
  # if mass is clustered at max
  if (cdf[n] >= .975 & cdf[n-1] <= .025) {
    result[n-1] = TRUE
    result[n] = TRUE
  }
  # if mass is clustered precisely somewhere in between
  for (i in 2:n) {
    if (cdf[i] >= .975 & cdf[i-1] <= .025) {
      result[i-1] = TRUE
      result[i] = TRUE
    }
  }
  return(result)
}

summary_data <- summary_data %>%
  group_by(subject, condition, variable, true) %>%
  mutate(
    in_hdi = adjust_bool(in_hdi),
    in_hdi = adjust_cdf(cdf, in_hdi),
  )

summary_data = summary_data[summary_data$in_hdi == T,]

# Just keep what's needed for plotting
pdata = summary_data %>%
  group_by(subject, condition, variable, true) %>%
  summarize(
    mean = first(mean),
    hdi_lower = first(value),
    hdi_upper = last(value)
  )

pdata$true = factor(pdata$true)

######################################################
# Plot each parameter separately
######################################################

dodgewidth = .9

# drift
plt.d = ggplot(data=pdata[pdata$variable=="d",], aes(x=true, y=mean)) +
  myPlot +
  geom_hline(yintercept = .003, color = "grey85") +
  geom_hline(yintercept = .007, color = "grey85") +

  geom_pointrange(
    aes(ymin=hdi_lower, ymax=hdi_upper, color = condition), 
    size = .1,
    position = position_dodge2(width = dodgewidth)
  ) +

  coord_cartesian(ylim = c(0,.012)) +
  scale_y_continuous(breaks = c(.003, .007, .011)) +
  labs(
    title = TeX("$d$"),
    y = "Estimate",
    x = "True Value"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines")
  ) +
  facet_grid(rows=vars(condition))

# sigma
plt.s = ggplot(data=pdata[pdata$variable=="sigma",], aes(x=true, y=mean)) +
  myPlot +
  geom_hline(yintercept = .03, color = "grey85") +
  geom_hline(yintercept = .07, color = "grey85") +
  
  geom_pointrange(
    aes(ymin=hdi_lower, ymax=hdi_upper, color = condition), 
    size = .1,
    position = position_dodge2(width = dodgewidth)
  ) +
  
  coord_cartesian(ylim = c(.01,.09)) +
  scale_y_continuous(breaks = c(.01, .03, .05, .07, .09)) +
  labs(
    title = TeX("$\\sigma$"),
    y = "Estimate",
    x = "True Value"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title.y = element_blank(),
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines")
  ) +
  facet_grid(rows=vars(condition))

# theta
plt.t = ggplot(data=pdata[pdata$variable=="theta",], aes(x=true, y=mean)) +
  myPlot +
  geom_hline(yintercept = .2, color = "grey85") +
  geom_hline(yintercept = .5, color = "grey85") +
  geom_hline(yintercept = .8, color = "grey85") +
  
  geom_pointrange(
    aes(ymin=hdi_lower, ymax=hdi_upper, color = condition), 
    size = .1,
    position = position_dodge2(width = (dodgewidth-.1))
  ) +
  
  coord_cartesian(ylim = c(0,1)) +
  scale_y_continuous(breaks = c(.2, .5, .8)) +
  labs(
    title = TeX("$\\theta$"),
    y = "Estimate",
    x = "True Value"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title.y = element_blank(),
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines")
  ) +
  facet_grid(rows=vars(condition))

# ref
plt.r = ggplot(data=pdata[pdata$variable=="ref",], aes(x=true, y=mean)) +
  myPlot +
  geom_hline(yintercept = -12, color = "grey85") +
  geom_hline(yintercept = 0, color = "grey85") +
  geom_hline(yintercept = 12, color = "grey85") +
  
  geom_pointrange(
    aes(ymin=hdi_lower, ymax=hdi_upper, color = condition), 
    size = .1,
    position = position_dodge2(width = (dodgewidth-.1))
  ) +
  
  coord_cartesian(ylim = c(-20,14)) +
  scale_y_continuous(breaks = c(-12, 0, 12)) +
  labs(
    title = TeX("$r$"),
    y = "Estimate",
    x = "True Value"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title.y = element_blank(),
    strip.text.x = element_text(size = 20),
    strip.background = element_blank(),
    strip.text.y = element_blank(),
    panel.spacing = unit(1, "lines")
  ) +
  facet_grid(rows=vars(condition))


##############################################################################
# Combine plots
##############################################################################

plt.ParamRecov <- grid.arrange(
  arrangeGrob(
    plt.d, plt.s, plt.t, plt.r,
    ncol = 4
  ),
  nrow = 1
)

plot(plt.ParamRecov)

ggsave(file.path(figdir, "ParameterRecovery.pdf"), plt.ParamRecov, height=4.5, width=14.75, units="in")
