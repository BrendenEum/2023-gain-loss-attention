## Plot function

fixCross.net.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, nvDiff) %>%
    summarize(
      net.mean = mean(net_fix, na.rm=T)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, nvDiff) %>%
    summarize(
      y = mean(net.mean, na.rm=T),
      se = std.error(net.mean, na.rm=T)
    )

  plt <- ggplot(data=pdata, aes(x=nvDiff, y=y, color=condition)) +
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
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-.75,.75)) +
    labs(y="Net Fix. Duration (L-R, s)", x="Norm. Left - Right E[V]") +
    theme_bw() +
    theme(
      legend.position = "none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixprop.net.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    net_fix ~ vDiff*relevel(condition,ref="Gain") + (1+vDiff*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_FixationProcess_Net_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.net.e <- fixprop.net.plt(cfr)
#reg.net.e <- fixprop.net.reg(cfr)

#plt.net.e
#fixef(reg.net.e)[,c('Estimate', 'Q2.5', 'Q97.5')]