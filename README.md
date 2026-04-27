ecopmodb
================

This package provides functionality for navigating the prediction files
produced by the [ecopmo](https://github.com/BigelowLab/ecopmo) package
workflows.

# Requirements

## From CRAN

- [rlang](https://CRAN.R-project.org/package=rlang)
- [stars](https://CRAN.R-project.org/package=stars)
- [readr](https://CRAN.R-project.org/package=readr)
- [dplyr](https://CRAN.R-project.org/package=dplyr)

# Installation

Use the [pak R package](https://CRAN.R-project.org/package=pak) to
install directlly from Github.

    pak::pak("BigelowLab/ecopmodb")

# Summary

Prediction output are stored in a one-prediction-per-file architecture.
Depending upon the data set, there may be many files per day (or month).
To facilitate the navigation, selection and reading of files we provide
a simple database which can be filtered to select files, and a function
that will read the files into a
[stars](https://CRAN.R-project.org/package=stars) array.

# Read in a database

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

## Select a subset of files

Filtering is quite easy using
[dplyr](https://CRAN.R-project.org/package=dplyr).

``` r
db = dplyr::filter(db,
                   per == "monc",
                   type == "q050")
```

Finally, read in the files.

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
