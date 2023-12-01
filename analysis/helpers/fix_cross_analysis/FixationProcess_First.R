## Plot function

fixCross.first.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, condition, fixCrossLoc, difficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLocdifficulty) %>%
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
    labs(y="First Fix. Duration (s)", x="Best - Worst E[V]", color="Condition") +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixCross.first.reg <- function(data, study="error", dataset="error") {

  data <- data[data$fix_type=="First",]

  results <- brm(
    fix_dur ~ difficulty*condition*fixCrossLoc + (1+difficulty*condition*fixCrossLoc | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,700), class=Intercept),
      prior(normal(0,100), class=b)),
    file = file.path(tempregdir, paste0(study, "_FixCross_FixationProcess_First_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.first.e <- fixprop.first.plt(cfr)
#reg.first.e <- fixprop.first.reg(cfr)

#plt.first.e
#fixef(reg.first.e)[,c('Estimate', 'Q2.5', 'Q97.5')]