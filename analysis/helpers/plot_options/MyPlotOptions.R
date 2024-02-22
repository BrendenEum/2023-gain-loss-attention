gainlosscolors = c("Gain" = "Green4", "Loss" = "Red3", "blue2", "deeppink", "purple2", "orange2", "cyan3", "bisque")

color_e = 'lightcyan1'
color_c = 'mistyrose1'
color_j = 'lightcyan2'

myPlot = list(
  theme_bw(),
  coord_cartesian(expand=F),
  scale_color_manual(values=gainlosscolors),
  scale_fill_manual(values=gainlosscolors),
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

linesize = 1.5
markersize = .01
errsize = 1.5
linealpha = 0.9
figw = 6
figh = 4
legendposition = c(0.08,0.74)