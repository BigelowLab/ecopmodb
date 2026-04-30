ecopmodb
================

This package provides functionality for navigating the prediction files
produced by the [ecopmo](https://github.com/BigelowLab/ecopmo) package
workflows.

# 1 Requirements

## From CRAN

- [rlang](https://CRAN.R-project.org/package=rlang)
- [stars](https://CRAN.R-project.org/package=stars)
- [readr](https://CRAN.R-project.org/package=readr)
- [dplyr](https://CRAN.R-project.org/package=dplyr)
- [stringr](https://CRAN.R-project.org/package=stringr)
- [yaml](https://CRAN.R-project.org/package=yaml)

# 2 Installation

Use the [pak R package](https://CRAN.R-project.org/package=pak) to
install directly from Github.

    pak::pak("BigelowLab/ecopmodb")

# 3 Summary

Prediction output are stored in a one-prediction-per-file architecture.
Depending upon the data set, there may be many files per day (or month).
To facilitate the navigation, selection and reading of files we provide
a simple database which can be filtered to select files, and a function
that will read the files into a
[stars](https://CRAN.R-project.org/package=stars) or
[SpatRaster](https://CRAN.R-project.org/package=terra) array.

# 4 Read in a database

To read a database, you need only need to provide a path to where the
database is located.

``` r
suppressPackageStartupMessages({
  library(ecopmodb)
  library(dplyr)
  library(stars)
})

# obviously, you'll want to use a path that is available to you
path = "/mnt/s1/projects/ecocast/projectdata/ecomoncopernicusmodel/copernicus/ctenop/versions/v0/v0.00/preds"
db = ecopmodb::read_database(path)
dplyr::count(db, per, type)
```

    ## # A tibble: 5 × 3
    ##   per   type      n
    ##   <chr> <chr> <int>
    ## 1 day   q005  12174
    ## 2 day   q050  12174
    ## 3 day   q095  12174
    ## 4 mon   q050    401
    ## 5 monc  q050     12

## Have one place for all ecopmo outputs?

If you have one directory where all of your
[ecopmo](https://github.com/BigelowLab/ecopmo) prediction outputs are
stored, then you can set up a hidden file to store that path. This is
just a convenience for the user, and is not a requirement.

``` r
ecopmo::set_root_data_path("/mnt/s1/projects/ecocast/projectdata/ecomoncopernicusmodel/copernicus")
```

    ## [1] "/mnt/s1/projects/ecocast/projectdata/ecomoncopernicusmodel/copernicus"

This will be useful if you use configuration files (see below).

## Select a subset of files

Filtering is quite easy using
[dplyr](https://CRAN.R-project.org/package=dplyr).

``` r
db = dplyr::filter(db,
                   per == "monc",
                   type == "q050")
```

## Finally, read in the files.

``` r
x = ecopmodb::read_ecopmo(db, path)
x
```

    ## stars object with 3 dimensions and 1 attribute
    ## attribute(s), summary of first 1e+05 cells:
    ##            Min.   1st Qu.    Median      Mean   3rd Qu.     Max.  NA's
    ## q050  0.2790147 0.6564292 0.9300928 0.8151182 0.9873105 0.999474 34222
    ## dimension(s):
    ##      from  to offset    delta refsys point                    values x/y
    ## x       1 415 -77.04  0.08333 WGS 84 FALSE                      NULL [x]
    ## y       1 261  56.71 -0.08333 WGS 84 FALSE                      NULL [y]
    ## date    1  12     NA       NA   Date    NA 1993-01-01,...,1993-12-01

These can be read in as
[SpatRaster](https://CRAN.R-project.org/package=terra) class objects,
but the arrangement of the layers may not be what you might hope.

``` r
y = ecopmodb::read_ecopmo(db, path, form = "SpatRaster")
y
```

    ## class       : SpatRaster 
    ## size        : 261, 415, 12  (nrow, ncol, nlyr)
    ## resolution  : 0.08333333, 0.08333333  (x, y)
    ## extent      : -77.04167, -42.45833, 34.95833, 56.70833  (xmin, xmax, ymin, ymax)
    ## coord. ref. : lon/lat WGS 84 (EPSG:4326) 
    ## source(s)   : memory
    ## names       :     lyr.1,     lyr.2,     lyr.3,     lyr.4,     lyr.5,     lyr.6, ... 
    ## min values  : 0.2466775, 0.1414665, 0.1533578, 0.1532717, 0.1274452, 0.1093750, ... 
    ## max values  : 0.9994740, 0.9994964, 0.9984681, 0.9983139, 0.9980972, 0.9985875, ... 
    ## time (days) : 1993-01-01 to 1993-12-01 (12 steps)

# 5 Using configuration lists

Configuration lists, stored in [YAML](https://yaml.org/) format, play a
central role in the [ecopmo](https://github.com/BigelowLab/ecopmo)
workflow.

Assuming you set the root data path (see above) it is very easy to read
in a configuration.

``` r
cfg = ecopmodb::read_configuration(species = "ctenop", version = "v0.00")
str(cfg)
```

    ## List of 9
    ##  $ species      : chr "ctenop"
    ##  $ longname     : chr "Ctenophore"
    ##  $ version      : chr "v0.00"
    ##  $ class        : chr "jellyfish"
    ##  $ note         : chr "none"
    ##  $ verbose      : logi TRUE
    ##  $ training_data:List of 5
    ##   ..$ species       : chr "ctenop"
    ##   ..$ species_data  :List of 4
    ##   .. ..$ ecomon_column: chr "ctenop_m2"
    ##   .. ..$ alt_source   : chr "function"
    ##   .. ..$ function     : chr "read_ecomon_covars"
    ##   .. ..$ threshold    :List of 2
    ##   .. .. ..$ pre : num 0
    ##   .. .. ..$ post: NULL
    ##   ..$ classification:List of 3
    ##   .. ..$ name  : chr "patch"
    ##   .. ..$ levels: int [1:2] 1 0
    ##   .. ..$ labels: chr [1:2] "1" "0"
    ##   ..$ coper_data    :List of 6
    ##   .. ..$ vars_static: chr [1:2] "deptho" "slope"
    ##   .. ..$ reg_phys   : chr "chfc"
    ##   .. ..$ vars_phys  : chr [1:6] "temp_bot" "mlotst_mld" "sal_sur" "temp_sur" ...
    ##   .. ..$ reg_bgc    : chr "world"
    ##   .. ..$ vars_bgc   : chr [1:6] "chl_sur" "no3_sur" "nppv_sur" "o2_sur" ...
    ##   .. ..$ vars_time  : chr [1:2] "day_length" "ddx_day_length"
    ##   ..$ split         :List of 3
    ##   .. ..$ func : chr "rsample::mc_cv"
    ##   .. ..$ prop : num 0.75
    ##   .. ..$ times: int 25
    ##  $ model        :List of 3
    ##   ..$ seed           : num 750
    ##   ..$ model          :List of 8
    ##   .. ..$ name      : chr "Boosted Regression Tree"
    ##   .. ..$ engine    : chr "xgboost"
    ##   .. ..$ trees     : num 500
    ##   .. ..$ learn_rate: num 0.1
    ##   .. ..$ tree_depth: num 4
    ##   .. ..$ mtry      : num 5
    ##   .. ..$ min_n     : num 10
    ##   .. ..$ nthread   : num 4
    ##   ..$ transformations: chr [1:2] "step_log_bathy" "step_normalize_numeric"
    ##  $ predict      :List of 1
    ##   ..$ quantiles: num [1:7] 0 0.05 0.25 0.5 0.75 0.95 1

## Read a database with the configuration

You maybe find it easier to read a database without having to muck
around with paths.

``` r
db = ecopmodb::read_database(cfg)
```
