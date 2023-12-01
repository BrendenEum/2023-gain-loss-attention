## Plot function

fixCross.rt.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, condition, fixCrossLoc, difficulty) %>%
    summarize(
      rt.mean = mean(rt)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLoc, difficulty) %>%
    summarize(
      y = mean(rt.mean),
      se = std.error(rt.mean)
    ) %>%
    na.omit()

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y)) +
    myPlot +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,NA)) +
    labs(y="Response Time (s)", x="Best - Worst E[V]") +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixCross.rt.reg <- function(data, study="error", dataset="error") {

  data <- data[data$fix_type=="First",]

  results <- brm(
    rt ~ difficulty*condition*fixCrossLoc + (1+difficulty*condition*fixCrossLoc | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_FixCross_BasicPsychometrics_RT_", dataset)))

  return(results)

}

######################
## Exploratory
######################

#plt.rt.e <- psycho.rt.plt(cfr)
#reg.rt.e <- psycho.rt.reg(cfr)

#plt.rt.e
#fixef(reg.rt.e)[,c('Estimate', 'Q2.5', 'Q97.5')]