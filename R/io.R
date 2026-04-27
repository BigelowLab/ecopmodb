#' Read raster predictions 
#' 
#' @export
#' @param db data frame of file database
#' @param path chr, the path to the database
#' @param threshold num or NULL, if numeric then threshold the data to be 
#'   greater than or equal to this value.
#' @return stars object
read_ecopmo = function(db, path, threshold = NULL){
  cnt = dplyr::count(db, .data$per)
  if (nrow(cnt) > 1) {
    stop("please filter database such that it has only one value for 'per'")
  }
  cnt = dplyr::count(db, type)
  if ( (nrow(cnt) > 1) && (length(unique(cnt$n)) > 1) ){
    stop("if multiple types requested they must all share the same number of records")
  }
  
  # for each type - read in all of the dates
  db |>
    dplyr::arrange(.data$type, .data$date) |>
    dplyr::group_by(.data$type) |>
    dplyr::group_map(
      function(grp, key){
        files = compose_filename(grp, path)
        s = stars::read_stars(files, along = list(date = grp$date)) |>
          rlang::set_names(grp$type[1])
        if (!is.null(threshold)) s[1] = s[1] >= threshold[1]
        s
      }, .keep = TRUE) |>
    andreas::bind_attrs()
} 
