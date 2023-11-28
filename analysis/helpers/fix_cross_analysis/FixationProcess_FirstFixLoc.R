data = cfr[(cfr$FixCrossLoc=="Left" | cfr$FixCrossLoc=="Right"),]

pdata <- data[data$FirstFix==T,] %>%
  group_by(subject, Condition, FixCrossLoc, vDiff) %>%
  summarize(
    Location.mean = mean(-as.numeric(Location)+2, na.rm=F)
  ) %>%
  ungroup() %>%
  group_by(Condition, FixCrossLoc, vDiff) %>%
  summarize(
    y = mean(Location.mean, na.rm=F),
    se = std.error(Location.mean, na.rm=F)
  )

plt <- ggplot(data=pdata, aes(x=vDiff, y=y, group=Condition)) +
  myPlot +
  geom_hline(yintercept=0.5, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_line(aes(color=Condition), size=linesize) +
  geom_ribbon(aes(ymin=y-se, ymax=y+se, fill=Condition), alpha=ribbonalpha) +
  xlim(c(-4,4)) +
  ylim(c(0,1)) +
  labs(y="Pr(Look Left First)", x="Left - Right E[V]") +
  theme(
    legend.position=c(0.1,0.8)
  ) +
  facet_grid(cols = vars(FixCrossLoc))