data = cfr

pdata <- data[data$LastFix==T,] %>%
  group_by(subject, Condition, Location, FixCrossLoc, vDiff) %>%
  summarize(
    choice.mean = mean(choice)
  ) %>%
  ungroup() %>%
  group_by(Condition, Location, FixCrossLoc, vDiff) %>%
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
  guides(linetype = guide_legend(override.aes = list(fill = c(NA, NA)))) +
  facet_grid(cols = vars(FixCrossLoc))