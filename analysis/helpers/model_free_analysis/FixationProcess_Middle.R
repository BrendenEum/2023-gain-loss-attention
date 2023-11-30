## Plot function

fixprop.mid.plt <- function(data, xlim) {

  pdata <- data[data$fix_type=="Middle",] %>%
    group_by(subject, condition, difficulty) %>%
    summarize(
      mid.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(condition, difficulty) %>%
    summarize(
      y = mean(mid.mean),
      se = std.error(mid.mean)
    )

  plt <- ggplot(data=pdata, aes(x=difficulty, y=y)) +
    myPlot +
    geom_line(aes(color=condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=condition), alpha=ribbonalpha, show.legend=F) +
    xlim(c(xlim[1],xlim[2])) +
    ylim(c(0,NA)) +
    labs(y="Middle Fix. Duration (s)", x="Best - Worst E[V]", color="Condition")


  return(plt)

}

## Regression function

fixprop.mid.reg <- function(data) {

  data <- data[data$MiddleFix==T,]

  results <- brm(
    fix_dur ~ difficulty*Condition + (1+difficulty*Condition | subject),
    data=data,
    family = gaussian(),
    prior = c(
      prior(normal(0,800), class=Intercept),
      prior(normal(0,50), class=b)
    ),
    file = file.path(tempdir, "fixprop.mid")
  )
  return(results)

}

######################
## Exploratory
######################

#plt.mid.e <- fixprop.mid.plt(cfr)
#reg.mid.e <- fixprop.mid.reg(cfr)

#plt.mid.e
#fixef(reg.mid.e)[,c('Estimate', 'Q2.5', 'Q97.5')]