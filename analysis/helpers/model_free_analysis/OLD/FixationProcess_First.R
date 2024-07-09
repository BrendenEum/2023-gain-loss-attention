round_to_nearest_quarter <- function(x) {
  round(x * 4) / 4
}

## Plot function

fixprop.first.plt <- function(data, xlim) {
  
  data$nfixValue = round_to_nearest_quarter(data$nfixValue)

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, nfixValue) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, nfixValue) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=nfixValue, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0.0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      linewidth=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), linewidth=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(.3,.8)) +
    labs(y="First Fix. Duration (s)", x="Norm. First E[V]", color="Condition", linetype="Study")


  return(plt)
}

## Regression function

fixprop.first.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]
  
  priors <- c(
    set_prior("normal(0, 0.5)", class = "Intercept"), 
    set_prior("normal(0, 0.1)", class = "b", coef = "zndifficulty"),  
    set_prior("normal(0, 0.1)", class = "b", coef = "relevelconditionrefEQGainLoss"), 
    set_prior("normal(0, 0.1)", class = "b", coef = "zndifficulty:relevelconditionrefEQGainLoss")  
  )
  
  data$zndifficulty = scale(data$ndifficulty)

  results <- my_brm(
    fix_dur ~ zndifficulty*relevel(condition,ref="Gain") + (1+zndifficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    prior = priors,
    file = file.path(tempregdir, paste0(study, "_FixationProcess_First_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.first.e <- fixprop.first.plt(cfr)
#reg.first.e <- fixprop.first.reg(cfr)

#plt.first.e
#fixef(reg.first.e)[,c('Estimate', 'Q2.5', 'Q97.5')]