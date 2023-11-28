data = cfr

breaks <- seq(-50,1250,100)/1000
labels <- seq(0,1200,100)/1000
data$fix_dur <- cut(data$fix_dur, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

pdata <- data[data$FirstFix==T,] %>%
  group_by(subject, Condition, FixCrossLoc, fix_dur) %>%
  summarize(
    corrFirst.mean = mean(firstSeenChosen.corr, na.rm=T)
  ) %>%
  ungroup() %>%
  group_by(Condition, FixCrossLoc, fix_dur) %>%
  summarize(
    y = mean(corrFirst.mean, na.rm=T),
    se = std.error(corrFirst.mean, na.rm=T)
  )

plt <- ggplot(data=pdata, aes(x=fix_dur, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), size=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  labs(y="Corr. Pr(First Seen Chosen)", x="First Fixation Duration (s)")+
  xlim(c(.1,1)) +
  ylim(c(-0.4,0.4)) +
  facet_grid(cols = vars(FixCrossLoc))