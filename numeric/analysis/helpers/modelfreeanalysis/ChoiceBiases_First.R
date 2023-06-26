bias.firstfix.plt <- function(data) {

  breaks <- seq(-50,1250,100)/1000
  labels <- seq(0,1200,100)/1000
  data$fix_dur <- cut(data$fix_dur, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, Condition, vDiff) %>%
    mutate(
      firstSeenChosen.corr = firstSeenChosen - mean(firstSeenChosen),
    ) %>%
    ungroup() %>%
    group_by(subject, Condition, fix_dur) %>%
    summarize(
      corrFirst.mean = mean(firstSeenChosen.corr)
    ) %>%
    ungroup() %>%
    group_by(Condition, fix_dur) %>%
    summarize(
      y = mean(corrFirst.mean),
      se = std.error(corrFirst.mean)
    )

  plt <- ggplot(data=pdata, aes(x=fix_dur, y=y, group=Condition)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    labs(y="Corr. Pr(First Seen Chosen)", x="First Fixation Duration (s)")+
    xlim(c(0,1.2)) +
    ylim(c(-0.4,0.4))


  return(plt)
}

## Regression function

bias.firstfix.reg <- function(data) {

  data <- data[data$fix_type=="First",] %>%
    group_by(subject, Condition, vDiff) %>%
    mutate(
      firstSeenChosen.corr = firstSeenChosen - mean(firstSeenChosen),
    )

  results <- brm(
    firstSeenChosen.corr ~ fix_dur*Condition + (1+fix_dur*Condition | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempdir, "bias.firstfix")
  )
  return(results)

}

######################
## Exploratory
######################

plt.firstfix.e <- bias.firstfix.plt(cfr)
#reg.firstfix.e <- bias.firstfix.reg(cfr)

plt.firstfix.e
#fixef(reg.firstfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]