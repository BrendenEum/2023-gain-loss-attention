cfr$ov = cfr$vL + cfr$vR
data = cfr[cfr$Sanity==0,]
data$ov = round(data$ov, digits = 0)

pdata = data %>%
  group_by(subject, Condition, ov) %>%
  summarize(
    rt.mean = mean(rt)
  ) %>%
  ungroup() %>%
  group_by(Condition, ov) %>%
  summarize(
    y = mean(rt.mean), 
    se = std.error(rt.mean)
  )

ggplot(data = pdata, aes(x=ov, y=y, group=Condition, color=Condition, fill=Condition)) +
  geom_vline(xintercept = c(-3,2), color = "grey") +
  geom_ribbon(aes(ymin=y-se, ymax=y+se), alpha = .25) +
  geom_line() +
  labs(
    x = "Overall Value",
    y = "Response Time (s)"
  ) +
  ylim(c(0,4))
  
