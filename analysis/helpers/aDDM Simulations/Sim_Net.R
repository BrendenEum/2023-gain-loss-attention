sim.netfix.plt <- function(data, xlim) {

  breaks <- seq(-1.625,1.625,.250)
  labels <- seq(-1.500,1.500,.250)
  print(breaks)
  data$net_fix <- cut(data$netFixLeft, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data %>%
    group_by(simulated, studyN, subject, nvDiff) %>%
    mutate(
      nchoice.corr = choice - mean(choice),
    ) %>%
    group_by(simulated, studyN, subject, condition, net_fix) %>%
    summarize(
      choice.mean = mean(nchoice.corr, na.rm=T)
    ) %>%
    ungroup() %>%
    group_by(simulated, studyN, condition, net_fix) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()
  
  pdata <<- pdata

  plt <- ggplot(data=pdata, aes(x=net_fix, y=y, color=condition, alpha=simulated)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=simulated), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-0.41,0.41)) +
    labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
    scale_alpha_discrete(range = c(0.25, 1.0)) +
    theme(
      legend.position="none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(rows = vars(studyN)) +
    theme(
      strip.background = element_blank(),
      strip.text.y = element_blank()
    )

  return(plt)

}
