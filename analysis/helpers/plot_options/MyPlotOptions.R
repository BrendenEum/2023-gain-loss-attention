myPlot = list(
  theme_bw(),
  coord_cartesian(expand=F),
  scale_color_gl("gain_loss_colors"),
  scale_fill_gl("gain_loss_colors"),
  theme(
    legend.position="None",
    legend.background=element_blank(),
    legend.key = element_rect(fill = NA),
    legend.spacing.x = unit(0.1, 'cm'),
    legend.spacing.y = unit(0.1, 'cm'),
    plot.margin = unit(c(.5,.5,.5,.5), "cm"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 22),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 12)
  ),
  guides(
    color = guide_legend(override.aes=list(fill=NA)),
    fill = guide_legend(byrow = T)
  )
)

linesize = 2
markersize = .1
ribbonalpha = 0.33
figw = 6
figh = 4