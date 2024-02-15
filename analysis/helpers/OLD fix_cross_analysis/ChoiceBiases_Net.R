fixCross.netfix.plt <- function(data, xlim) {

  breaks <- seq(-1625,1625,250)/1000
  labels <- seq(-1500,1500,250)/1000
  print(breaks)
  data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data[data$firstFix==T,] %>%
    group_by(subject, condition, fixCrossLoc, net_fix) %>%
    summarize(
      choice.mean = mean(choice.corr, na.rm=T)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLoc, net_fix) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()


  plt <- ggplot(data=pdata, aes(x=net_fix, y=y)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-0.41,0.41)) +
    facet_grid(cols = vars(fixCrossLoc))

  return(plt)

}

## Regression function

fixCross.netfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]

  results <- brm(
    choice.corr ~ net_fix*condition*fixCrossLoc + (1+net_fix*condition*fixCrossLoc | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_FixCross_ChoiceBiases_Net_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.netfix.e <- bias.netfix.plt(cfr)
#reg.netfix.e <- bias.netfix.reg(cfr)

#plt.netfix.e
#fixef(reg.netfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]