
<!-- README.md is generated from README.Rmd. Please edit that file -->
prisonbrief: An R package that returns tidy data from the World Prison Brief website
====================================================================================

The goal of `prisonbrief` is to download, clean and return data from the [World Prison Brief website](http://www.prisonstudies.org/). The World Prison Brief is an online database compiled by the [Institute for Criminal Policy Research](http://www.icpr.org.uk/) with information on prison systems around the world. Data currently cover 223 jurisdictions and have been collected from public sources. The `prisonbrief` package provides easy-to-use functions to convert the World Prison Brief database into a format convenient for statistical analysis.

Installation
------------

The stable version of `prisonbrief` is available on [CRAN](https://cran.r-project.org/package=prisonbrief). To install it, just type:

``` r
install.packages("prisonbrief")
```

You can install the most recent development version of `prisonbrief` using the `devtools` package. First, you need to install the `devtools` package with the following code:

``` r
if(!require(devtools)) install.packages("devtools")
```

Then you need to load `devtools` and install `prisonbrief` from its GitHub repository:

``` r
library(devtools)
devtools::install_github("danilofreire/prisonbrief")
```

Usage
-----

`prisonbrief` is quite simple to use. The package contains only three functions, all of them starting with `wpb`, the acronym for World Prison Brief.

The first is a convenience function named `wpb_list()`. It prints a list of available countries to the console.

``` r
library(prisonbrief)

wpb_list()
# A tibble: 226 x 2
                country_name             country_url
                       <chr>                   <chr>
 1               Afghanistan             afghanistan
 2                   Albania                 albania
 3                   Algeria                 algeria
 4     American Samoa  (USA)      american-samoa-usa
 5                   Andorra                 andorra
 6                    Angola                  angola
 7 Anguilla (United Kingdom) anguilla-united-kingdom
 8       Antigua and Barbuda     antigua-and-barbuda
 9                 Argentina               argentina
10                   Armenia                 armenia
# ... with 216 more rows
```

The second function is `wpb_tables()`. This function returns a series of variables about the prison systems of the world, of a particular region, or of a specific country. For instance, the code below downloads prison data for Africa:

``` r
africa <- wpb_tables(region = "Africa")
names(africa)
 [1] "country"                 "prison_population_rate"  "prison-population-total" "female-prisoners"       
 [5] "pre-trial-detainees"     "foreign-prisoners"       "occupancy-level"         "iso_a2"                 
 [9] "name"                    "geometry"    
```

The region choices are "Africa", "Asia", "Caribbean", "Central America", "Europe", "Middle East", "North America", "Oceania", "South America" and "All".

The `wpb_tables()` also provides geometric shapes to make plotting maps easier. For instance, you can download and plot the prison population rate in South America with only two lines of code:

``` r
south_america <- wpb_tables(region = "South America")
ggplot(south_america, aes(fill = prison_population_rate)) + geom_sf() + theme_minimal()
```

![](http://i.imgur.com/wek7T71.png)

Contributions
-------------

`prisonbrief` was written by [Danilo Freire](http://danilofreire.com/) and [Robert Myles McDonnell](https://robertmyles.github.io/). Feedback and comments are welcome. If you have any suggestions on how to improve the package feel free to [open an issue on GitHub](https://github.com/danilofreire/wpb/issues).

Citation
--------

If you use the `prisonbrief` package, you can cite it with:

``` r
citation("prisonbrief")
```

Please also cite the source as [World Prison Brief, Institute for Criminal Policy Research](http://www.prisonstudies.org/about-us).
