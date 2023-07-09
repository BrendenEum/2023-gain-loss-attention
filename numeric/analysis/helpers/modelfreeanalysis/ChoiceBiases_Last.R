## Plot function

bias.lastfix.plt <- function(data) {

  pdata <- data[data$LastFix==T,] %>%
    group_by(subject, Condition, Location, vDiff) %>%
    summarize(
      choice.mean = mean(choice)
    ) %>%
    ungroup() %>%
    group_by(Condition, Location, vDiff) %>%
    summarize(
      y = mean(choice.mean),
      se = std.error(choice.mean)
    )

  plt <- ggplot(data=pdata, aes(x=vDiff, y=y, linetype=Location)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_vline(xintercept=0, color="grey", alpha=0.75) +
    geom_line(aes(color=Condition), size=linesize) +
    geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
    xlim(c(-4,4)) +
    ylim(c(0,1)) +
    labs(y="Pr(Choose Left)", x="Left - Right E[V]") +
    theme(
      legend.position=c(0.1,0.75)
    ) +
    guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA))))


  return(plt)
}

## Regression function

bias.lastfix.reg <- function(data) {

  data <- data[data$LastFix==T,]
  data <- data %>% mutate(n=1)
  data <-  data %>%
    group_by(subject, Condition, Location, vDiff) %>%
    summarize(n = sum(n),
              choice = sum(choice))

  results <- brm(
    choice | trials(n) ~ vDiff*Condition*Location + (1+vDiff*Condition*Location | subject),
    data=data,
    family = binomial(link="logit"),
    file = file.path(tempdir, "bias.lastfix")
  )
  return(results)

}

######################
## Exploratory
######################

plt.lastfix.e <- bias.lastfix.plt(cfr)
#reg.lastfix.e <- bias.lastfix.reg(cfr)

plt.lastfix.e
#fixef(reg.lastfix.e)[,c('Estimate', 'Q2.5', 'Q97.5')]