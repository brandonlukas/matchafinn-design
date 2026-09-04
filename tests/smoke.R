# The one check: what the package exports is exactly what tokens.json says, and every hex is a hex.
library(mfdesign)
t <- tokens()
stopifnot(
  identical(names(pal), names(t$colour)),
  all(grepl("^#[0-9A-F]{6}$", c(pal, pal_tissue, pal_signal))),
  pal_signal[2] == pal[["atac"]],                # the signal ramp passes through the atac token
  identical(pal_signal_at, c(0, 0.37, 1)),
  length(pal_tissue) == 8,
  pal_ccre[["none"]] == pal[["rule"]], length(ramp("matcha", 3)) == 3,
  identical(unname(pal_arm(TRUE)["control"]), pal[["slate"]]),
  fs_label > fs_base, fs_base > fs_small, fs_small > fs_min, fs_min >= 5,
  inherits(theme_nature(), "theme"),
  is.list(theme_embedding())
)
# gene_track() must read exons the same way whether they arrive as a matrix or a list of pairs
gm <- list(list(name = "G", strand = "+", tx_start = 1e6, tx_end = 2e6,
                exons = matrix(c(1.1e6, 1.5e6, 1.2e6, 1.6e6), ncol = 2)))
ex <- ggplot2::layer_data(gene_track(gm, c(1, 2), marker = "G"), 4L)
stopifnot(all.equal(ex$xmin, c(1.1, 1.5)), all.equal(ex$xmax, c(1.2, 1.6)))

cat("mfdesign smoke: ok\n")
