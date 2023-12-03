## Plot function

fixprop.first.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(subject, condition, difficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(condition, difficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y)) +
    myPlot +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,NA)) +
    labs(y="First Fix. Duration (s)", x="Best - Worst E[V]", color="Condition")


  return(plt)
}

## Regression function

fixprop.first.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    fix_dur ~ difficulty*condition + (1+difficulty*condition | subject),
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