#' Compose, decompose and build prediction databases
#'
#' `decompose_filename` and `build_database` return a tabular database while
#' `compose_filename` returns a filename
#' 
#' @export
#' @param filename str, one or more filenames to decompose
#' @param ext str, the extension to strip (with dot)
#' @return a tabular database with these elements
#' 1. date Date, well, the date
#' 2. per str, period such as 'day' or 'mon'
#' 3. type str, descriptive where 'qNNN' is the N.NNth quantile
decompose_filename = function(filename = c('1993-01-01_day_q000.tif',
                                           "1993-01-01_mon_mean.tif"),
                              ext = ".tif"){
  x = basename(filename) |>
    stringr::str_replace(stringr::coll(ext[1]), "") |>
    stringr::str_split(stringr::coll("_"))

  dplyr::tibble(
    date = sapply(x, `[[`, 1) |> as.Date(format = "%Y-%m-%d"),
    per = sapply(x, `[[`, 2), 
    type = sapply(x, `[[`, 3))
}

#' @export
#' @rdname decompose_filename
#' @param x a tabular database
#' @param path str the path to the data
#' @param ext the filename extension to remove or apply (with dot)
#' @return one or more filepaths
compose_filename = function(x = decompose_filename(), 
                            path = ".", 
                            ext = ".tif"){

  name = sprintf("%s_%s_%s%s",
                 format(x$date, "%Y/%m/%d/%Y-%m-%d"),
                 x$per,
                 x$type,
                 ext[1])
  file.path(path, name)
}

#' Build a database
#' @export
#' @param path a path to a database directory or a configuration list
#' @param pattern str, the regex pattern to use for finding files
#' @param save_db logical, if `TRUE` then save the database
#' @return a tabular database
build_database = function(path = ".", 
                          pattern = "^.*\\.tif$", 
                          save_db = FALSE){
  if (inherits(path, "list") && all(c("species", "version") %in% names(path))){
    path = version_path(path, "preds")
  }
  x = list.files(path, recursive= TRUE, pattern = pattern, full.names = FALSE) |>
    decompose_filename()
  if (save_db) x = write_database(x, path)
  x
}


#' Read, write and append a database
#' 
#' @export 
#' @param path a path to a database directory or a configuration list
#' @param filename str the database file name
#' @return a tabular database
read_database = function(path = ".", filename = "database"){
  if (inherits(path, "list") && all(c("species", "version") %in% names(path))){
    path = version_path(path, "preds")
  }
  filename = file.path(path, filename)
  db = if(!file.exists(filename[1])){
    warning("database file not found: ", path)
    dplyr::tibble(date = Sys.Date(), per = "", type ="") |>
      dplyr::slice(0)
  } else {
    readr::read_csv(filename,
                    col_types = "Dcc")
  }
  db
}

#' Read, write and append a database
#' 
#' @export 
#' @rdname read_database
#' @param x a tabular database
#' @return the input tabular database
write_database = function(x, path = ".", filename = "database"){
  ok = make_path(path)
  readr::write_csv(x, file.path(path, filename))
}

#' Append to a database
#' 
#' @export
#' @rdname read_database
#' @param ... arguments passed to other functions such as `filename`
append_database = function(x, path = ".", ...){
  y = read_database(path, ...)
  dplyr::bind_rows(y, x) |>
    dplyr::distinct() |>
    write_database(path)
}
