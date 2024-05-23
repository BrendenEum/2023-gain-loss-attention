# See https://www.thegreatstatsby.com/posts/2021-03-08-ml-prospect/#the-choices for a great tutorial!

####################################
# Preamble
####################################

library(tidyverse)
library(furrr) # parallelization of map functions from purrr, i.e. parallelize optimization
library(patchwork)
source("../plot_options/GainLossColorPalette.R")
source("../plot_options/MyPlotOptions.R")
source("../plot_options/SE.R")

print(RDRule)


####################################
# cfr should already be loaded through FitAndPlotRefDeptModels.R
####################################

data = cfr[cfr$firstFix==T & cfr$trial%%2==1, ] # Only one observation per trial and only in-sample trials!
outsample = cfr[cfr$firstFix==T & cfr$trial%%2==0, ] # Out-of-sample data


####################################
# Functions for Prospect Theory
####################################

# Calculate subjective utility given lambda/rho.
# Takes a vector of values and parameters and returns subjective utilities.
calc_subjective_utility <- function(vals, refs, lambda, rho) {
  ifelse((vals-refs) >= 0, (vals-refs)^rho, -lambda * ((-(vals-refs))^rho))
}

# Calculate reweighted probability according to Prelec 1998..
calc_prelec_prob <- function(prob, gamma) {
  exp(-(-log(prob))^gamma)
}

# Calculate utility difference from vectors of gains, losses, and certainty.
calc_utility_diff <- function(L1_su, L2_su, L1_wp, L2_wp, R1_su, R2_su, R1_wp, R2_wp) {
  (L1_wp*L1_su + L2_wp*L2_su) - (R1_wp*R1_su + R2_wp*R2_su)
}

# Calculate the probability of accepting a gamble, given a difference in subjective utility and temperature.
calc_prob_L <- function(utility_diff, temperature_G, temperature_L, loss_id_var) {
  temperature = abs(loss_id_var - 1) * temperature_G + loss_id_var * temperature_L
  return( (1 + exp(-temperature * (utility_diff)))^-1 )
}


####################################
# NLL function we will optimize over
####################################

minimize_LL_prospect <- function(df, par) {
  lambda_par <- 1
  rho_par <- par[1]
  temperature_G_par <- par[2]
  temperature_L_par <- par[3]
  gamma_par <- par[4]
  df_updated = df %>%
    mutate(
      L1_su = calc_subjective_utility(LAmt, LRef, lambda_par, rho_par),
      L2_su = calc_subjective_utility(0, LRef, lambda_par, rho_par),
      R1_su = calc_subjective_utility(RAmt, RRef, lambda_par, rho_par),
      R2_su = calc_subjective_utility(0, RRef, lambda_par, rho_par),
      L1_wp = calc_prelec_prob(LProb, gamma_par),
      L2_wp = calc_prelec_prob(1-LProb, gamma_par),
      R1_wp = calc_prelec_prob(RProb, gamma_par),
      R2_wp = calc_prelec_prob(1-RProb, gamma_par),
      utility_diff = calc_utility_diff(L1_su, L2_su, L1_wp, L2_wp, R1_su, R2_su, R1_wp, R2_wp),
      loss_id = (LAmt<0),
      prob_choose_L = calc_prob_L(utility_diff, temperature_G_par, temperature_L_par, loss_id),
      prob_choose_L_rc = case_when(
        prob_choose_L == 1 ~ 1-.Machine$double.eps,
        prob_choose_L == 0 ~ 0+.Machine$double.eps,
        TRUE ~ prob_choose_L
      ),
      log_likelihood_trial = choice * log(prob_choose_L_rc) + (1-choice) * log(1-prob_choose_L_rc)
    )
  
  -sum(df_updated$log_likelihood_trial)
}


####################################
# Create nested data
####################################

.data_nested = data %>%
  nest(data = -c(studyN, subject, condition))


####################################
# Optimize over nested data with 4 different starting points (computationally heavy, but parallelized)
####################################

future::plan(multisession, workers = 4)

# lambda, rho, temperature_G, temperature_L, gamma
# Stillman has lambda range from 0 to 20. Baillon has lambdas ranging from 0 to ~37.
# Stillman and Baillon have rho's ranging from 0 to just over 2.
# Stillman has temperatures from 0 to 20, with some bunching at 20. Baillon has temperatures upwards of 35.
# I think Prelec prob reweighting should be bounded above by 1. Gonzalez and Wu (1999) found gamma between .55 and .95.
lower_bounds = c(.01, .01, .01, .01)
upper_bounds = c(4, 30, 30, 1)

.data_optim_quad <- .data_nested %>%
  mutate(optim_out_1 = future_map(data, ~ optim(par = c(.83, 2.57, 2.57, 1), # Sokol-Hessner et al. 2009 means
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = lower_bounds,
                                                upper = upper_bounds)),
         optim_out_2 = future_map(data, ~ optim(par = c(.91, 3.15, 3.15, 1), # Stillman et al. 2020 means
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = lower_bounds,
                                                upper = upper_bounds)),
         optim_out_3 = future_map(data, ~ optim(par = c(.47, .9, .05, .53), # Toubia et al. 2013 means (lambda, sigma, delta, delta)
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = lower_bounds,
                                                upper = upper_bounds)),
         optim_out_4 = future_map(data, ~ optim(par = c(.44, 10.89, 10.89, .43), # Baillon et al. 2020 medians
                                                fn = minimize_LL_prospect,
                                                df = .,
                                                method = 'L-BFGS-B',
                                                lower = lower_bounds,
                                                upper = upper_bounds)))


####################################
# Compare results across different starting points and store the best
####################################

evaluate_model <- function(model_list) {
  
  names(model_list) <- str_c('m', 1:length(model_list))
  models_tibble <<- as_tibble(model_list)
  
  convergence_mat <<- models_tibble %>% 
    summarise(across(everything(), ~ map_dbl(., 'convergence'))) # convergence 
  ll_mat <<- models_tibble %>% 
    summarise(across(everything(), ~ map_dbl(., 'value'))) # log likelihood
  
  ll_mat[convergence_mat != 0] <<- NA # set LL of non-converging models to be NA
  lowest_likelihood <<- apply(ll_mat, 1, which.min) # choose the minimum LL from each row
  
  index_mat <<- matrix(c(1:nrow(models_tibble), lowest_likelihood), ncol = 2, byrow=FALSE)
  return(as.matrix(models_tibble)[index_mat]) # for each row, return the optim output that had minimum LL
}

data_optim_quad_pars <- .data_optim_quad %>% 
  mutate(best_model = evaluate_model(list(optim_out_1, optim_out_2, optim_out_3, optim_out_4)),
         convergence = map_dbl(best_model, 'convergence'),
         NLL = map_dbl(best_model, 'value'),
         pars = map(best_model, 'par'),
         lambda = 1,
         rho = map_dbl(pars, ~ .[1]),
         temperature_G = map_dbl(pars, ~ .[2]),
         temperature_L = map_dbl(pars, ~ .[3]),
         gamma = map_dbl(pars, ~ .[4]))

if (sum(data_optim_quad_pars$convergence)>0) {warning("OPTIM DIDNT CONVERGE FOR AT LEAST ONE SUBJECT-CONDITION!")}


####################################
# Plot individual Estimates
####################################

.hist_lambda <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = lambda)) +
  myPlot +
  geom_histogram() +
  geom_vline(xintercept = 1, color="red", linewidth=1.5) +
  labs(title = 'loss aversion') +
  coord_cartesian(expand = T)
.hist_rho <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = rho)) +
  myPlot +
  geom_histogram() +
  labs(title = 'diminishing marginal returns') +
  coord_cartesian(expand = T)
.hist_temperature_G <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = temperature_G)) +
  myPlot +
  geom_histogram() +
  labs(title = 'temperature gain') +
  coord_cartesian(expand = T)
.hist_temperature_L <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = temperature_L)) +
  myPlot +
  geom_histogram() +
  labs(title = 'temperature loss') +
  coord_cartesian(expand = T)
.hist_gamma <- data_optim_quad_pars %>% 
  filter(convergence == 0) %>% 
  ggplot(aes(x = gamma)) +
  myPlot +
  geom_histogram() +
  labs(title = 'probability weighting') +
  coord_cartesian(expand = T)

.plt = .hist_lambda + .hist_rho + .hist_temperature_G + .hist_temperature_L + .hist_gamma
.fn = paste0("ProspectTheory_", RDRule, "_IndividualEstimates.pdf")
ggsave(file.path(.figdir, .fn), .plt, width=figw*1.75, height=figh*1.75)


####################################
# Group-Level Out-of-Sample Predictions
####################################

.pdataA = merge(
  outsample, 
  data_optim_quad_pars[,c("studyN", "subject", "condition", "lambda", "rho", "temperature_G", "temperature_L", "gamma")], 
  by=c("studyN", "subject", "condition")
)

.pdataA = .pdataA %>%
  mutate(
    loss_id = (LAmt < 0), 
    L1_su = calc_subjective_utility(LAmt, LRef, lambda, rho),
    L2_su = calc_subjective_utility(0, LRef, lambda, rho),
    R1_su = calc_subjective_utility(RAmt, RRef, lambda, rho),
    R2_su = calc_subjective_utility(0, RRef, lambda, rho),
    L1_wp = calc_prelec_prob(LProb, gamma),
    L2_wp = calc_prelec_prob(1-LProb, gamma),
    R1_wp = calc_prelec_prob(RProb, gamma),
    R2_wp = calc_prelec_prob(1-RProb, gamma),
    L_RDVal = L1_su * L1_wp + L2_su * L2_wp,
    R_RDVal = R1_su * R1_wp + R2_su * R2_wp,
    LR_diff = calc_utility_diff(L1_su, L2_su, L1_wp, L2_wp, R1_su, R2_su, R1_wp, R2_wp),
    pred_choice = calc_prob_L(LR_diff, temperature_G, temperature_L, loss_id)
  )
.pdataGroup = .pdataA
.pdataA = .pdataA %>%
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
.pdataB = .pdataA %>% mutate(y = yhat, y_se = yhat_se, simulated = 1)
.pdata = rbind(.pdataA, .pdataB)
.pdata$simulated = factor(.pdata$simulated, levels = c(0,1), labels = c("Observed", "Simulated"))
.pdata$studyN = factor(.pdata$studyN, levels = c(1,2), labels = c("Study 1", "Study 2"))

.plt = ggplot(data = .pdata, aes(x = nvDiff, y = y)) +
  myPlot +
  
  geom_line(aes(color=simulated), linewidth=linewidth, show.legend = T) +
  geom_ribbon(aes(ymin = y-y_se, ymax = y+y_se, fill = simulated), alpha = .5) +
  
  facet_grid(rows = vars(studyN), cols = vars(condition)) +
  labs(x = "Norm. Left - Right E[V]", y = "Pr(Choose Left)") +
  theme(
    legend.position = c(.1, .92),
    panel.spacing = unit(2, "lines")
  ) +
  scale_color_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue")) +
  scale_fill_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue"), labels = c("Observed", "Simulated")) +
  coord_cartesian(xlim=c(-1,1), ylim=c(0,1), expand=F) +
  scale_x_continuous(breaks=c(-1, 0, 1)) +
  scale_y_continuous(breaks=c(0, .5, 1))

.fn = paste0("ProspectTheory_", RDRule, "_GroupOutSamplePredictions.pdf")
ggsave(file.path(.figdir, .fn), .plt, width=figw*1.2, height=figh*1.2)


####################################
# Individual-Level Out-of-Sample Predictions
####################################

set.seed(4)
.study1subjects = sample(unique(outsample$subject[outsample$studyN==1]), 4)
.study2subjects = sample(unique(outsample$subject[outsample$studyN==2]), 4)

.pdataA = .pdataGroup[.pdataGroup$subject %in% c(.study1subjects, .study2subjects),] %>%
  select("studyN", "subject", "condition", "choice", "pred_choice", "nvDiff") %>%
  group_by(studyN, subject, condition, nvDiff) %>%
  summarize(
    y = mean(choice),
    y_se = SE(choice),
    yhat = mean(pred_choice),
    yhat_se = SE(pred_choice),
    simulated = 0
  )
.pdataB = .pdataA %>% mutate(y = yhat, y_se = yhat_se, simulated = 1)
.pdataFull = rbind(.pdataA, .pdataB)
.pdataFull$simulated = factor(.pdataFull$simulated, levels = c(0,1), labels = c("Observed", "Simulated"))
.pdataFull$studyN = factor(.pdataFull$studyN, levels = c(1,2), labels = c("Study 1", "Study 2"))
.pdataFull[is.na(.pdataFull)] = 0

for (sID in c(.study1subjects, .study2subjects)) {
  .pdata = .pdataFull[.pdataFull$subject==sID, ]
  
  .plt = ggplot(data = .pdata, aes(x = nvDiff, y = y)) +
    myPlot +
    
    geom_line(aes(color=simulated), linewidth=linewidth, show.legend = F) +
    geom_ribbon(aes(ymin = y-y_se, ymax = y+y_se, fill = simulated), alpha = .5) +
    
    facet_grid(rows = vars(studyN), cols = vars(condition)) +
    labs(x = "Norm. Left - Right E[V]", y = "Pr(Choose Left)") +
    theme(
      legend.position = c(.1, .92),
      panel.spacing = unit(2, "lines")
    ) +
    scale_color_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue")) +
    scale_fill_manual(name = "", values=c("Observed" = "grey", "Simulated" = "dodgerblue"), labels = c("Observed", "Simulated")) +
    coord_cartesian(xlim=c(-1,1), ylim=c(0,1), expand=F) +
    scale_x_continuous(breaks=c(-1, 0, 1)) +
    scale_y_continuous(breaks=c(0, .5, 1))
  
  .fn = paste0("ProspectTheory_", RDRule, "_IndivOutSamplePredictions_", sID, ".pdf")
  ggsave(file.path(.figdir, .fn), .plt, width=figw*1.2, height=figh*1.2)
}


####################################
# Save RDValues for aDDM Fitting
####################################

.cfr = merge(
  cfr[cfr$firstFix==T,], 
  data_optim_quad_pars[,c("studyN", "subject", "condition", "lambda", "rho", "temperature_G", "temperature_L", "gamma")], 
  by=c("studyN", "subject", "condition")
)

.cfr = .cfr %>%
  mutate(
    loss_id = (LAmt < 0), 
    L1_su = calc_subjective_utility(LAmt, LRef, lambda, rho),
    L2_su = calc_subjective_utility(0, LRef, lambda, rho),
    R1_su = calc_subjective_utility(RAmt, RRef, lambda, rho),
    R2_su = calc_subjective_utility(0, RRef, lambda, rho),
    L1_wp = calc_prelec_prob(LProb, gamma),
    L2_wp = calc_prelec_prob(1-LProb, gamma),
    R1_wp = calc_prelec_prob(RProb, gamma),
    R2_wp = calc_prelec_prob(1-RProb, gamma),
    L_RDVal = L1_su * L1_wp + L2_su * L2_wp,
    R_RDVal = R1_su * R1_wp + R2_su * R2_wp,
    LR_diff = calc_utility_diff(L1_su, L2_su, L1_wp, L2_wp, R1_su, R2_su, R1_wp, R2_wp),
    pred_choice = calc_prob_L(LR_diff, temperature_G, temperature_L, loss_id)
  )
RDValues = .cfr[,c("studyN", "subject", "trial", "condition", "L_RDVal", "R_RDVal",
                   "L1_su", "L1_wp", "L2_su", "L2_wp", "R1_su", "R1_wp", "R2_su", "R2_wp",
                   "lambda", "rho", "temperature_G", "temperature_L", "gamma")]