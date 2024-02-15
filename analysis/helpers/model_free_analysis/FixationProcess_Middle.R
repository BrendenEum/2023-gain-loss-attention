## Plot function

fixprop.mid.plt <- function(data, xlim) {

  pdata <- data[data$middleFix==T,] %>%
    group_by(studyN, subject, condition, ndifficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, ndifficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=ndifficulty, y=y, color=condition)) +
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
    ylim(c(.3,.8)) +
    labs(y="Middle Fix. Duration (s)", x="Norm. Best - Worst E[V]", color="Condition")


  return(plt)

}

## Regression function

fixprop.mid.reg <- function(data, study="error", dataset="error") {

  data <- data[data$middleFix==T,]

  results <- brm(
    fix_dur ~ ndifficulty*relevel(condition,ref="Gain") + (1+ndifficulty*relevel(condition,ref="Gain") | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempregdir, paste0(study, "_FixationProcess_Middle_", dataset)))
  
  return(results)

}

######################
## Exploratory
######################

#plt.mid.e <- fixprop.mid.plt(cfr)
#reg.mid.e <- fixprop.mid.reg(cfr)

#plt.mid.e
#fixef(reg.mid.e)[,c('Estimate', 'Q2.5', 'Q97.5')]