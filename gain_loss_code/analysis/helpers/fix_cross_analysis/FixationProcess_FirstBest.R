## Plot function

fixCross.prfirst.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      firstbest.mean = mean(location==correctAnswer)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      y = mean(firstbest.mean),
      se = std.error(firstbest.mean)
    ) %>%
    na.omit()

  plt <- ggplot(data=pdata[pdata$ndifficulty>0,], aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    xlim(c(xlim[1], xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(First Fix. to Best)", x="Norm. Best - Worst E[V]", color="Condition") +
    theme_bw() +
    theme(
      legend.position = legendposition,
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))

  return(plt)

}

## Regression function

fixprop.prfirst.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==1 & data$ndifficulty>0,]
  data$firstBest <- as.numeric(data$location==data$correctAnswer)
  #data <- data %>% mutate(n=1)
  #data <-  data %>%
  #  group_by(subject, condition, difficulty) %>%
  #  summarize(n = sum(n),
  #            firstBest = sum(firstBest))

  results <- brm(
    firstBest ~ difficulty*relevel(condition,ref="Gain") + (1+difficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,.5), class=Intercept),
      prior(normal(0,.5), class=b)),
    file = file.path(tempregdir, paste0(study, "_FixationProcess_FirstBest_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.prfirst.e <- fixprop.prfirst.plt(cfr)
#reg.prfirst.e <- fixprop.prfirst.reg(cfr)

#plt.prfirst.e
#fixef(reg.prfirst.e)[,c('Estimate', 'Q2.5', 'Q97.5')]