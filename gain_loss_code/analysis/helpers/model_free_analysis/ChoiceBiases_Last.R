## Plot function

bias.lastfix.plt <- function(data, xlim) {

  pdata <- data[data$lastFix==T,] %>%
    group_by(studyN, subject, condition, location, nlastOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) 
  
  pdata$choice.mean[pdata$location=="Right"] = 1-pdata$choice.mean[pdata$location=="Right"]
  
  pdata = pdata %>%
    group_by(studyN, subject, condition, nlastOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice.mean)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, nlastOtherVDiff) %>%
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
      aes(ymin=y-se, ymax=y+se, group=studyN), 
      linewidth=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=studyN), linewidth=linesize) +
    coord_cartesian(xlim=c(xlim[1],xlim[2]), ylim=c(0,1), expand=F) +
    labs(y="Pr(Choose Last Fix. Option)", x="Norm. Last - Other E[V]", color="Condition", linetype="Study")


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
  
  priors <- c(
    set_prior("normal(0, 2.0)", class = "Intercept"), 
    set_prior("normal(0, 8.0)", class = "b", coef = "znlastOtherVDiff"),  
    set_prior("normal(0, 1.0)", class = "b", coef = "relevelconditionrefEQGainLoss"), 
    set_prior("normal(0, 1.0)", class = "b", coef = "znlastOtherVDiff:relevelconditionrefEQGainLoss")  
  )
  
  data$znlastOtherVDiff = scale(data$nlastOtherVDiff)

  results <- my_brm(
    choice | trials(n) ~ znlastOtherVDiff*relevel(condition,ref="Gain") + (1+znlastOtherVDiff*relevel(condition,ref="Gain") | subject),
    data=data,
    family = binomial(link="logit"),
    prior = priors,
    control = list(adapt_delta = 0.99),
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