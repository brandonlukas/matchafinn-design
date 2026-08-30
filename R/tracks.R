# Genome-track furniture. gene_track() draws gene models under a signal stack (STYLE.md §6): the
# marker gene(s) in ink, co-located genes in slate, exons as boxes, strand arrowheads along the
# intron, italic names above. x is in Mb so it aligns with a signal plot drawn on the same scale.
#   models  list of {name, strand, tx_start, tx_end, exons = list(c(s, e), ...)} (matcha's
#           parse_gtf_gene_models output, or a data.frame with those columns)
#   xlim    window in Mb; models are clamped to it
#   marker  gene names drawn prominent (all, if none match)
gene_track <- function(models, xlim, marker = character(), chrom = NULL) {
  gms <- models
  ng <- if (is.data.frame(gms)) nrow(gms) else length(gms)
  if (ng == 0) return(NULL)
  col <- function(f) if (is.data.frame(gms)) gms[[f]] else vapply(gms, function(g) g[[f]], gms[[1]][[f]])
  name <- as.character(col("name")); strand <- as.character(col("strand"))
  ts_bp <- as.numeric(col("tx_start")); te_bp <- as.numeric(col("tx_end"))
  exl <- if (is.data.frame(gms)) gms$exons else lapply(gms, `[[`, "exons")
  marker <- toupper(marker)
  # greedy row-packing on the window-clamped span so overlapping genes do not collide
  gs <- pmax(ts_bp / 1e6, xlim[1]); ge <- pmin(te_bp / 1e6, xlim[2])
  row_of <- integer(ng); row_end <- numeric(0)
  for (i in order(gs)) {
    r <- which(gs[i] > row_end); r <- if (length(r)) r[1] else length(row_end) + 1
    row_of[i] <- r; row_end[r] <- ge[i]
  }
  nr <- max(row_of)
  introns <- exons <- arrows <- labs <- NULL
  for (i in seq_len(ng)) {
    prom <- toupper(name[i]) %in% marker
    y <- nr - row_of[i] + 1
    ts <- max(ts_bp[i] / 1e6, xlim[1]); te <- min(te_bp[i] / 1e6, xlim[2]) # clamp to the window
    introns <- rbind(introns, data.frame(x = ts, xend = te, y = y, prom = prom))
    ex <- exl[[i]]
    if (!is.null(ex) && length(unlist(ex)) >= 2) {
      em <- matrix(as.numeric(unlist(ex)), ncol = 2, byrow = TRUE) / 1e6
      em <- cbind(pmax(em[, 1], xlim[1]), pmin(em[, 2], xlim[2]))
      exons <- rbind(exons, data.frame(xmin = em[, 1], xmax = em[, 2], y = y, prom = prom)[em[, 2] > em[, 1], ])
    }
    if (te > ts) {
      pts <- seq(ts, te, length.out = 7)[2:6]
      tip <- diff(xlim) * 0.012 * (if (strand[i] == "-") -1 else 1)
      arrows <- rbind(arrows, data.frame(x = pts, xend = pts + tip, y = y, prom = prom))
    }
    labs <- rbind(labs, data.frame(x = (ts + te) / 2, y = y + 0.55, lab = name[i], prom = prom))
  }
  if (!any(introns$prom)) introns$prom <- arrows$prom <- labs$prom <- TRUE
  if (!is.null(exons) && !any(exons$prom)) exons$prom <- TRUE
  pal_gene <- c(`TRUE` = pal[["ink"]], `FALSE` = pal[["slate"]])
  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(data = introns, ggplot2::aes(x, y, xend = xend, yend = y, colour = prom), linewidth = 0.25) +
    ggplot2::geom_segment(data = arrows, ggplot2::aes(x, y, xend = xend, yend = y, colour = prom),
      arrow = grid::arrow(length = grid::unit(0.5, "mm"), type = "open"), linewidth = 0.25) +
    ggplot2::geom_text(data = labs, ggplot2::aes(x, y, label = lab, colour = prom), fontface = "italic",
      size = pt2mm(fs_min), vjust = 0) +
    ggplot2::scale_colour_manual(values = pal_gene) + ggplot2::scale_fill_manual(values = pal_gene) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = c(0.5, nr + 1.1), clip = "off") +
    ggplot2::labs(x = if (is.null(chrom)) "Mb" else sprintf("%s (Mb)", chrom), y = NULL) +
    ggplot2::guides(colour = "none", fill = "none") +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_blank(), panel.grid = ggplot2::element_blank())
  if (!is.null(exons)) {
    p <- p + ggplot2::geom_rect(data = exons, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = y - 0.26, ymax = y + 0.26, fill = prom))
  }
  p
}
