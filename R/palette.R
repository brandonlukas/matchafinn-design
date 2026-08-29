# Colour tokens (STYLE.md §2). Reading: colour = the hero acted; slate = a competitor; rule grey =
# nothing tried (null, floor, context). One hue, one meaning, across the whole paper. Panel scripts
# reference tokens (pal[["slate"]]), never hex literals.
pal <- vapply(.tokens$colour, `[[`, "", "hex")

# 8 desaturated hues for the one many-category case where colour is the sole (illustrative) encoder,
# e.g. a UMAP by tissue; "Other" is pal[["rule"]]. Cap at 8. Not available for any other meaning.
pal_tissue <- .tokens$tissue

# Signal ramp — read density (deeptools-style heatmaps, tracks): white -> atac -> umber, through the
# atac token; ends in umber, never red. The stops sit at pal_signal_at (0, 0.37, 1) so that L* falls
# linearly (97 -> 72 -> 28) across the range — a perceptually even ramp, not one that darkens twice
# as fast in its upper half. ComplexHeatmap: colorRamp2(pal_signal_at * zmax, pal_signal).
pal_signal <- .tokens$signal
pal_signal_at <- .tokens$signal_at

pal_modality <- c("ATAC" = pal[["atac"]], "ChIP" = pal[["chip"]])
scale_colour_modality <- function(...) ggplot2::scale_colour_manual(values = pal_modality, ...)

# Arms: case is always rose; control is teal when it is a compared arm, slate when it is context
# (`context = TRUE`) — STYLE.md §2.
pal_arm <- function(context = FALSE) {
  c(case = pal[["case"]], control = if (context) pal[["slate"]] else pal[["control"]])
}
scale_colour_arm <- function(context = FALSE, ...) ggplot2::scale_colour_manual(values = pal_arm(context), ...)
scale_fill_arm <- function(context = FALSE, ...) ggplot2::scale_fill_manual(values = pal_arm(context), ...)

# ENCODE SCREEN cCRE classes for composition bars (STYLE.md §2): PLS → pELS → dELS is one olive
# lightness ramp (ordinal by distance to TSS; light for dELS, which dominates every bar), the
# TF-binding-defined classes collapse to one dusty blue, "none" is rule grey.
pal_ccre <- unlist(.tokens$ccre)

# Family ramp (STYLE.md §2): ordered sub-categories of one family are lightness steps of that
# family's hue, never new hues. `n` colours from the token toward `to` (`to` itself excluded):
# ramp("matcha", 2)[2] is the pale step, ramp("matcha", 2, to = "black")[2] the dark one.
ramp <- function(token, n, to = "white") grDevices::colorRampPalette(c(pal[[token]], to))(n + 1)[seq_len(n)]
