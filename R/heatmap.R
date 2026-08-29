# Heatmap furniture (STYLE.md "Heatmaps"). ComplexHeatmap's own colourbar draws its ticks inside the
# bar with no way to change it, so the house colourbar is drawn here with grid: a vertical ramp,
# one `rule`-weight border, ticks and labels OUTSIDE to the right (the deeptools / matplotlib look).
# Call inside a viewport (~11 mm wide): the bar sits at the edge away from the labels, vertically
# centred; `side` puts ticks + labels to the right (default) or left. Nothing is labelled — the unit goes in the caption.
#   col_fun  a circlize::colorRamp2 (or any function value -> colour)
#   lim      the bar's range (0 to the clipped max)
#   at       tick values; default pretty(lim) — even increments, never the max itself
colourbar <- function(col_fun, lim, at = NULL, height = grid::unit(14, "mm"), width = grid::unit(2, "mm"),
                      tick = grid::unit(0.7, "mm"), fontsize = fs_min, side = c("right", "left")) {
  side <- match.arg(side) # which side of the bar the ticks and labels hang off
  # Even increments (pretty), and the bar simply runs past the last tick to the clipped max.
  if (is.null(at)) at <- pretty(lim, 3)
  at <- at[at >= lim[1] & at <= lim[2]]
  z <- seq(lim[1], lim[2], length.out = 128)
  lwd <- .tokens$stroke_pt$rule / 0.75 # grid lwd is 1/96 in; STYLE's rule stroke in pt
  # Bar at the viewport's edge on the far side from the labels; the labels take the rest of its width.
  x <- if (side == "right") grid::unit(0.5, "mm") else grid::unit(1, "npc") - grid::unit(0.5, "mm") - width
  grid::grid.raster(matrix(rev(col_fun(z)), ncol = 1),
    x = x, y = 0.5, width = width, height = height, just = "left", interpolate = TRUE
  )
  grid::grid.rect(x = x, y = 0.5, width = width, height = height, just = "left",
    gp = grid::gpar(fill = NA, col = pal[["ink"]], lwd = lwd))
  y0 <- grid::unit(0.5, "npc") - height * 0.5
  for (a in at) {
    y <- y0 + height * ((a - lim[1]) / diff(lim))
    if (side == "right") {
      grid::grid.segments(x + width, y, x + width + tick, y, gp = grid::gpar(col = pal[["ink"]], lwd = lwd))
      grid::grid.text(format(a), x + width + tick + grid::unit(0.6, "mm"), y, just = "left",
        gp = grid::gpar(fontsize = fontsize))
    } else {
      grid::grid.segments(x, y, x - tick, y, gp = grid::gpar(col = pal[["ink"]], lwd = lwd))
      grid::grid.text(format(a), x - tick - grid::unit(0.6, "mm"), y, just = "right",
        gp = grid::gpar(fontsize = fontsize))
    }
  }
  invisible(NULL)
}
