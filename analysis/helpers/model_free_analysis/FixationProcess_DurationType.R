## Plot function

fixprop.fixtype.plt <- function(data) {

  pdata.F <- data[data$firstFix==T,] %>%
    group_by(studyN, subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 1
    )
  pdata.M <- data[data$middleFix==T,] %>%
    group_by(studyN, subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 2
    )
  pdata.L <- data[data$lastFix==T,] %>%
    group_by(studyN, subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup() %>%
    group_by(studyN, condition) %>%
    summarize(
      y = mean(fix_dur.mean),
      se = std.error(fix_dur.mean),
      x = 3
    )
  pdata <- bind_rows(pdata.F,pdata.M,pdata.L)
  pdata$x <- factor(pdata$x, levels=c(1,2,3), labels=c("First","Middle","Last"))

  plt <- ggplot(data=pdata, aes(x=x, y=y, shape=studyN, color=condition)) +
    myPlot +
    geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
    geom_pointrange(aes(ymin=y-se, ymax=y+se), fatten=8, linewidth=.75, position=position_dodge(.9)) +
    ylim(c(0,1)) +
    labs(y="Fixation Duration (s)", x="Fixation Type", shape="Study") +
    guides(
      color="none"
    ) +
    theme(
      legend.position=c(0.052,0.88)
    )


  return(plt)
}

## Difference t-tests

fixprop.durationtype.ttest <- function(data, study="error", dataset="error") {

  # First Fixations
  fixmean.F <- data[data$firstFix==T,] %>%
    group_by(subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  
  t.test.F <- t.test(
    fixmean.F[fixmean.F$condition=="Gain",]$fix_dur.mean-
    fixmean.F[fixmean.F$condition=="Loss",]$fix_dur.mean)
  t.test.F.txt <- capture.output(print(t.test.F))
  writeLines(t.test.F.txt, con = file.path(tempregdir, paste0(study, "_FixationProcess_DurationType_First_", dataset, ".txt")))
  
  #cohen.d.F <- cohen.d(
  #  fixmean.F[fixmean.F$condition=="Gain",]$fix_dur.mean,
  #  fixmean.F[fixmean.F$condition=="Loss",]$fix_dur.mean)

  #Middle Fixations
  fixmean.M <- data[data$middleFix==T,] %>%
    group_by(subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  
  t.test.M <- t.test(
    fixmean.M[fixmean.M$condition=="Gain",]$fix_dur.mean-
    fixmean.M[fixmean.M$condition=="Loss",]$fix_dur.mean)
  t.test.M.txt <- capture.output(print(t.test.M))
  writeLines(t.test.M.txt, con = file.path(tempregdir, paste0(study, "_FixationProcess_DurationType_Middle_", dataset, ".txt")))
  
  #cohen.d.M <- cohen.d(
  #  fixmean.M[fixmean.M$condition=="Gain",]$fix_dur.mean,
  #  fixmean.M[fixmean.M$condition=="Loss",]$fix_dur.mean)

  #Last Fixations
  fixmean.L <- data[data$lastFix==T,] %>%
    group_by(subject, condition) %>%
    summarize(
      fix_dur.mean = mean(fix_dur)
    ) %>%
    ungroup()
  
  t.test.L <- t.test(
    fixmean.L[fixmean.L$condition=="Gain",]$fix_dur.mean-
    fixmean.L[fixmean.L$condition=="Loss",]$fix_dur.mean)
  t.test.L.txt <- capture.output(print(t.test.L))
  writeLines(t.test.L.txt, con = file.path(tempregdir, paste0(study, "_FixationProcess_DurationType_Last_", dataset, ".txt")))
  
  #cohen.d.L <- cohen.d(
  #  fixmean.L[fixmean.L$condition=="Gain",]$fix_dur.mean,
  #  fixmean.L[fixmean.L$condition=="Loss",]$fix_dur.mean)

}


######################
## Exploratory
######################

#plt.fixtype.e <- fixprop.fixtype.plt(cfr)