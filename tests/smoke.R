# The one check: what the package exports is exactly what tokens.json says, and every hex is a hex.
library(mfdesign)
t <- tokens()
stopifnot(
  identical(names(pal), names(t$colour)),
  all(grepl("^#[0-9A-F]{6}$", c(pal, pal_tissue, pal_signal))),
  pal_signal[2] == pal[["atac"]],                # the signal ramp passes through the atac token
  length(pal_tissue) == 8,
  pal_ccre[["none"]] == pal[["rule"]], length(ramp("matcha", 3)) == 3,
  identical(unname(pal_arm(TRUE)["control"]), pal[["slate"]]),
  fs_label > fs_base, fs_base > fs_small, fs_small > fs_min, fs_min >= 5,
  inherits(theme_nature(), "theme"),
  is.list(theme_embedding())
)
cat("mfdesign smoke: ok\n")
