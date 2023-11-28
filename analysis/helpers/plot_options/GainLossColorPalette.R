# Color palette
my_colors = list(
  gain_loss_colors = c("green4", "red3", "blue2", "purple2", "orange2", "deeppink", "cyan3", "bisque3")
)
cvi_palettes = function(name, n, all_palettes = my_colors, type = c("discrete", "continuous")) {
  palette = all_palettes[[name]]
  if (missing(n)) {
    n = length(palette)
  }
  type = match.arg(type)
  out = switch(type,
               continuous = grDevices::colorRampPalette(palette)(n),
               discrete = palette[1:n]
  )
  structure(out, name = name, class = "palette")
}
scale_color_gl = function(name) {
  ggplot2::scale_colour_manual(values = cvi_palettes(name,
                                                     type = "discrete"))
}
scale_fill_gl = function(name) {
  ggplot2::scale_fill_manual(values = cvi_palettes(name,
                                                   type = "discrete"))
}