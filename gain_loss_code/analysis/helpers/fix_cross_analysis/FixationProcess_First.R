## Plot function

fixCross.first.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(.3,.71)) +
    labs(y="First Fix. Duration (s)", x="Norm. Best - Worst E[V]") +
    theme_bw() +
    theme(
      legend.position = "none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixprop.first.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    fix_dur ~ difficulty*relevel(condition,ref="Gain") + (1+difficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,700), class=Intercept),
      prior(normal(0,100), class=b)),
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