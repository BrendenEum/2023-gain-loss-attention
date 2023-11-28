## Plot function

psycho.numfix.plt <- function(data) {

  pdata <- data[data$fix_type=="Last",] %>%
    group_by(subject, Condition, difficulty) %>%
    summarize(
      fix_num.mean = mean(fix_num)
    ) %>%
    ungroup() %>%
    group_by(Condition, difficulty) %>%
    summarize(
      y = mean(fix_num.mean),
      se = std.error(fix_num.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y, group=Condition)) +
    myPlot +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(0,1)) +
    ylim(c(0,NA)) +
    labs(y="Number of Fixations", x="Best - Worst E[V]")


  return(plt)

}

## Regression function

psycho.numfix.reg <- function(data) {

  data <- data[data$fix_type=="Last",]

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

plt.numfix.e <- psycho.numfix.plt(cfr)
#reg.numfix.e <- psycho.numfix.reg(cfr)

plt.numfix.e
#fixef(reg.numfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]