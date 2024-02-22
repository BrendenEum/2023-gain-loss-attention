## Plot function

sim.rt.plt <- function(data, xlim) {

  pdata <- data %>%
    group_by(simulated, studyN, subject, condition, ndifficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(simulated, studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition, alpha=simulated)) +
    myPlot +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=simulated), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,12)) +
    labs(y="Response Time (s)", x="Norm. Best - Worst E[V]") +
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