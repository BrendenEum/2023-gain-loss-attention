bias.firstfix.plt <- function(data, xlim) {

  # breaks <- seq(-50,1250,100)/1000
  # labels <- seq(0,1200,100)/1000
  # data$fix_dur <- cut(data$fix_dur, breaks=breaks, labels=labels) %>%
  #   as.character() %>%
  #   as.numeric()
  # 
  # pdata <- data[data$firstFix==T,] %>%
  #   group_by(subject, condition, fix_dur) %>%
  #   summarize(
  #     corrFirst.mean = mean(firstSeenChosen.corr)
  #   ) %>%
  #   ungroup() %>%
  #   group_by(condition, fix_dur) %>%
  #   summarize(
  #     y = mean(corrFirst.mean),
  #     se = std.error(corrFirst.mean)
  #   )
  # 
  # plt <- ggplot(data=pdata, aes(x=fix_dur, y=y)) +
  #   myPlot +
  #   geom_hline(yintercept=0, color="grey", alpha=0.75) +
  #   geom_line(aes(color=condition), size=linesize) +
  #   geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
  #   labs(y="Corr. Pr(First Seen Chosen)", x="First Fixation Duration (s)")+
  #   xlim(c(xlim[1],xlim[2])) +
  #   ylim(c(-0.4,0.4))
  
  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, location, nfirstOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) 
  
  pdata$choice.mean[pdata$location=="Right"] = 1-pdata$choice.mean[pdata$location=="Right"]
  
  pdata = pdata %>%
    group_by(studyN, subject, condition, nfirstOtherVDiff) %>%
    summarize(
      choice.mean = mean(choice.mean)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, nfirstOtherVDiff) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    ) %>%
    na.omit()
  
  
  
  plt <- ggplot(data=pdata, aes(x=nfirstOtherVDiff, y=y, color=condition)) +
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
    labs(y="Pr(Choose First Fix. Option)", x="Norm. First - Other E[V]", color="Condition", linetype="Study")

  return(plt)
}

## Regression function

bias.firstfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$firstFix==T,] 
  data <- data %>% mutate(n=1)
  data$choseFirstFix = ifelse(
    (data$choice==1 & data$location=="Left") | (data$choice==0 & data$location=="Right"), 1, 0)
  data <-  data %>%
    group_by(subject, condition, nfirstOtherVDiff) %>%
    summarize(n = sum(n),
              choice = sum(choseFirstFix))
  
  priors <- c(
    set_prior("normal(0, 0.5)", class = "Intercept"), 
    set_prior("normal(0, 8.0)", class = "b", coef = "znfirstOtherVDiff"),  
    set_prior("normal(0, 0.5)", class = "b", coef = "relevelconditionrefEQGainLoss"), 
    set_prior("normal(0, 1.0)", class = "b", coef = "znfirstOtherVDiff:relevelconditionrefEQGainLoss")  
  )
  
  data$znfirstOtherVDiff = scale(data$nfirstOtherVDiff)

  results <- my_brm(
    choice | trials(n) ~ 
      znfirstOtherVDiff*relevel(condition, ref="Gain") + 
      (1+znfirstOtherVDiff*relevel(condition, ref="Gain") | subject),
    data=data,
    family = binomial(link="logit"),
    prior = priors,
    file = file.path(tempregdir, paste0(study, "_ChoiceBiases_First_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.firstfix.e <- bias.firstfix.plt(cfr)
#reg.firstfix.e <- bias.firstfix.reg(cfr)

#plt.firstfix.e
#fixef(reg.firstfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]