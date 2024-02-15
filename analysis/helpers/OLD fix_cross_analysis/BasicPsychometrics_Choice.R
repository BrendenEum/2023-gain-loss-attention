## Plot function

fixCross.choice.plt <- function(data, xlim=c(-1,1)) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, nvDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, nvDiff) %>%
    summarize(
      y = mean(choice.mean, na.rm=T),
      se = std.error(choice.mean, na.rm=F)
    ) %>%
    na.omit()
  
  plt <- ggplot(data=pdata, aes(x=nvDiff, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Norm. Left - Right E[V]", color="Condition") +
    theme(
      legend.position=legendposition,
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

psycho.choice.reg <- function(data, study="error", dataset="error") {

  # Convert to Binomial data
  data <- data[data$firstFix==T,]
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, condition, vDiff) %>%
    summarize(
      n = sum(n),
      choice = sum(choice))

  results <- brm(
    choice | trials(n) ~ vDiff*relevel(condition,ref="Gain") + (1+vDiff*relevel(condition,ref="Gain") | subject),
    data = data,
    family = binomial(link='logit'),
    file = file.path(tempregdir, paste0(study, "_BasicPsychometrics_Choice_", dataset)))

  return(results)

}

######################
## Exploratory
######################

## Choice probabilities

#plt.choice.e <- psycho.choice.plt(ecfr)
#reg.choice.e <- psycho.choice.reg(cfr)