data = cfr # only when you've made cfr = ecfr in model_free_analysis_figures.R!
xlim = c(-1.3,1.3)

breaks <- seq(-1.625,1.625,.250)
labels <- seq(-1.500,1.500,.250)
print(breaks)
data$net_fix <- cut(data$net_fix, breaks=breaks, labels=labels) %>%
  as.character() %>%
  as.numeric()

data = data %>%
  mutate(tempValue = (vL+vR)/2) %>%
  group_by(studyN, subject, condition) %>%
  mutate(meanValue = mean(tempValue)) %>%
  ungroup() %>%
  mutate(belowAverage = ifelse(vL<meanValue & vR<meanValue, 1, 0))

view(data[,c("studyN","subject", "condition","vL",'vR','meanValue','belowAverage')])

pdata <- data[data$firstFix==T & data$belowAverage==1,] %>%
  group_by(studyN, subject, condition, net_fix) %>%
  summarize(
    choice.mean = mean(nchoice.corr, na.rm=T)
  ) %>%
  ungroup() %>%
  group_by(studyN, condition, net_fix) %>%
  summarize(
    y = mean(choice.mean),
    se = std.error(choice.mean)
  ) %>%
  na.omit()

plt <- ggplot(data=pdata, aes(x=net_fix, y=y, color=condition)) +
  myPlot +
  geom_hline(yintercept=0, color="grey", alpha=0.75) +
  geom_vline(xintercept=0, color="grey", alpha=0.75) +
  geom_linerange(
    aes(ymin=y-se, ymax=y+se, group=studyN), 
    size=errsize, 
    position=position_jitter(width=.01, seed=4), 
    show.legend=F
  ) +
  geom_line(aes(linetype=studyN), size=linesize) +
  labs(y="Corr. Pr(Choose Left)", x="Net Fixation (L-R, s)", color="Condition", linetype="Study") +
  xlim(c(xlim[1],xlim[2])) +
  ylim(c(-0.41,0.41)) +
  theme(
    legend.position = c(0.25,0.74)
  )

plot(plt)
