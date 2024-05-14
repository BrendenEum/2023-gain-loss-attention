####################################
# Preamble
####################################

rm(list=ls())
set.seed(4)
library(tidyverse)
library(furrr) # parallelization of map functions from purrr, i.e. parallelize optimization
library(patchwork)
source("reference-point-functions.R")
source("../plot_options/GainLossColorPalette.R")
source("../plot_options/MyPlotOptions.R")
source("../plot_options/SE.R")
.figdir = file.path("../../outputs/figures")

load("../../../data/processed_data/datasets/ecfr.RData")
data = ecfr[ecfr$firstFix==T & ecfr$trial%%2==1, ] # Only one observation per trial and only in-sample trials!
outsample = ecfr[ecfr$firstFix==T & ecfr$trial%%2==0, ] # Out-of-sample data


####################################
# Functions for Prospect Theory
####################################

# Calculate subjective utility given lambda/rho.
# Takes a vector of values and parameters and returns subjective utilities.
calc_subjective_utility <- function(vals, lambda, rho) {
  ifelse(vals >= 0, vals^rho, -lambda * ((-vals)^rho))
}

# Calculate utility difference from vectors of gains, losses, and certainty.
calc_utility_diff <- function(tgt_amt, tgt_prob, oth_amt, oth_prob) {
  tgt_prob*tgt_amt - oth_amt*oth_prob
}

# Calculate the probability of accepting a gamble, given a difference in subjective utility and temperature.
calc_prob_tgt <- function(utility_diff, temperature) {
  (1 + exp(-temperature * (utility_diff)))^-1
}


####################################
# NLL function we will optimize over
####################################

minimize_LL_prospect <- function(df, par) {
  lambda_par <- par[1]
  rho_par <- par[2]
  temperature_par <- par[3]
  df_updated = df %>%
    mutate(
      L_su = calc_subjective_utility(LAmt, lambda_par, rho_par),
      R_su = calc_subjective_utility(RAmt, lambda_par, rho_par),
      utility_diff = calc_utility_diff(L_su, LProb, R_su, RProb),
      prob_accept = calc_prob_tgt(utility_diff, temperature = temperature_par),
      prob_accept_rc = case_when(
        prob_accept == 1 ~ 1-.Machine$double.eps,
        prob_accept == 0 ~ 0+.Machine$double.eps,
        TRUE ~ prob_accept
      ),
      log_likelihood_trial = choice * log(prob_accept_rc) + (1-choice) * log(1-prob_accept_rc)
    )
  
  -sum(df_updated$log_likelihood_trial)
}


####################################
# Create nested data
####################################

data_nested = data %>%
  nest(data = -c(studyN, subject, condition))


####################################
# Optimize over nested data with 4 different starting points (computationally heavy, but parallelized)
####################################

future::plan(multisession, workers = 4)

data_optim_quad <- data_nested %>%
  mutate(optim_out_1 = future_map(data, ~ optim(par = c(1.24, .83, 2.57),
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = c(.01,.01,.01),
                                                upper = c(20, 10, 20))),
         optim_out_2 = future_map(data, ~ optim(par = c(1, 1, 1),
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = c(.01,.01,.01),
                                                upper = c(20, 10, 20))),
         optim_out_3 = future_map(data, ~ optim(par = c(2, 1, .9),
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = c(.01,.01,.01),
                                                upper = c(20, 10, 20))),
         optim_out_4 = future_map(data, ~ optim(par = c(1.5, .83, 4.22),
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = c(.01,.01,.01),
                                                upper = c(20, 10, 20))))


####################################
# Compare results across different starting points and store the best
####################################

evaluate_model <- function(model_list) {
  
  names(model_list) <- str_c('m', 1:length(model_list))
  models_tibble <- as_tibble(model_list)
  
  convergence_mat <- models_tibble %>% 
    summarise(across(everything(), ~ map_dbl(., 'convergence'))) # convergence 
  ll_mat <- models_tibble %>% 
    summarise(across(everything(), ~ map_dbl(., 'value'))) # log likelihood
  
  ll_mat[convergence_mat != 0] <- NA # set LL of non-converging models to be NA
  lowest_likelihood <- apply(ll_mat, 1, which.min) # choose the minimum LL from each row
  
  index_mat <- matrix(c(1:nrow(models_tibble), lowest_likelihood), ncol = 2, byrow=FALSE)
  as.matrix(models_tibble)[index_mat] # for each row, return the optim output that had minimum LL
}

data_optim_quad_pars <- data_optim_quad %>% 
  mutate(best_model = evaluate_model(list(optim_out_1, optim_out_2, optim_out_3, optim_out_4)),
         convergence = map_dbl(best_model, 'convergence'),
         pars = map(best_model, 'par'),
         lambda = map_dbl(pars, ~ .[1]),
         rho = map_dbl(pars, ~ .[2]),
         temperature = map_dbl(pars, ~ .[3]))

if (sum(data_optim_quad_pars$convergence)>0) {warning("OPTIM DIDNT CONVERGE FOR AT LEAST ONE SUBJECT-CONDITION!")}


####################################
# Plot individual Estimates
####################################

hist_lambda <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = lambda)) +
  myPlot +
  geom_histogram() +
  geom_vline(xintercept = 1, color="red", linewidth=1.5) +
  labs(title = 'loss aversion')
hist_rho <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = rho)) +
  myPlot +
  geom_histogram() +
  labs(title = 'diminishing marginal returns')
hist_temperature <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = temperature)) +
  myPlot +
  geom_histogram() +
  labs(title = 'temperature')

plt = hist_lambda + hist_rho + hist_temperature
ggsave(file.path(.figdir, "ProspectTheory_IndividualEstimates.pdf"), plt, width=figw*2.5, height=figh)


####################################
# Group-Level Out-of-Sample Predictions
####################################

pdataA = merge(
  outsample, 
  data_optim_quad_pars[,c("studyN", "subject", "condition", "lambda", "rho", "temperature")], 
  by=c("studyN", "subject", "condition")
)

pdataA = pdataA %>%
  mutate(
    L_su = calc_subjective_utility(LAmt, lambda, rho),
    R_su = calc_subjective_utility(RAmt, lambda, rho),
    LR_diff = calc_utility_diff(L_su, LProb, R_su, RProb),
    pred_choice = calc_prob_tgt(LR_diff, temperature)
  ) %>%
  select("studyN", "subject", "condition", "choice", "pred_choice", "nvDiff") %>%
  group_by(studyN, subject, condition, nvDiff) %>%
  summarize(
    choice = mean(choice),
    pred_choice = mean(pred_choice)
  ) %>% ungroup() %>%
  group_by(studyN, condition, nvDiff) %>%
  summarize(
    y = mean(choice),
    y_se = SE(choice),
    yhat = mean(pred_choice),
    yhat_se = SE(pred_choice),
    simulated = 0
  )
pdataB = pdataA %>% mutate(y = yhat, y_se = yhat_se, simulated = 1)
pdata = rbind(pdataA, pdataB)
pdata$simulated = factor(pdata$simulated, levels = c(0,1), labels = c("Observed", "Simulated"))
pdata$studyN = factor(pdata$studyN, levels = c(1,2), labels = c("Study 1", "Study 2"))

plt = ggplot(data = pdata, aes(x = nvDiff, y = y)) +
  myPlot +
  
  geom_line(aes(color=simulated), linewidth=linewidth, show.legend = F) +
  geom_ribbon(aes(ymin = y-y_se, ymax = y+y_se, fill = simulated), alpha = .5) +
  
  facet_grid(rows = vars(studyN), cols = vars(condition)) +
  labs(x = "Norm. Left - Right E[V]", y = "Pr(Choose Left)") +
  theme(
    legend.position = c(.1, .92),
    panel.spacing = unit(2, "lines")
  ) +
  scale_fill_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue"), labels = c("Observed", "Simulated")) +
  coord_cartesian(xlim=c(-1,1), ylim=c(0,1), expand=F) +
  scale_x_continuous(breaks=c(-1, 0, 1)) +
  scale_y_continuous(breaks=c(0, .5, 1))

ggsave(file.path(.figdir, "ProspectTheory_GroupOutSamplePredictions.pdf"), plt, width=figw*1.2, height=figh*1.2)


####################################
# Individual-Level Out-of-Sample Predictions
####################################

set.seed(4)
study1subjects = sample(unique(outsample$subject[outsample$studyN==1]), 4)
study2subjects = sample(unique(outsample$subject[outsample$studyN==2]), 4)
outsample = outsample[outsample$subject %in% c(study1subjects, study2subjects),]

pdataA = merge(
  outsample, 
  data_optim_quad_pars[,c("studyN", "subject", "condition", "lambda", "rho", "temperature")], 
  by=c("studyN", "subject", "condition")
)

pdataA = pdataA %>%
  mutate(
    L_su = calc_subjective_utility(LAmt, lambda, rho),
    R_su = calc_subjective_utility(RAmt, lambda, rho),
    LR_diff = calc_utility_diff(L_su, LProb, R_su, RProb),
    pred_choice = calc_prob_tgt(LR_diff, temperature)
  ) %>%
  select("studyN", "subject", "condition", "choice", "pred_choice", "nvDiff") %>%
  group_by(studyN, subject, condition, nvDiff) %>%
  summarize(
    y = mean(choice),
    y_se = SE(choice),
    yhat = mean(pred_choice),
    yhat_se = SE(pred_choice),
    simulated = 0
  )
pdataB = pdataA %>% mutate(y = yhat, y_se = yhat_se, simulated = 1)
pdataFull = rbind(pdataA, pdataB)
pdataFull$simulated = factor(pdataFull$simulated, levels = c(0,1), labels = c("Observed", "Simulated"))
pdataFull$studyN = factor(pdataFull$studyN, levels = c(1,2), labels = c("Study 1", "Study 2"))
pdataFull[is.na(pdataFull)] = 0

for (sID in c(study1subjects, study2subjects)) {
  pdata = pdataFull[pdataFull$subject==sID, ]
  
  plt = ggplot(data = pdata, aes(x = nvDiff, y = y)) +
    myPlot +
    
    geom_line(aes(color=simulated), linewidth=linewidth, show.legend = F) +
    geom_ribbon(aes(ymin = y-y_se, ymax = y+y_se, fill = simulated), alpha = .5) +
    
    facet_grid(rows = vars(studyN), cols = vars(condition)) +
    labs(x = "Norm. Left - Right E[V]", y = "Pr(Choose Left)") +
    theme(
      legend.position = c(.1, .92),
      panel.spacing = unit(2, "lines")
    ) +
    scale_fill_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue"), labels = c("Observed", "Simulated")) +
    coord_cartesian(xlim=c(-1,1), ylim=c(0,1), expand=F) +
    scale_x_continuous(breaks=c(-1, 0, 1)) +
    scale_y_continuous(breaks=c(0, .5, 1))
  
  ggsave(file.path(.figdir, paste0("ProspectTheory_IndivOutSamplePredictions_", sID, ".pdf")), plt, width=figw*1.2, height=figh*1.2)
}
