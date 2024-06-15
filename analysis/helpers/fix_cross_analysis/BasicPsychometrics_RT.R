## Plot function

fixCross.rt.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, ndifficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
    myPlot +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(1,4)) +
    labs(y="Response Time (s)", x="Norm. Best - Worst E[V]") +
    theme_bw() +
    theme(
      legend.position = "none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

psycho.rt.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    rt ~ difficulty*relevel(condition,ref="Gain") + (1+difficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_BasicPsychometrics_RT_", dataset)))

  return(results)

}

######################
## Exploratory
######################

#plt.rt.e <- psycho.rt.plt(cfr)
#reg.rt.e <- psycho.rt.reg(cfr)

#plt.rt.e
#fixef(reg.rt.e)[,c('Estimate', 'Q2.5', 'Q97.5')]