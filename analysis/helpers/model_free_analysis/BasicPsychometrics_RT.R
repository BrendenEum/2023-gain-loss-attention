## Plot function

psycho.rt.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, condition, difficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(condition, difficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y)) +
    myPlot +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,NA)) +
    labs(y="Response Time (s)", x="Best - Worst E[V]")


  return(plt)
}

## Regression function

psycho.rt.reg <- function(data, study="error", dataset="error") {

  data <- data[data$fix_type=="First",]

  results <- brm(
    rt ~ difficulty*condition + (1+difficulty*condition | subject),
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