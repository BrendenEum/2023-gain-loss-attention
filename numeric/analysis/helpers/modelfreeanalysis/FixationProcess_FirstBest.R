## Plot function

fixprop.prfirst.plt <- function(data) {

  pdata <- data[data$FirstFix==T,] %>%
    group_by(subject, Condition, difficulty) %>%
    summarize(
      firstbest.mean = mean((as.numeric(Location)-1)==CorrectAnswer)
    ) %>%
    ungroup() %>%
    group_by(Condition, difficulty) %>%
    summarize(
      y = mean(firstbest.mean),
      se = std.error(firstbest.mean)
    )

  plt <- ggplot(data=pdata[pdata$difficulty>=0,], aes(x=difficulty, y=y, group=Condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(0,4)) +
    ylim(c(0,1)) +
    labs(y="Pr(First Fix. to Best)", x="Best - Worst E[V]") +
    theme(
      legend.position = c(0.1,0.85)
    )

  return(plt)

}

## Regression function

fixprop.prfirst.reg <- function(data) {

  data <- data[data$FirstFix==T,]
  data$firstBest <- data$Location==data$CorrectAnswer
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, Condition, difficulty) %>%
    summarize(n = sum(n),
              firstBest = sum(firstBest))

  results <- brm(
    firstBest | trials(n) ~ difficulty*Condition + (1+difficulty*Condition | subject),
    data=data,
    family = binomial(link="logit"),
    file = file.path(tempdir, "fixprop.prfirst")
  )
  return(results)

}

######################
## Exploratory
######################

plt.prfirst.e <- fixprop.prfirst.plt(cfr)
#reg.prfirst.e <- fixprop.prfirst.reg(cfr)

plt.prfirst.e
#fixef(reg.prfirst.e)[,c('Estimate', 'Q2.5', 'Q97.5')]