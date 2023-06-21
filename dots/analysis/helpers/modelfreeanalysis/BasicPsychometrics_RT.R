## Plot function

psycho.rt.plt <- function(data) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, Condition, difficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(Condition, difficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y, group=Condition)) +
    myPlot +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(0,1)) +
    ylim(c(0,NA)) +
    labs(y="Response Time (s)", x="Best - Worst E[V]")


  return(plt)
}

## Regression function

psycho.rt.reg <- function(data) {

  data <- data[data$fix_type=="First",]

  results <- brm(
    rt ~ difficulty*Condition + (1+difficulty*Condition | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempdir, "psycho.rt")
  )

  return(results)

}

######################
## Exploratory
######################

plt.rt.e <- psycho.rt.plt(cfr)
#reg.rt.e <- psycho.rt.reg(cfr)

plt.rt.e
#fixef(reg.rt.e)[,c('Estimate', 'Q2.5', 'Q97.5')]