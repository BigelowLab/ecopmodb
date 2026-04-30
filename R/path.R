#' Retrieve the root data path
#' 
#' @export
#' @param ... other path segments to append to the root
#' @param root chr the root data path
#' @return the root data path
root_data_path = function(...,
                          root = get_root_data_path()){
  file.path(root, ...)
}

#' Set the root data path in a hidden file in the user's home
#' directory.
#' 
#' @export
#' @param path chr, the root data path
#' @param filename chr, the file where the path is stored
#' @param create logical, if TRUE create the path if it doesn't exist
#' @return the input path
set_root_data_path = function(path = ".",
                              filename = "~/.ecopmo",
                              create = TRUE){
  if (create[1]){
    if (!dir.exists(path)) ok = dir.create(path, recursive = TRUE)
  }
  cat(path, "\n", sep = "", file = filename)
  return(path)
}

#' @rdname set_root_data_path
#' @export
get_root_data_path = function(filename = "~/.ecopmo"){
  readLines(filename)
}


#' Create a path if it doesn't exist
#' 
#' @export
#' @param path str one or more path descriptions
#' @param recursive logical, if TRUE then make intermediary paths as needed
#' @param ... other arguments for `dir.create`
#' @return the input path(s)
make_path = function(path, recursive = TRUE, ...){
  sapply(path,
         function(p){
           if (!dir.exists(p)) {
             ok = dir.create(p, recursive = recursive[1],...)
           }
           p
         }) |>
    unname()
}

#' Generate a species path
#' 
#' @export
#' @param cfg a configuration list
#' @param ... other path segments to add (by default none), 
#'   these must appear before `root`
#' @param root str, the root data path
#' @return the species or version data path
species_path = function(cfg,
                        ...,
                        root = root_data_path()){
  file.path(root, cfg$species, ...)
}

#' Generate a version path from a version configuration
#' 
#' @rdname species_path
#' @export 
version_path = function(cfg,
                        ...,
                        root = root_data_path()){
  
  
  # ver = Major, minor, release (M, m, r)
  # <root>/species/versions/M/ver
  v = parse_version(cfg$version[1])
  file.path(root,
            cfg$species,
            "versions",
            v[['major']],
            cfg$version,
            ...)
}

#' Parse a version string
#'
#' Versions have the format Major.Minor.Release
#'
#' @export
#' @param x version string to parse
#' @param sep character, by default '.' but any single character will do 
#' @return named character vector
parse_version <- function(x = 'v2.123.1', sep = "."){
  xx = strsplit(x, sep[1], fixed = TRUE)[[1]]
  c(major = xx[1], minor = xx[2], release = ifelse(length(xx) == 3, xx[3], NA))
}


#' Build a version string from components
#'
#' Versions have the format vMajor.Minor.Release
#'
#' @export
#' @param major string, like '3' or a named vector with (major, minor, [release])
#' @param minor string, like '13', ignored if major has length > 1
#' @param release string, optional like '002', ignored if major has length > 1
#' @param sep character, by default '.' but any single character will do 
#' @return version string like 'v3.13.002'
build_version <- function(major, minor, release, sep = "."){
  if(missing(major)) stop("major is required")
  if (length(major) >= 2){
    v = paste(major, collapse = sep[1])
  } else {
    if(missing(minor)) stop("minor is required")
    v = paste(major, minor[1], sep  = sep[1])
    if(!missing(release)) v = paste(v, release[1], sep  = sep[1])
  }
  v
}

#' Given a path - make it if it doesn't exist
#'
#' @export
#' @param path character, the path to check and/or create
#' @param recursive logical, create paths recursively?
#' @param ... other arguments for \code{dir.create}
#' @return the path
make_path <- function(path, recursive = TRUE, ...){
  ok <- dir.exists(path[1])
  if (!ok){
    ok <- dir.create(path, recursive = recursive, ...)
  }
  path
}
