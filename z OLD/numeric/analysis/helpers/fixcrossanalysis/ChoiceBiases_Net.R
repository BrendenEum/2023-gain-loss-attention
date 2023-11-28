data = cfr

breaks <- seq(-1050,1050,100)/1000
labels <- seq(-1000,1000,100)/1000
print(breaks)
data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

pdata <- data[data$FirstFix==T,] %>%
  group_by(subject, Condition, FixCrossLoc, net_fix) %>%
  summarize(
    choice.mean = mean(choice.corr)
  ) %>%
  ungroup() %>%
  group_by(Condition, FixCrossLoc, net_fix) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  )


plt <- ggplot(data=pdata, aes(x=net_fix, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), size=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)") +
  xlim(c(-1,1)) +
  ylim(c(-0.4,0.4)) +
  facet_grid(cols = vars(FixCrossLoc))