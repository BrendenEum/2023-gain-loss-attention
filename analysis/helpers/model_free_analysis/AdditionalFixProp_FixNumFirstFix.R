## Plot function

psycho.numfixfirstfix.plt <- function(data) {
  
  data = data[data$studyN==2,]
  
  data = data %>%
    group_by(studyN, subject, condition, trial) %>%
    mutate(maxFixNum = max(fix_num))
  
  pdata <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition, location) %>%
    summarize(
      maxFixNum.mean = mean(maxFixNum)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition, location) %>%
    summarize(
      y = mean(maxFixNum.mean),
      se = std.error(maxFixNum.mean)
    )

  plt <- ggplot(data=data[data$firstFix==T,], aes(x=maxFixNum, fill=condition)) +
    myPlot +
    geom_histogram(binwidth=1, color="black", show.legend=F) +
    coord_cartesian(ylim=c(0,1600), expand=F) +
    scale_y_continuous(breaks=c(0,700,1400)) +
    scale_x_continuous(breaks=c(1, 3, 5, 7, 9, 11, 13)) +
    labs(y="Count", x="Number of Fixations") +
    facet_grid(rows=vars(condition), cols=vars(location))

  return(plt)

}

## Regression function

psycho.numfixfirstfix.reg <- function(data, study="error", dataset="error") {

  data <- data[data$lastFix==T,]

  # results <- brm(
  #   fix_num ~ ndifficulty*relevel(condition,ref="Gain") + (1+ndifficulty*relevel(condition,ref="Gain") | subject),
  #   data=data,
  #   family = gaussian(),
  #   file = file.path(tempregdir, paste0(study, "_AdditionalFixProp_NumberFixationsFirstFix_", dataset)))
  # 
  return(results)

}

######################
## Exploratory
######################

#plt.numfix.e <- psycho.numfix.plt(cfr)
#reg.numfix.e <- psycho.numfix.reg(cfr)

#plt.numfix.e
#fixef(reg.numfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]