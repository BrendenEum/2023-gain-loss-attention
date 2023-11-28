## Plot function

fixprop.fixtype.plt <- function(data) {

  pdata.F <- data[data$FirstFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(Condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 1
    )
  pdata.M <- data[data$MiddleFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(Condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 2
    )
  pdata.L <- data[data$LastFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(Condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 3
    )
  pdata <- bind_rows(pdata.F,pdata.M,pdata.L)
  pdata$x <- factor(pdata$x, levels=c(1,2,3), labels=c("First","Middle","Last"))

  plt <- ggplot(data=pdata, aes(x=x, y=y, group=Condition)) +
    myPlot +
    geom_bar(aes(fill=Condition), position=position_dodge(.9), stat="identity") +
    geom_errorbar(aes(ymin=y-se, ymax=y+se), position=position_dodge(.9), color='black', width=0) +
    ylim(c(0,.7)) +
    labs(y="Fixation Duration (s)", x="Fixation Type")


  return(plt)
}

## Difference t-tests

fixprop.durationtype.ttest <- function(data) {

  fixmean.F <- data[data$FirstFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  t.test.F <- t.test(
    fixmean.F[fixmean.F$Condition=="Gain",]$fix_dur.mean,
    fixmean.F[fixmean.F$Condition=="Loss",]$fix_dur.mean
  )
  # cohen.d.F <- cohen.d(
  #   fixmean.F[fixmean.F$Condition=="Gain",]$fix_dur.mean,
  #   fixmean.F[fixmean.F$Condition=="Loss",]$fix_dur.mean
  # )

  fixmean.M <- data[data$MiddleFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  t.test.M <- t.test(
    fixmean.M[fixmean.M$Condition=="Gain",]$fix_dur.mean,
    fixmean.M[fixmean.M$Condition=="Loss",]$fix_dur.mean
  )
  # cohen.d.M <- cohen.d(
  #   fixmean.M[fixmean.M$Condition=="Gain",]$fix_dur.mean,
  #   fixmean.M[fixmean.M$Condition=="Loss",]$fix_dur.mean
  # )

  fixmean.L <- data[data$LastFix==T,] %>%
    group_by(subject, Condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  t.test.L <- t.test(
    fixmean.L[fixmean.L$Condition=="Gain",]$fix_dur.mean,
    fixmean.L[fixmean.L$Condition=="Loss",]$fix_dur.mean
  )
  # cohen.d.L <- cohen.d(
  #   fixmean.L[fixmean.L$Condition=="Gain",]$fix_dur.mean,
  #   fixmean.L[fixmean.L$Condition=="Loss",]$fix_dur.mean
  # )

}


######################
## Exploratory
######################

plt.fixtype.e <- fixprop.fixtype.plt(cfr)