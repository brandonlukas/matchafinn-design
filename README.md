# matchafinn-design

The shared figure design system of the Matcha/Finn repos (`matcha2`, `finn2`, `matchafinn-apps`)
— one source of truth, imported by every `make_figures/`.

- **`inst/tokens.json`** — the tokens: colours, tissue set, signal ramp, type/stroke/point scales,
  canvas. The only file allowed to contain a hex literal.
- **`STYLE.md`** — the rules (what each token means, when a frame is allowed, the three ramps…).
- **`design-system.html`** — the same system rendered visually, for review.
- **`R/`** — the `mfdesign` package (the export list is `NAMESPACE`): tokens as R objects, the
  scales, `theme_nature()`, the axis/bar helpers and the panel export helpers. Everything is
  derived from `tokens.json` at install.

## Use

```r
# once per machine / env
pak::pkg_install("brandonlukas/matchafinn-design")   # or: R CMD INSTALL path/to/matchafinn-design

# in a repo's make_figures/panels/_common.R
library(mfdesign)
theme_set(theme_nature())
pal_method <- c("Matcha" = pal[["matcha"]], "RP+PCA" = pal[["slate"]])   # repo-specific names only
```

Python / web: read `inst/tokens.json` (`mfdesign::tokens_path()` gives the installed copy).

## Change a token

Edit `inst/tokens.json` (and the rule in `STYLE.md`), bump `Version` in `DESCRIPTION`, reinstall,
re-render. `Rscript tests/smoke.R` checks the exports against the file.
