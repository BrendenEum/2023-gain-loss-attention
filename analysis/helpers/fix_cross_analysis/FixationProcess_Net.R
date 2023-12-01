## Plot function

fixCross.net.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, condition, fixCrossLoc, vDiff) %>%
    summarize(
      net.mean = mean(net_fix, na.rm=T)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLoc, vDiff) %>%
    summarize(
      y = mean(net.mean, na.rm=T),
      se = std.error(net.mean, na.rm=T)
    )

  plt <- ggplot(data=pdata, aes(x=vDiff, y=y, group=condition)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-.5,.5)) +
    labs(y="Net Fix. Duration (L-R, s)", x="Left - Right E[V]") +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixCross.net.reg <- function(data, study="error", dataset="error") {

  data <- data[data$fix_type=="First",]

  results <- brm(
    net_fix ~ vDiff*condition*fixCrossLoc + (1+vDiff*condition*fixCrossLoc | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,1000), class=b)),
    file = file.path(tempregdir, paste0(study, "_FixCross_FixationProcess_Net_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.net.e <- fixprop.net.plt(cfr)
#reg.net.e <- fixprop.net.reg(cfr)

#plt.net.e
#fixef(reg.net.e)[,c('Estimate', 'Q2.5', 'Q97.5')]