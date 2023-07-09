## Plot function

fixprop.first.plt <- function(data) {

  pdata <- data[data$FirstFix==T,] %>%
    group_by(subject, Condition, difficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(Condition, difficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y, group=Condition)) +
    myPlot +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(0,4)) +
    ylim(c(0,NA)) +
    labs(y="First Fix. Duration (s)", x="Best - Worst E[V]")


  return(plt)
}

## Regression function

fixprop.first.reg <- function(data) {

  data <- data[data$FirstFix==T,]

  results <- brm(
    fix_dur ~ difficulty*Condition + (1+difficulty*Condition | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,700), class=Intercept),
      prior(normal(0,100), class=b)
    ),
    file = file.path(tempdir, "fixprop.first")
  )
  return(results)

}

######################
## Exploratory
######################

plt.first.e <- fixprop.first.plt(cfr)
#reg.first.e <- fixprop.first.reg(cfr)

plt.first.e
#fixef(reg.first.e)[,c('Estimate', 'Q2.5', 'Q97.5')]