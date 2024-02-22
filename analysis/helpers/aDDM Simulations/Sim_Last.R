## Plot function

sim.lastfix.plt <- function(data, xlim) {
  
  data$lastOtherVDiff = NA
  data$nlastOtherVDiff = NA
  data$lastOtherVDiff[data$lastFixLoc==1] = (data$vL[data$lastFixLoc==1]-data$vR[data$lastFixLoc==1])
  data$lastOtherVDiff[data$lastFixLoc==0] = (data$vR[data$lastFixLoc==0]-data$vL[data$lastFixLoc==0])
  breaks <- seq(-1.125,1.125,.25)
  tags   <- seq(-1,1,.25)
  data$nlastOtherVDiff[data$studyN==1] = as.numeric(as.character(cut(data$lastOtherVDiff[data$studyN==1], breaks, labels=tags)))
  breaks <- seq(-10.5,10.5,1)
  tags   <- seq(-10,10,1)
  data$nlastOtherVDiff[data$studyN==2] = as.numeric(as.character(cut(data$lastOtherVDiff[data$studyN==2], breaks, labels=tags)))/4
  
  data$choseLastFix = data$choice==data$lastFixLoc
  
  pdata <- data %>%
    group_by(simulated, studyN, subject, condition, lastFixLoc, nlastOtherVDiff) %>%
    summarize(
      choseLastFix.mean = mean(choseLastFix)
    ) %>%
    group_by(simulated, studyN, subject, condition, nlastOtherVDiff) %>%
    summarize(
      choseLastFix.mean = mean(choseLastFix.mean)
    ) %>%
    group_by(simulated, studyN, condition, nlastOtherVDiff) %>%
    summarize(
      y = mean(choseLastFix.mean),
      se = std.error(choseLastFix.mean)
    ) %>%
    na.omit()
  
  print(pdata)

  plt <- ggplot(data=pdata, aes(x=nlastOtherVDiff, y=y, color=condition, alpha=simulated)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_linerange(
      aes(ymin=y-se, ymax=y+se), 
      size=errsize, 
      position=position_jitter(width=.01, seed=4), 
      show.legend=F
    ) +
    geom_line(aes(linetype=simulated), size=linesize) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Last Fix. Option)", x="Norm. Last - Other E[V]", color="Condition", linetype="Study") +
    scale_alpha_discrete(range = c(0.25, 1.0)) +
    theme(
      legend.position="none",
      panel.spacing=unit(2,"lines")
    ) +
    facet_grid(rows = vars(studyN)) +
    theme(
      strip.background = element_blank(),
      strip.text.y = element_blank()
    )


  return(plt)
}