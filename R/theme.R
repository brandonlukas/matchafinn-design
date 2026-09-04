# Type scale (pt) — semantic roles, not arbitrary sizes (STYLE.md §3). The journal dictates the
# window, so these are the whole hierarchy. geom_text()/geom_label() take `size` in mm: pt2mm().
fs_label <- .tokens$type_pt$label # panel letter — Arial Black, Inkscape only
fs_base  <- .tokens$type_pt$base  # axis titles, legend titles, strip titles, panel title
fs_small <- .tokens$type_pt$small # tick labels, legend text, most in-panel annotation
fs_min   <- .tokens$type_pt$min   # dense text only; never below

pt2mm <- function(pt) pt / ggplot2::.pt

# Point sizes (ggplot `size`; STYLE.md §4): size is the point's role, never a bare number.
pt_cloud <- .tokens$point$cloud # every member of a population in the thousands; alpha 0.6, rasterised
pt_data  <- .tokens$point$data  # observations you could count: swarm, scatter, replicates
pt_key   <- .tokens$point$key   # one point per group that summarises it (estimate + CI); legend keys

# The journal theme: black text and lines, no gridlines, transparent background, 0.4 pt lines,
# two type sizes in use (titles fs_base, tick/legend text one step below).
theme_nature <- function(base_size = fs_base, base_family = "") {
  secondary <- base_size - 1 # tick labels / legend text one step below titles (fs_small when base=fs_base)
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # colour is set once on the roots; every text/line element inherits it (strip.text is the
      # one theme_grey overrides with its own grey, so it is set again)
      text              = ggplot2::element_text(color = "black", size = base_size),
      line              = ggplot2::element_line(color = "black", linewidth = .tokens$stroke_pt$rule),
      plot.title        = ggplot2::element_text(size = base_size, face = "plain", hjust = 0),
      plot.subtitle     = ggplot2::element_text(size = secondary),
      plot.tag          = ggplot2::element_text(size = fs_label, face = "bold", hjust = 0),
      axis.title        = ggplot2::element_text(size = base_size),
      axis.text         = ggplot2::element_text(size = secondary),
      legend.title      = ggplot2::element_text(size = base_size),
      legend.text       = ggplot2::element_text(size = secondary),
      strip.text        = ggplot2::element_text(color = "black", size = base_size),

      panel.grid        = ggplot2::element_blank(),
      panel.background  = ggplot2::element_blank(),
      plot.background   = ggplot2::element_blank(),
      legend.background = ggplot2::element_blank(),
      legend.key        = ggplot2::element_blank(),
      strip.background  = ggplot2::element_blank()
    )
}

# Axes and bars — STYLE.md §4 (Axes, Bars). axis_cap(x = FALSE) when x is discrete.
bar_width   <- .tokens$geom$bar_width                    # of the slot; dodged groups share it
expand_zero <- ggplot2::expansion(mult = c(0, 0.05))     # flush at 0, 5 % headroom
axis_cap <- function(x = TRUE, y = TRUE) {
  cap <- ggplot2::guide_axis(cap = "both")
  ggplot2::guides(x = if (x) cap, y = if (y) cap)
}

# Embedding add-on (UMAP / PCA / t-SNE): arrowed, corner-cropped axis guides, no ticks or text,
# square aspect. A list of layers ADDED on top of theme_nature(), not a replacement.
theme_embedding <- function() {
  axis <- legendry::guide_axis_base(cap = I(c(-Inf, 0.2)))
  # Compact journal-style head: small closed triangle (~5× the 0.4pt stem width), mitre/butt so
  # the apex stays sharp. Longer (0.55 lines) reads swept-heavy; wider+shorter reads as a fat triangle.
  arrow <- grid::arrow(type = "closed", angle = 22, length = grid::unit(0.3, "lines"))
  list(
    ggplot2::theme(
      axis.ticks   = ggplot2::element_blank(),
      axis.text    = ggplot2::element_blank(),
      aspect.ratio = 1,
      axis.line    = ggplot2::element_line(arrow = arrow, linejoin = "mitre", lineend = "butt"),
      # unitless orientation labels (UMAP 1/2) → quietest tier (fs_small), not full axis-title size
      axis.title   = ggplot2::element_text(hjust = 0, size = fs_small)
    ),
    ggplot2::guides(x = axis, y = axis)
  )
}
