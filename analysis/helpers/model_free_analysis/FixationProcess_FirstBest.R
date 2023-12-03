## Plot function

fixprop.prfirst.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(subject, condition, difficulty) %>%
    summarize(
      firstbest.mean = mean(location==correctAnswer)
    ) %>%
    ungroup() %>%
    group_by(condition, difficulty) %>%
    summarize(
      y = mean(firstbest.mean),
      se = std.error(firstbest.mean)
    ) %>%
    na.omit()
  

  plt <- ggplot(data=pdata[pdata$difficulty>=0,], aes(x=difficulty, y=y)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1], xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(First Fix. to Best)", x="Best - Worst E[V]", color="Condition") +
    theme(
      legend.position = c(0.1,0.85)
    )

  return(plt)

}

## Regression function

fixprop.prfirst.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]
  data$firstBest <- data$location==data$correctAnswer
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, condition, difficulty) %>%
    summarize(n = sum(n),
              firstBest = sum(firstBest))

  results <- brm(
    firstBest | trials(n) ~ difficulty*condition + (1+difficulty*condition | subject),
    data=data,
    family = binomial(link="logit"),
    file = file.path(tempregdir, paste0(study, "_FixationProcess_FirstBest_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.prfirst.e <- fixprop.prfirst.plt(cfr)
#reg.prfirst.e <- fixprop.prfirst.reg(cfr)

#plt.prfirst.e
#fixef(reg.prfirst.e)[,c('Estimate', 'Q2.5', 'Q97.5')]