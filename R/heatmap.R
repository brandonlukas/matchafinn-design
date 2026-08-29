# Heatmap furniture (STYLE.md "Heatmaps"). ComplexHeatmap's own colourbar draws its ticks inside the
# bar with no way to change it, so the house colourbar is drawn here with grid: a vertical ramp,
# one `rule`-weight border, ticks and labels OUTSIDE to the right (the deeptools / matplotlib look).
# Call inside a viewport (it fills it, centred); nothing is labelled — the unit goes in the caption.
#   col_fun  a circlize::colorRamp2 (or any function value -> colour)
#   at       tick values, within `lim`
colourbar <- function(col_fun, at, lim = range(at), height = grid::unit(14, "mm"), width = grid::unit(2, "mm"),
                      tick = grid::unit(0.7, "mm"), fontsize = fs_min) {
  z <- seq(lim[1], lim[2], length.out = 128)
  lwd <- .tokens$stroke_pt$rule / 0.75 # grid lwd is 1/96 in; STYLE's rule stroke in pt
  x <- grid::unit(0.5, "npc") - width * 0.5 # bar's left edge; labels hang off its right edge
  grid::grid.raster(matrix(rev(col_fun(z)), ncol = 1),
    x = x, y = 0.5, width = width, height = height, just = "left", interpolate = TRUE
  )
  grid::grid.rect(x = x, y = 0.5, width = width, height = height, just = "left",
    gp = grid::gpar(fill = NA, col = pal[["ink"]], lwd = lwd))
  y0 <- grid::unit(0.5, "npc") - height * 0.5
  for (a in at) {
    y <- y0 + height * ((a - lim[1]) / diff(lim))
    grid::grid.segments(x + width, y, x + width + tick, y, gp = grid::gpar(col = pal[["ink"]], lwd = lwd))
    grid::grid.text(format(a), x + width + tick + grid::unit(0.6, "mm"), y, just = "left",
      gp = grid::gpar(fontsize = fontsize))
  }
  invisible(NULL)
}
