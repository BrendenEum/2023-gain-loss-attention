## Plot function

psycho.rt.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, ndifficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      linewidth=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), linewidth=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(1,4)) +
    labs(y="Response Time (s)", x="Norm. Best - Worst E[V]")


  return(plt)
}

## Regression function

psycho.rt.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]
  
  results = lmer(
    rt ~ ndifficulty*relevel(condition,ref="Gain") + (1+ndifficulty*relevel(condition,ref="Gain") | subject),
    data = data,
  ) %>% tidy(effects = "fixed", conf.int = T)
  
  fn = paste0("regression_output/", study, "_BasicPsychometrics_RT_", dataset, ".csv")
  write.csv(results, fn, row.names = FALSE)

  return(results)

}

######################
## Exploratory
######################

#plt.rt.e <- psycho.rt.plt(cfr)
#reg.rt.e <- psycho.rt.reg(cfr)

#plt.rt.e
#fixef(reg.rt.e)[,c('Estimate', 'Q2.5', 'Q97.5')]