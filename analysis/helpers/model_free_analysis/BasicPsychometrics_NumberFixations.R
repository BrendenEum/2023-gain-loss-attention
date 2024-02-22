## Plot function

psycho.numfix.plt <- function(data, xlim) {

  pdata <- data[data$lastFix==T,] %>%
    group_by(studyN, subject, condition, ndifficulty) %>%
    summarize(
      fix_num.mean = mean(fix_num)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(fix_num.mean),
      se = std.error(fix_num.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(2,NA)) +
    labs(y="Number of Fixations", x="Norm. Best - Worst E[V]")


  return(plt)

}

## Regression function

psycho.numfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$lastFix==T,]

  results <- brm(
    fix_num ~ ndifficulty*relevel(condition,ref="Gain") + (1+ndifficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_BasicPsychometrics_NumberFixations_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.numfix.e <- psycho.numfix.plt(cfr)
#reg.numfix.e <- psycho.numfix.reg(cfr)

#plt.numfix.e
#fixef(reg.numfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]