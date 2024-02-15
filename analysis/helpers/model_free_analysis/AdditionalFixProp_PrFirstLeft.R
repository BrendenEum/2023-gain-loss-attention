## Plot function

addfixprop.firstLeft.plt <- function(data, xlim) {

  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, nvDiff) %>%
    summarize(
      mid.loc = mean(abs(as.numeric(location)-2))
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, nvDiff) %>%
    summarize(
      y = mean(mid.loc),
      se = std.error(mid.loc)
    )

  plt <- ggplot(data=pdata, aes(x=nvDiff, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(First Fix. Left)", x="Norm. Left - Right E[V]", color="Condition", linetype="Study") +
    theme(
      legend.position = c(.9, .24)
    )


  return(plt)
}

## Regression function

addfixprop.firstLeft.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,]
  data <- data %>% mutate(n=1)
  data$location_numeric = 2-as.numeric(data$location)
  data <-  data %>%
    group_by(subject, condition, nvDiff) %>%
    summarize(n = sum(n),
              countLeft = sum(location_numeric))
  
  results <- brm(
    countLeft | trials(n) ~ nvDiff*relevel(condition,ref="Gain") + (1+nvDiff*relevel(condition,ref="Gain") | subject),
    data=data,
    family = binomial(link="logit"),
    file = file.path(tempregdir, paste0(study, "_AdditionalFixProp_PrFirstLeft", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.first.e <- fixprop.first.plt(cfr)
#reg.first.e <- fixprop.first.reg(cfr)

#plt.first.e
#fixef(reg.first.e)[,c('Estimate', 'Q2.5', 'Q97.5')]