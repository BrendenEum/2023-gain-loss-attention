## Plot function

fixprop.prfirst.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, ndifficulty) %>%
    summarize(
      firstbest.mean = mean(location==correctAnswer)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(firstbest.mean),
      se = std.error(firstbest.mean)
    ) %>%
    na.omit()

  plt <- ggplot(data=pdata[pdata$ndifficulty>0,], aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      linewidth=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), linewidth=linesize) +
    xlim(c(xlim[1], xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(First Fix. to Best)", x="Norm. Best - Worst E[V]", color="Condition", linetype="Study") +
    theme(
      legend.position = legendposition
    )

  return(plt)

}

## Regression function

fixprop.prfirst.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==1 & data$ndifficulty>0,]
  data$firstBest <- as.numeric(data$location==data$correctAnswer)
  
  results = glmer(
    firstBest ~ ndifficulty*relevel(condition,ref="Gain") + (1+ndifficulty*relevel(condition,ref="Gain") | subject),
    data = data,
    family = binomial
  ) %>% tidy(effects = "fixed", conf.int = T)
  
  fn = paste0("regression_output/", study, "_FixationProcess_FirstBest_", dataset, ".csv")
  write.csv(results, fn, row.names = FALSE)
  
  return(results)

}

######################
## Exploratory
######################

#plt.prfirst.e <- fixprop.prfirst.plt(cfr)
#reg.prfirst.e <- fixprop.prfirst.reg(cfr)

#plt.prfirst.e
#fixef(reg.prfirst.e)[,c('Estimate', 'Q2.5', 'Q97.5')]