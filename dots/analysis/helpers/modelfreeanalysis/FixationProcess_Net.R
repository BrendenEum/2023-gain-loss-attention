## Plot function

fixprop.net.plt <- function(data) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, Condition, vDiff) %>%
    summarize(
      net.mean = mean(net_fix)
    ) %>%
    ungroup() %>%
    group_by(Condition, vDiff) %>%
    summarize(
      y = mean(net.mean),
      se = std.error(net.mean)
    )

  plt <- ggplot(data=pdata, aes(x=vDiff, y=y, group=Condition)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(-1,1)) +
    ylim(c(-.4,.4)) +
    labs(y="Net Fix. Duration (L-R, s)", x="Left - Right E[V]")


  return(plt)
}

## Regression function

fixprop.net.reg <- function(data) {

  data <- data[data$fix_type=="First",]

  results <- brm(
    net_fix ~ vDiff*Condition + (1+vDiff*Condition | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,1000), class=b)
    ),
    file = file.path(tempdir, "fixprop.net")
  )
  return(results)

}

######################
## Exploratory
######################

plt.net.e <- fixprop.net.plt(cfr)
#reg.net.e <- fixprop.net.reg(cfr)

plt.net.e
#fixef(reg.net.e)[,c('Estimate', 'Q2.5', 'Q97.5')]