## Plot function

psycho.choice.plt <- function(data) {

  pdata <- data[data$FirstFix==T,] %>%
    group_by(subject, Condition, vDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(Condition, vDiff) %>%
    summarize(
      y = mean(choice.mean, na.rm=T),
      se = std.error(choice.mean, na.rm=F)
    )

  plt <- ggplot(data=pdata, aes(x=vDiff, y=y, group=Condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(-4,4)) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Left - Right E[V]") +
    theme(
      legend.position=c(0.1,0.8)
    )


  return(plt)
}

## Regression function

psycho.choice.reg <- function(data) {

  # Convert to Binomial data
  data <- data[data$FirstFix==T,]
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, Condition, vDiff) %>%
    summarize(n = sum(n),
              choice = sum(choice))

  results <- brm(
    choice | trials(n) ~ vDiff*Condition + (1+vDiff*Condition | subject),
    data = data,
    family = binomial(link='logit'),
    file = file.path(tempdir, "psycho.choice")
  )

  return(results)

}

######################
## Exploratory
######################

## Choice probabilities

plt.choice.e <- psycho.choice.plt(cfr)
#reg.choice.e <- psycho.choice.reg(cfr)