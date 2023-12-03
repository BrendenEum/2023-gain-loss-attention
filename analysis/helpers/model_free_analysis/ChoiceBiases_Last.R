## Plot function

bias.lastfix.plt <- function(data, xlim) {

  pdata <- data[data$lastFix==T,] %>%
    group_by(subject, condition, location, vDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(condition, location, vDiff) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()

  plt <- ggplot(data=pdata, aes(x=vDiff, y=y, linetype=location)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Left - Right E[V]", linetype="Last Fixation", color="Condition") +
    theme(
      legend.position=c(0.1,0.75),
      legend.key.width=unit(1,"cm")
    ) +
    guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA))))


  return(plt)
}

## Regression function

bias.lastfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$lastFix==T,]
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, condition, location, vDiff) %>%
    summarize(n = sum(n),
              choice = sum(choice))

  results <- brm(
    choice | trials(n) ~ vDiff*condition*location + (1+vDiff*condition*location | subject),
    data=data,
    family = binomial(link="logit"),
    file = file.path(tempregdir, paste0(study, "_ChoiceBiases_Last_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.lastfix.e <- bias.lastfix.plt(cfr)
#reg.lastfix.e <- bias.lastfix.reg(cfr)

#plt.lastfix.e
#fixef(reg.lastfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]