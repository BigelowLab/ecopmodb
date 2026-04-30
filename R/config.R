#' Read, write and configurations
#' 
#' @export
#' @param cfg list, configuration list
#' @param filename str the file description, not required but overrides the 
#'   automatic construction of the output filename.  When reading a config, 
#'   `filename` is ignored if species (and possibly version) are provided.
#' @param root chr, the root data path, only required if `filename` is missing
#' @return configuration list (invisibly)
write_configuration <- function(cfg, filename,
                                root = root_data_path()){
  if (missing(filename) && !is.null(cfg$version)) {
    v = parse_version(cfg$version[1])
    # mysids/versions/v0/v0.00/v0.00.yaml
    filename = file.path(root, cfg$species[1],
                         "versions",
                         v[['major']],
                         cfg$version[1],
                         paste0(cfg$version[1], ".yaml"))
  } else {
    stop("filename must be provided if config is not a version config")
  }
  yaml::write_yaml(cfg, filename)
  invisible(cfg)
}
#' @export
#' @rdname write_configuration
#' @param species chr or NULL, if chr search for the species config in `root` If 
#'   not `NULL` then filename is ignored.
#' @param version chr or NULL, if this and species are not NULL then search for the
#'   version config in `root/species`
read_configuration <- function(filename,
                               species = NULL,
                               version = NULL,
                               root = root_data_path()) {
  
  if (!is.null(species)){
    if (!is.null(version)){
      v = parse_version(version[1])
      # mysids/versions/v0/v0.00/v0.00.yaml
      filename = file.path(root, species[1],
                           "versions",
                           v[['major']],
                           version[1],
                           paste0(version[1], ".yaml"))
    } else {
      filename = file.path(root, species[1], paste0(species[1], ".yaml"))
    }
  }
  if (!file.exists(filename[1])) stop("filename not found:", filename[1])
  yaml::read_yaml(filename[1])
}
#' @export
#' @rdname write_configuration
#' @param species str, the species name
#' @param root the root data path
#' @return str, zero or more versions attached to this species
list_configurations = function(species = "testspecies",
                               root = root_data_path()){
  vpath = file.path(root, species[1], "versions")
  list.files(vpath, 
             recursive = TRUE, 
             pattern = "^.*\\.yaml$", 
             full.names =  TRUE)
}


#' Parse a version string
#'
#' Versions have the format vMajor.Minor.Release
#'
#' @export
#' @param x version string to parse
#' @param sep character, by default '.' but any single character will do 
#' @return named character vector
parse_version <- function(x = 'v2.123.1', sep = "."){
  xx = strsplit(x, sep[1], fixed = TRUE)[[1]]
  c(major = xx[1], minor = xx[2], release = ifelse(length(xx) == 3, xx[3], NA))
}