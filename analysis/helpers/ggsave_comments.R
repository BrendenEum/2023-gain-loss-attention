#' Save a ggplot with comments in the metadata
#'
#' Performs a normal call to `ggsave` from the package `ggplot2` to save a plot,
#' then uses ExifTool (https://exiftool.org/) via the package `exifr` to
#' overwrite metadata comments with the specified comments.
#'
#' @param filename Relative or absolute path of plot save destination
#' @param ... Other arguments to `ggsave`
#' @param comments Comments to write in metadata; if NA, won't touch existing
#'    metadata
#' @returns ExifTool exit code (0 = success)
#' @examples
#' ggsave_comments("my_plot.png", comments = "This is my comment")
#' ggsave_comments(
#'    filename = "figs/big_plot.jpg",
#'    scale = 3,
#'    comments = "my_plot but with scale = 3")
ggsave_comments <- function(filename, ..., comments = NA) {
  require(exifr)
  require(ggplot2)
  
  #' Helper function to edit file metadata
  #'
  #' Formats arguments for and calls ExifTool to overwrite metadata of
  #' specified tags. ExifTool option `overwrite_original_in_place` is used to
  #' avoid generating extra files. The contents of each metadata tag in `tags`
  #' of the file at `filename` are overwritten with the comments specified in
  #' `ggsave_comments`.
  #'
  #' @param tags A single metadata tag or vector of tags to overwrite
  #' @param filename Relative or absolute path of file to edit
  #' @returns ExifTool exit code (0 = success)
  #' @examples
  #' ggsave_helper("my_plot.png", "Description")
  #' ggsave_helper("figs/my_plot.jpg", c("Description", "UserComment"))
  ggsave_helper <- function(filename, tags) {
    formatted_tags <- c(
      paste0("-", tags, '="', comments, '"'),
      "-overwrite_original_in_place"
    )
    exiftool_call(args = formatted_tags, fnames = filename, quiet = TRUE)
  }
  
  standard_tags <- c(
    "Description", # Generic
    "XPComment", # Windows?
    "UserComment" # Windows?
  )
  ggsave(filename, ...)
  if (!is.na(comments)) {
    if (Sys.info()["sysname"] == "Darwin") {
      # Save in MacOS Finder comments as well
      # Requires separate call to exiftool, not sure why
      ggsave_helper(filename = filename, tags = "MDItemFinderComment")
    }
    ggsave_helper(filename = filename, tags = standard_tags)
  }
}