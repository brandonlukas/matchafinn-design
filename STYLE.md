# Matcha + Finn figure design system

One visual language for every figure of the Matcha/Finn manuscript and all three code repos
(`matcha2`, `finn2`, `matchafinn-apps`). This file holds the **rules**; `inst/tokens.json` holds the
**values** (the only file allowed to contain a hex literal); the `mfdesign` R package derives
everything from it. `design-system.html` is the same system rendered. Discipline is Swiss
(hairlines, restraint, fewest sizes); the colour is ours.

Status of a rule: **held** = already true everywhere; **settle** = currently inconsistent, the
rule below is the resolution (applied 2026-08-28; the log is at the end).

## 1. Principles (from the moodboard, `mood.html`)

1. **Colour encodes identity, never emphasis.** A hue means one thing across the whole paper.
   Nothing is coloured to look important.
2. **Grey carries everything that is not the claim** — backgrounds, non-hits, nulls, context.
   Colour is reserved for what the method did.
3. **The null or threshold is drawn, not asserted** — dashed cutoffs, grey null tracks,
   a-priori constants labelled on the plot (`τ = 0.96`, `λ = 0.50`).
4. **One coordinate system, reused** — a row order or a locus window fixed once per figure
   (ideally per paper) so panels compare without being told to.
5. **Frames are nearly absent** — hairline axes, no gridlines, no boxes, no legend frames;
   panel titles as plain text.
6. **Schematics carry real thumbnails, not icons**, drawn in the same tokens as the data panels.
7. **Constraints first** — every glyph ≥ 5 pt at 1:1, verified by `audit_panel.py`, never eyeballed.

## 2. Colour tokens

Names are semantic. Panel scripts reference tokens (`pal[["matcha"]]`, `pal_arm()`), never hex
literals (§8 lint). Repo-specific *names* for tokens (`pal_method`, `pal_prior`) live in each repo's
`_common.R`. Muted throughout; saturation belongs to the two heroes.

### Heroes (the methods) — *settle*

| token | hex | meaning |
|---|---|---|
| `matcha` | `#3F8E6E` | Matcha: retrieval, embedding similarity, the rank |
| `finn` | `#33517F` | Finn: weights, the synthesized track, anything downstream of the blend |

Matcha green and Finn indigo are the paper's two families (per the identity). **Finn is indigo
everywhere** (`finn2/helpers.R` `pal_method` included; Fig 1a and Fig 3 show both methods). Deep tints (`#1F6F52`, identity matcha) are for screen text
and slides, not for marks.

### Neutrals (true greys, chroma 0; the green-tinted family, warm greys and `greyNN` retire) — *settle*

| token | hex | role |
|---|---|---|
| `ink` | `#000000` | all text, axes, ticks, track baselines (print black; `#141C18` is the screen identity only) |
| `muted` | `#767676` | secondary text: in-panel annotations, threshold labels, rank/context labels |
| `slate` | `#989898` | **neutral data**: the primary baseline method (RP+PCA, pooling), non-hit bars, unranked points |
| `rule` | `#DCDCDC` | hairlines, evidence-row rules, zoom leaders, ghost points (ATAC cloud behind an exemplar), "Other" tissue, shaded bands, the cosine < 0 flat, the random/prevalence floor, the motif null |

Panels export **transparent** and are always assumed to sit on white; there is no ground token.

Reading: *colour = the hero acted; slate = a competitor; rule-grey = nothing tried (null, floor,
context).* Two or more baselines in one panel → slate lightness ramp (`muted` → `slate` → `rule`)
with shape/linetype as the redundant channel; never a second hue.

### Modality — *held*

| token | hex | |
|---|---|---|
| `atac` | `#E0A458` | amber, the input (query ATAC track, ATAC points, an "ATAC-only" baseline) |
| `chip` | `#5B4B8A` | plum, the output/reference (ChIP points, consensus track, held-out gold) |

Lightness (amber light, plum dark) is the CVD backup; shape (ATAC ▲ / ChIP ●) where points mix.

### Accents — *settle*

| token | hex | meaning |
|---|---|---|
| `red` | `#E31A1C` | **the one red**: the query mark (ggplot shape 8 asterisk, all stroke, so it hides nothing). The hue absent from viridis. |
| `hit` | `#225EA8` | a same-context hit in a ranked list (Fig 2e bars); misses are `slate` |

### Arms — case / control — *settle*

| token | hex | meaning |
|---|---|---|
| `case` | `#AD547F` | rose: the disease/case arm (fibroid) — **always** |
| `control` | `#5FA19F` | teal: the healthy/control arm (myometrium) **when it is a compared arm** |

When the control is *context* rather than a comparison (a reference the case is read against), it
takes `slate` instead — principle 2, grey carries what is not the claim. `scale_colour_arm()` /
`scale_fill_arm()` (`context = TRUE` for the slate form). Rose and teal are the only hue arcs no
other token occupies (everything else is within ~45° of a hero, a modality or an accent); 14 L*
apart and opposite in a/b, so the pair survives every CVD type. Rose and `red` share L* ≈ 48 and
never share a panel (query → embeddings; arms → differential panels).

### Family ramps — ordered sub-categories — *settle*

When a category splits into *ordered* sub-categories, they are a **lightness ramp of the parent
hue** — dark for the focal / nearest / first, light for the rest — never new hues; new hues are spent
only on genuinely different families (`ramp(token, n)`). Baselines already do this
(`muted → slate → rule`); a method's ablations are tints of the method's hue.

### cCRE classes — *settle*

`pal_ccre` for ENCODE SCREEN composition bars: **PLS → pELS → dELS** is one olive ramp
(`#596330 → #87905E → #B8C093`; ordinal by distance to TSS, light for dELS because it dominates
every bar), **CTCF / CA / TF** collapse to one dusty blue `#708FA5` (TF-binding-defined, not
histone-defined; C 16 so it never reads as `hit`), **none** is `rule`. Olive is the last hue arc
more than 40° from every token; SCREEN's own red/orange/yellow/blue would collide with `red`, `atac`
and `hit`.

### Tissue / many-category — *held*

`pal_tissue`, 8 desaturated hues + `rule` for "Other" (context, not a competitor — and light enough
that the grey 8th hue still reads); cap at 8. Only for the case where colour is
the sole encoder and illustrative (a UMAP by tissue). Its hues are **not** available for other
meanings (motif is `rule` grey, not a tissue rose).

### Continuous scales — three ramps, keyed to what they measure — *settle*

- **Signal (read density: deeptools-style heatmaps, tracks):** `pal_signal`, white → `atac` →
  umber `#6E3013`, through the atac token so an accessibility heatmap is visibly ATAC-coloured; it
  ends in umber, not red, so it never quotes `red`. Clip at the 98th percentile (deeptools' zMax).
- **Score (cosine, co-binding r, −log10 p_adj, AUPRC — any abstract 0–1 quantity):** viridis on
  0–1; values below 0 collapse to `rule` grey on the same bar (`scale_fill_cosine()`). Co-binding r
  is one-directional in practice (nearly all r ≥ 0) so it takes this ramp, not a diverging one.
  p_adj takes it as −log10 with count as size — never clusterProfiler's blue → magenta → red,
  a two-ended ramp on a one-ended quantity that would quote both `hit` and `red`.
- **Diverging (differential binding):** `control` teal ↔ white ↔ `case` rose
  (`colorspace::diverging_hcl(n, h = c(195, 350), c = 42, l = c(48, 97))`), so "more in disease"
  and "the disease arm" are one hue. Not red ↔ blue: `red` is the query and `hit` is blue, and a
  colourbar must not borrow either meaning.

## 3. Type — *held*

Arial (svglite default; schematics `FONT = "Arial"`), black, upright, sentence case.

| token | pt | role |
|---|---|---|
| `fs_label` | **8 Arial Black** | panel letter, added in Inkscape only (never by a script), lowercase |
| `fs_base` | 7 | axis titles, legend titles, strip titles, panel title, schematic stage titles, on-plot stars/effect labels |
| `fs_small` | 6 | tick labels, legend text, most in-panel annotation, direct labels, embedding axis words |
| `fs_min` | 5 | dense text only: rank/context labels on bars, gene names, track strips, schematic numerals |

Three sizes per panel at most. `geom_text(size = pt2mm(fs_*))` — never a bare number.
Gene names italic; TF names upright. Numbers: cosine 2 dp, weights/AUPRC 3 dp, `tabular-nums`
in tables. Panel titles (`BCL6`) plain 7 pt, left-aligned at the axis origin; schematic stage
titles centred over the stage.

## 4. Strokes, points, dashes — *settle*

| | value | use |
|---|---|---|
| hairline | 0.25 pt | gene introns, evidence rules, zoom leaders, dashed thresholds, schematic connectors |
| rule | 0.4 pt | axes, ticks, track baselines, zoom source box  |
| emphasis | 0.6 pt | data lines (curves, freqpoly), CI bars, gene exons |
| dash | `linetype = "22"` | a-priori constants and thresholds, always `muted`, labelled on the plot |
| point · cloud | 0.18, α 0.6, rasterised 900 dpi | dense embeddings |
| point · data | 1.0 | swarms, scatter |
| point · mean / key | 1.6 | legend keys (`override.aes`), summary points |
| point · query | 3 × pt^0.5 | the asterisk; scales sub-linearly with zoom |

## 5. Legends and labels

- **Direct labels beat legends.** Label clusters/lines on the plot (`muted`, `fs_small`) when
  ≤ 8 items fit; a legend only when they don't.
- Each legend **once per figure**; a key shared by two panels lives between them.
- Placement priority: inside the panel's dead space → top-left above the panel, horizontal,
  left-justified → right of the panel. Keys `unit(7, "pt")`. Colourbars
  vertical at the right, 6 pt wide, one per figure. No legend background or frame.
- Row/track labels sit **left as horizontal strips**, vertically centred on their row, so a label
  is tied to one track. Ranks as `#1`; context names in `muted`.

### Heatmaps — the one place a frame is allowed — *settle*

- **Frame:** `ink` 0.4 pt around the raster only (a raster needs an extent) — not the profile,
  not the figure. Principle 5 holds everywhere else.
- **Row groups:** a left strip, 3 mm, filled with the group's own token (arms, cCRE class,
  tissue); the block's label sits *inside* the strip (white, rotated, `fs_small`) when the block
  is tall enough, outside as a horizontal title when it is not.
- **Profile:** a mean-signal line above each heatmap, one line per row group in the group's
  colour — the strip is its legend. Tick-only y axis, no label (the unit goes in the caption).
- **One stroke weight:** frame, profile box + axis and colourbar border are all `rule` 0.4 pt.
  ComplexHeatmap draws several of these at its default lwd with no argument, so set the default
  through a parent viewport: `pushViewport(viewport(gp = gpar(lwd = 0.4 / 0.75)))` around `draw()`.
- **Resolution:** rasterise at ≥ 600 dpi with ≥ 1 bin per output pixel (small `binSize`,
  `raster_quality` high) so it reads as continuous, not blocky. Rows sorted by mean signal.
- **Colourbar:** vertical at the right, 2 mm wide, tick-only (no title), ticks and labels
  *outside* to the right in `fs_min` at even (`pretty`) increments, the bar running past the last
  tick to the clipped max — `mfdesign::colourbar()`
  (ComplexHeatmap's own draws ticks inside); one per figure, a shared scale across the panels it serves.

## 6. Layout and assembly

- **Canvas:** **180 mm** wide (Genome Biology; ≤ 225 mm tall. Panels exported at their final mm box, placed **1:1 in Inkscape, never scaled**.
- **Grid:** 8 mm gutters; align axis origins across a row and left edges down a column; one
  baseline per row. Verify with `grid_overlay.py` (muller-brockmann skill).
- **Panel letters:** 8 pt Arial Black lowercase, top-left, a fixed 1 mm outside the panel's ink box.
- **Zoom / magnifier:** source box `ink` 0.4 pt on the full view; two `rule`-grey 0.25 pt leaders
  to the zoom's corners; the zoom shows exactly the boxed region (`expand = FALSE`).
- **Schematics:** 1 unit = 1 mm, same tokens, flat fills, 0.18 pt outlines, arrows with the
  theme_embedding head (closed, 22°, 0.3 lines).
- Figure narratives (act structure, which panel zooms into which) are per-repo: `ASSEMBLY.md`.

## 7. Export pipeline — *held*

```r
library(mfdesign)                                   # once per repo, in panels/_common.R
save_panel(p, "<letter>_<what>", width_mm, height_mm)  # SVG (svglite) + PDF + PNG, transparent
crop_panel("<letter>_<what>")                          # trim to visible ink (aspect-ratio panels)
split_panel("bc_x", "b_x", "c_x")                      # two-cell patchwork → equal standalone halves
```

Names: `<letter>_<what>.svg` inside a per-figure folder; supplementary variants add a suffix
(`_FOXO1`). SVG/PDF are the deliverables, PNG the preview. Text stays text until the final
flattened submission copy.

## 8. Enforcement — two checks

```bash
# 1. no hex or greyNN literals in panel scripts (tokens only); expect no output
grep -nE '#[0-9A-Fa-f]{6}|"grey[0-9]+"|"gray[0-9]+"' make_figures/**/*.R
# 2. font floor / width at 1:1
python3 .claude/skills/scientific-figure-design/scripts/audit_panel.py figures/panels/*.svg
```

**Sharing across repos:** this repo is the single source. Each repo's `_common.R` does
`library(mfdesign)` (installed once per machine: `pak::pkg_install("brandonlukas/matchafinn-design")`)
and keeps only its own token *names*. Python/web consumers read `inst/tokens.json`. No vendored
copies, no cross-repo `source()` paths. Changing a token = edit `tokens.json` + the rule here, bump
the version, reinstall, re-render.

## 9. Decisions log

2026-08-28 — canvas 180 mm; one red (`brick`) for query and disease; diverging = brick ↔ blue;
same-context hit bars keep `hit` blue (not matcha green); motif baseline = `rule` grey null.

2026-08-29 — neutrals drop to chroma 0 (pure greys at the same lightness as the green-tinted
values they replace); `fs_label` is Arial Black, Inkscape-only; `ground` dropped (four neutrals); tissue "Other" = `rule`
(it was `grey80` at the annual-review tag and had drifted to `slate`); the red accent is the
annual-review query red `#E31A1C` (token `red`, replacing `brick #A33A2E`); two accents, `red` + `hit`;
arms `case` rose / `control` teal (slate when the control is context); diverging = teal ↔ rose.
Finn stays `#33517F` (brighter indigo lands on `hit`'s hue; the dark one reads as authoritative).
Three continuous ramps: signal (`pal_signal`, through atac), score (viridis), diverging (arms).
Heatmaps get an ink frame and token-coloured row-group strips.

2026-08-29 — the system moves to its own repo (`matchafinn-design`, the `mfdesign` package);
matcha2 is the first consumer. Figure-specific rules (acts, d→d zoom letters, dp) go to each
repo's `ASSEMBLY.md`.

2026-08-29 — v1.1.0: `pal_ccre` and `ramp()` (family ramps); matchafinn-apps is the second consumer.
