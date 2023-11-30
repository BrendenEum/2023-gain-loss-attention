## Plot function

psycho.numfix.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="Last",] %>%
    group_by(subject, condition, difficulty) %>%
    summarize(
      fix_num.mean = mean(fix_num)
    ) %>%
    ungroup() %>%
    group_by(condition, difficulty) %>%
    summarize(
      y = mean(fix_num.mean),
      se = std.error(fix_num.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y)) +
    myPlot +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,NA)) +
    labs(y="Number of Fixations", x="Best - Worst E[V]")


  return(plt)

}

## Regression function

psycho.numfix.reg <- function(data) {

  data <- data[data$LastFix==T,]

  results <- brm(
    fix_num ~ difficulty*Condition + (1+difficulty*Condition | subject),
    data=data,
    family = gaussian(),
    file = file.path(tempdir, "psycho.numfix")
  )
  return(results)

}

######################
## Exploratory
######################

#plt.numfix.e <- psycho.numfix.plt(cfr)
#reg.numfix.e <- psycho.numfix.reg(cfr)

#plt.numfix.e
#fixef(reg.numfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]