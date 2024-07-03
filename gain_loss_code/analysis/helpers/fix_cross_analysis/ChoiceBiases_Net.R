fixCross.netfix.plt <- function(data, xlim) {

  breaks <- seq(-1625,1625,250)/1000
  labels <- seq(-1500,1500,250)/1000
  print(breaks)
  data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, net_fix) %>%
    summarize(
      choice.mean = mean(nchoice.corr, na.rm=T)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, net_fix) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()
  
  pdata <<- pdata

  plt <- ggplot(data=pdata, aes(x=net_fix, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)", color="Condition", linetype="Study") +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-0.41,0.41)) +
    theme_bw() +
    theme(
      legend.position = legendposition,
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))

  return(plt)

}

## Regression function

bias.netfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    nchoice.corr ~ net_fix*relevel(condition,ref="Gain") + (1+net_fix*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,.5), class=Intercept),
      prior(normal(0,.5), class=b)),
    file = file.path(tempregdir, paste0(study, "_ChoiceBiases_Net_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.netfix.e <- bias.netfix.plt(cfr)
#reg.netfix.e <- bias.netfix.reg(cfr)

#plt.netfix.e
#fixef(reg.netfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]