## Plot function

fixCross.choice.plt <- function(data, xlim=c(-1,1)) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(subject, condition, fixCrossLoc, vDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(condition, fixCrossLoc, vDiff) %>%
    summarize(
      y = mean(choice.mean, na.rm=T),
      se = std.error(choice.mean, na.rm=F)
    ) %>%
    na.omit()
  
  plt <- ggplot(data=pdata, aes(x=vDiff, y=y)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Left - Right E[V]", color="Condition") +
    theme(
      legend.position=c(0.1,0.8)
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

fixCross.choice.reg <- function(data, study="error", dataset="error") {

  # Convert to Binomial data
  data <- data[data$firstFix==T,]
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, condition, fixCrossLoc, vDiff) %>%
    summarize(
      n = sum(n),
      choice = sum(choice))

  results <- brm(
    choice | trials(n) ~ vDiff*condition*fixCrossLoc + (1+vDiff*condition*fixCrossLoc | subject),
    data = data,
    family = binomial(link='logit'),
    file = file.path(tempregdir, paste0(study, "_FixCross_BasicPsychometrics_Choice_", dataset)))

  return(results)

}

######################
## Exploratory
######################

## Choice probabilities

#plt.choice.e <- psycho.choice.plt(ecfr)
#reg.choice.e <- psycho.choice.reg(cfr)