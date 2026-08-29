# Export a SINGLE panel as a standalone vector for hand-assembly in a vector editor (Inkscape).
# This is the production path: the final figure is pieced together from these standalone panels in
# post — in Inkscape (panel tags, cross-panel zoom leaders, any
# schematics are added there — NOT here). SVG via svglite keeps text editable and ungroupable;
# dense rasterised layers (ggrastr) embed as raster inside the SVG. Export at the FINAL print box so
# panels are placed 1:1 — never scale in the editor (it distorts stroke widths and text). A PDF
# backup + a PNG preview are written alongside.
save_panel <- function(plot, name, width_mm, height_mm, dir = "figures/panels", png = TRUE) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(dir, name)
  ggplot2::ggsave(paste0(path, ".svg"), plot,
    width = width_mm, height = height_mm, units = "mm",
    device = svglite::svglite, bg = "transparent"
  )
  pdf_device <- if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else "pdf"
  ggplot2::ggsave(paste0(path, ".pdf"), plot,
    width = width_mm, height = height_mm, units = "mm",
    device = pdf_device, bg = "transparent"
  )
  if (png) {
    ggsave(paste0(path, ".png"), plot,
      width = width_mm, height = height_mm, units = "mm",
      dpi = 900, bg = "transparent"
    )
  }
  invisible(plot)
}

# ---- Tighten an export to its visible-ink box -----------------------------
# Aspect-ratio plots + legends leave dead margins inside the nominal canvas (e.g. the embeddings).
# crop_panel() reframes the SVG viewBox and crops the PDF/PNG to the visible-ink bbox via ghostscript
# — which correctly ignores svglite's transparent full-canvas background (Inkscape's --export-area-
# drawing does NOT, so it can't crop these). Call it right after save_panel(). Re-render-safe; a
# no-op (with a message) if the tools are missing, so PC renders without ghostscript still work.
crop_panel <- function(name, dir = "figures/panels") {
  pad_pt <- 2
  base <- file.path(dir, name)
  svg <- paste0(base, ".svg")
  pdf <- paste0(base, ".pdf")
  png <- paste0(base, ".png")
  gs <- Sys.which("gs")
  if (!nzchar(gs)) {
    message("crop_panel: ghostscript (gs) not on PATH — skipping ", name,
            " [interactive R/RStudio may not inherit the shell PATH; launch R from a terminal]")
    return(invisible(FALSE))
  }
  if (!file.exists(pdf)) {
    message("crop_panel: PDF not found for ", name, " — skipping")
    return(invisible(FALSE))
  }
  # Visible-ink bbox in PDF points (origin bottom-left), padded slightly.
  out <- system2(gs, c("-dNOPAUSE", "-dBATCH", "-q", "-sDEVICE=bbox", pdf), stdout = TRUE, stderr = TRUE)
  hi <- grep("HiResBoundingBox", out, value = TRUE)[1]
  bb <- as.numeric(strsplit(trimws(sub(".*HiResBoundingBox:", "", hi)), "\\s+")[[1]]) # x0 y0 x1 y1
  bb <- bb + c(-pad_pt, -pad_pt, pad_pt, pad_pt)

  # SVG: reframe the viewBox. SVG y runs top-down, so flip the box using the canvas height.
  if (file.exists(svg)) {
    s <- readLines(svg, warn = FALSE)
    h <- grep("<svg", s)[1]
    vb <- as.numeric(strsplit(gsub("viewBox='|'", "", regmatches(s[h], regexpr("viewBox='[^']+'", s[h]))), " ")[[1]])
    nx <- bb[1]
    ny <- vb[4] - bb[4]
    nw <- bb[3] - bb[1]
    nh <- bb[4] - bb[2]
    line <- s[h]
    line <- sub("width='[^']+'", sprintf("width='%.2fpt'", nw), line)
    line <- sub("height='[^']+'", sprintf("height='%.2fpt'", nh), line)
    line <- sub("viewBox='[^']+'", sprintf("viewBox='%.2f %.2f %.2f %.2f'", nx, ny, nw, nh), line)
    s[h] <- line
    writeLines(s, svg)
  }
  # PDF + PNG: regenerate from the (now tight) SVG via Inkscape, so all three share the cropped frame.
  render_svg(base)
  invisible(TRUE)
}

# Re-render `<base>.svg` to PDF + PNG siblings via Inkscape (no-op with a message if it's missing).
render_svg <- function(base, dpi = 600) {
  ink <- Sys.which("inkscape")
  svg <- paste0(base, ".svg")
  if (!nzchar(ink) || !file.exists(svg)) {
    message("render_svg: inkscape missing — PDF/PNG not regenerated for ", basename(base))
    return(invisible(FALSE))
  }
  system2(ink, c(svg, "--export-type=pdf", paste0("--export-filename=", base, ".pdf")), stdout = FALSE, stderr = FALSE)
  system2(ink, c(svg, "--export-type=png", sprintf("--export-dpi=%d", dpi), paste0("--export-filename=", base, ".png")),
    stdout = FALSE, stderr = FALSE)
  invisible(TRUE)
}

# ---- Split a two-cell patchwork export into two standalone panels ---------
# A side-by-side patchwork (p1 | p2) is rendered as ONE SVG so both plots are guaranteed the same
# size; this cuts that export, post hoc, into `<left>.svg` / `<right>.svg` (+ PDF/PNG) that are
# exactly the two cells — equal boxes, 1:1 with the combined export, so they place independently in
# Inkscape. Works on svglite's one-element-per-line output: the two cells are the pair of equal-width
# clip rects that tile (left ends where right begins); every drawn element is assigned to a side by
# its x. Call after save_panel()/crop_panel() (the cropped viewBox sets the vertical extent).
split_panel <- function(name, left, right, dir = "figures/panels") {
  s <- readLines(file.path(dir, paste0(name, ".svg")), warn = FALSE)
  attr1 <- function(lines, key) as.numeric(sub(sprintf(".*%s='([^']+)'.*", key), "\\1", lines))
  # Cells: clipPath rects (indented, inside <defs>) — find the adjacent equal-width pair.
  cl <- s[grepl("^ +<rect x=", s)]
  cx <- attr1(cl, "x"); cw <- attr1(cl, "width")
  pair <- NULL
  for (i in seq_along(cl)) for (j in seq_along(cl)) {
    if (abs(cx[i] + cw[i] - cx[j]) < 0.05 && abs(cw[i] - cw[j]) < 0.05) pair <- c(i, j)
  }
  if (is.null(pair)) stop("split_panel: no two adjacent equal-width cells found in ", name)
  split_x <- cx[pair[2]]
  cell_w <- cw[pair[1]]

  h <- grep("<svg", s)[1]
  vb <- as.numeric(strsplit(regmatches(s[h], regexpr("(?<=viewBox=')[^']+", s[h], perl = TRUE)), " ")[[1]])
  # Drawn elements sit at column 0; their x is `x=`, `cx=`, `points='x,` or `translate(x,`.
  drawn <- grepl("^<(image|circle|text|polyline|polygon|line|path|rect) ", s) &
    grepl(" (x|cx|points)='|translate\\(", s)
  ex <- rep(NA_real_, length(s))
  ex[drawn] <- as.numeric(sub(".*?(?: (?:x|cx|points)='|translate\\()([-0-9.]+).*", "\\1", s[drawn], perl = TRUE))

  write_side <- function(out, x0, keep) {
    o <- s[!drawn | keep]
    o[h] <- sub("viewBox='[^']+'", sprintf("viewBox='%.2f %.2f %.2f %.2f'", x0, vb[2], cell_w, vb[4]),
      sub("width='[^']+'", sprintf("width='%.2fpt'", cell_w), o[h]))
    base <- file.path(dir, out)
    writeLines(o, paste0(base, ".svg"))
    render_svg(base)
  }
  write_side(left, cx[pair[1]], ex < split_x)
  write_side(right, split_x, ex >= split_x)
  invisible(NULL)
}

# ---- Export just a plot's legend -----------------------------------------
# Save ONLY the colour key (dots + labels) of a plot to its own SVG, so the assets can be ungrouped
# in Inkscape and placed by hand — e.g. as direct cluster labels on an embedding (the panel itself
# then carries no legend). Pairs well with crop_panel() to tighten the result.
# `values` is a named colour vector (names = labels, in the order to stack top→bottom). Builds a
# simple dot+label key (reliable sizing, unlike extracting the legend gtable) and crops it tight.
save_legend <- function(values, name, dir = "figures/panels", dot = 2) {
  k <- data.frame(
    lab = factor(names(values), levels = names(values)),
    y = rev(seq_along(values))
  )
  p <- ggplot2::ggplot(k, ggplot2::aes(0, y, colour = lab)) +
    ggplot2::geom_point(size = dot, stroke = 0) +
    ggplot2::geom_text(ggplot2::aes(x = 0.45, label = lab),
      hjust = 0, size = pt2mm(fs_small), colour = "black"
    ) +
    ggplot2::scale_colour_manual(values = values, guide = "none") +
    ggplot2::scale_x_continuous(limits = c(-0.3, 10), expand = c(0, 0)) +
    ggplot2::theme_void()
  save_panel(p, name, width_mm = 50, height_mm = max(10, length(values) * 4.5), dir = dir, png = FALSE)
  crop_panel(name, dir = dir)
}

