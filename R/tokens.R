# The single source of truth is inst/tokens.json. R evaluates package code with the source root as
# the working directory at install time, so every exported object is derived from that file here —
# nothing is typed twice. Non-R consumers read the same file: tokens_path() gives its installed
# location, or read it from the repo directly.
.tokens <- jsonlite::read_json("inst/tokens.json", simplifyVector = TRUE)

#' The design tokens as a list (colour, tissue, signal, type_pt, stroke_pt, point, canvas_mm).
tokens <- function() .tokens

#' Path of the installed tokens.json (for Python / web consumers on the same machine).
tokens_path <- function() system.file("tokens.json", package = "mfdesign")
