## Plot function

fixCross.lastfix.plt <- function(data, xlim) {

  pdata <- data[data$lastFix==T,] %>%
    group_by(studyN, subject, condition, location, fixCrossLoc, nlastOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) 
  
  pdata$choice.mean[pdata$location=="Right"] = 1-pdata$choice.mean[pdata$location=="Right"]
  
  pdata = pdata %>%
    group_by(studyN, subject, condition, fixCrossLoc, nlastOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice.mean)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, fixCrossLoc, nlastOtherVDiff) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()
  
  

  plt <- ggplot(data=pdata, aes(x=nlastOtherVDiff, y=y, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Last Fix. Option)", x="Norm. Last - Other E[V]") +
    theme_bw() +
    theme(
      legend.position = "none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(cols = vars(fixCrossLoc))


  return(plt)
}

## Regression function

bias.lastfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$lastFix==T,]
  data <- data %>% mutate(n=1)
  data$choseLastFix = ifelse(
    (data$choice==1 & data$location=="Left") | (data$choice==0 & data$location=="Right"), 1, 0)
  data <-  data %>%
    group_by(subject, condition, nlastOtherVDiff) %>%
    summarize(n = sum(n),
              choice = sum(choseLastFix))

  results <- brm(
    choice | trials(n) ~ nlastOtherVDiff*relevel(condition,ref="Gain") + (1+nlastOtherVDiff*relevel(condition,ref="Gain") | subject),
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