fixCross.firstfix.plt <- function(data, xlim) {

  breaks <- seq(-50,1250,100)/1000
  labels <- seq(0,1200,100)/1000
  data$fix_dur <- cut(data$fix_dur, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data[data$firstFix==T,] %>%
    group_by(subject, condition, fixCrossLoc, fix_dur) %>%
    summarize(
      corrFirst.mean = mean(firstSeenChosen.corr)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLoc, fix_dur) %>%
    summarize(
      y = mean(corrFirst.mean),
      se = std.error(corrFirst.mean)
    ) %>%
    na.omit()

  plt <- ggplot(data=pdata, aes(x=fix_dur, y=y)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    labs(y="Corr. Pr(First Seen Chosen)", x="First Fixation Duration (s)")+
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(-0.5,0.5)) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixCross.firstfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,] 
  # %>%
  #   group_by(subject, condition, vDiff) %>%
  #   mutate(
  #     firstSeenChosen.corr = firstSeenChosen - mean(firstSeenChosen),
  #   )

  results <- brm(
    firstSeenChosen.corr ~ fix_dur*condition*fixCrossLoc + (1+fix_dur*condition*fixCrossLoc | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_FixCross_ChoiceBiases_First_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.firstfix.e <- bias.firstfix.plt(cfr)
#reg.firstfix.e <- bias.firstfix.reg(cfr)

#plt.firstfix.e
#fixef(reg.firstfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]