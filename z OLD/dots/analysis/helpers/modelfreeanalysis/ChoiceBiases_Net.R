bias.netfix.plt <- function(data) {

  breaks <- seq(-1050,1050,100)/1000
  labels <- seq(-1000,1000,100)/1000
  print(breaks)
  data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
    as.character() %>%
    as.numeric()

  pdata <- data[data$fix_type=="First",] %>%
    group_by(subject, Condition, net_fix) %>%
    summarize(
      choice.mean = mean(choice.corr)
    ) %>%
    ungroup() %>%
    group_by(Condition, net_fix) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    )


  plt <- ggplot(data=pdata, aes(x=net_fix, y=y, group=Condition)) +
    myPlot +
    geom_hline(yintercept=0, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
    xlim(c(-.5,.5)) +
    ylim(c(-0.4,0.4))

  return(plt)

}

## Regression function

bias.netfix.reg <- function(data) {

  data <- data[data$fix_type=="First",]

  results <- brm(
    choice.corr ~ net_fix*Condition + (1+net_fix*Condition | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempdir, "bias.netfix")
  )
  return(results)

}

######################
## Exploratory
######################

plt.netfix.e <- bias.netfix.plt(cfr)
#reg.netfix.e <- bias.netfix.reg(cfr)

plt.netfix.e
#fixef(reg.netfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]