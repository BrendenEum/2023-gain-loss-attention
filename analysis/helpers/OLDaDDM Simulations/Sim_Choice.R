## Plot function

sim.choice.plt <- function(data, xlim=c(-1,1), legendposition="none") {

  pdata <- data %>%
    group_by(simulated, studyN, subject, condition, nvDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(simulated, studyN, condition, nvDiff) %>%
    summarize(
      y = mean(choice.mean, na.rm=T),
      se = std.error(choice.mean, na.rm=F)
    ) %>%
    na.omit()
  
  plt <- ggplot(data=pdata, aes(x=nvDiff, y=y, color=condition, alpha=simulated)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se),
      size=errsize,
      position=position_jitter(width=.01, seed=4),
      show.legend=F
    ) +
    geom_line(aes(linetype=simulated), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Norm. Left - Right E[V]") +
    scale_alpha_discrete(range = c(0.25, 1.0)) +
    theme(
      legend.position=,
      legend.title=element_blank(),
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(rows = vars(studyN)) +
    theme(
      strip.background = element_blank(),
      strip.text.y = element_blank()
    )


  return(plt)
}