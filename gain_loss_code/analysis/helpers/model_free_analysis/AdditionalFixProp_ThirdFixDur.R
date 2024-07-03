## Plot function

addfixprop.third.plt <- function(data, xlim) {

  pdata <- data[data$fix_num==3,] %>%
    group_by(studyN, subject, condition, ndifficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.6, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      linewidth=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), linewidth=linesize) +
    coord_cartesian(xlim=c(xlim[1],xlim[2]), ylim=c(.3, .9), expand=F) +
    labs(y="Third Fix. Duration (s)", x="Norm. Best - Worst E[V]", color="Condition", linetype="Study")


  return(plt)
}

## Regression function

addfixprop.third.reg <- function(data, study="error", dataset="error") {

  data <- data[data$fix_num==3,]
  
  priors <- c(
    set_prior("normal(0, 1.0)", class = "Intercept"), 
    set_prior("normal(0, 0.5)", class = "b", coef = "zndifficulty"),  
    set_prior("normal(0, 0.1)", class = "b", coef = "relevelconditionrefEQGainLoss"), 
    set_prior("normal(0, 0.1)", class = "b", coef = "zndifficulty:relevelconditionrefEQGainLoss")  
  )
  
  data$zndifficulty = scale(data$ndifficulty)

  results <- my_brm(
    fix_dur ~ zndifficulty*relevel(condition,ref="Gain") + (1+zndifficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    prior = priors,
    file = file.path(tempregdir, paste0(study, "_AdditionalFixProp_ThirdFixDur_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.first.e <- fixprop.first.plt(cfr)
#reg.first.e <- fixprop.first.reg(cfr)

#plt.first.e
#fixef(reg.first.e)[,c('Estimate', 'Q2.5', 'Q97.5')]