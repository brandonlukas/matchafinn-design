# Colour tokens (STYLE.md §2). Reading: colour = the hero acted; slate = a competitor; rule grey =
# nothing tried (null, floor, context). One hue, one meaning, across the whole paper. Panel scripts
# reference tokens (pal[["slate"]]), never hex literals.
pal <- vapply(.tokens$colour, `[[`, "", "hex")

# 8 desaturated hues for the one many-category case where colour is the sole (illustrative) encoder,
# e.g. a UMAP by tissue; "Other" is pal[["rule"]]. Cap at 8. Not available for any other meaning.
pal_tissue <- .tokens$tissue

# Signal ramp — read density (deeptools-style heatmaps, tracks): white -> atac -> umber, through the
# atac token; ends in umber, never red. ComplexHeatmap: colorRamp2(c(0, zmax / 2, zmax), pal_signal).
pal_signal <- .tokens$signal

pal_modality <- c("ATAC" = pal[["atac"]], "ChIP" = pal[["chip"]])
scale_colour_modality <- function(...) ggplot2::scale_colour_manual(values = pal_modality, ...)

# Arms: case is always rose; control is teal when it is a compared arm, slate when it is context
# (`context = TRUE`) — STYLE.md §2.
pal_arm <- function(context = FALSE) {
  c(case = pal[["case"]], control = if (context) pal[["slate"]] else pal[["control"]])
}
scale_colour_arm <- function(context = FALSE, ...) ggplot2::scale_colour_manual(values = pal_arm(context), ...)
scale_fill_arm <- function(context = FALSE, ...) ggplot2::scale_fill_manual(values = pal_arm(context), ...)
