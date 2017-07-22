
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/prisonbrief)](https://cran.r-project.org/package=prisonbrief) ![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/danilofreire/prisonbrief?branch=master&svg=true) [![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/prisonbrief)](https://CRAN.R-project.org/package=prisonbrief) [![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/grand-total/prisonbrief)](https://CRAN.R-project.org/package=prisonbrief)

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
#> # A tibble: 226 x 2
#>                 country_name             country_url
#>                        <chr>                   <chr>
#>  1               Afghanistan             afghanistan
#>  2                   Albania                 albania
#>  3                   Algeria                 algeria
#>  4     American Samoa  (USA)      american-samoa-usa
#>  5                   Andorra                 andorra
#>  6                    Angola                  angola
#>  7 Anguilla (United Kingdom) anguilla-united-kingdom
#>  8       Antigua and Barbuda     antigua-and-barbuda
#>  9                 Argentina               argentina
#> 10                   Armenia                 armenia
#> # ... with 216 more rows
```

The second function is `wpb_table()`. This function returns a series of variables about the prison systems of the world, of a particular region, or of a specific country. For instance, the code below downloads prison data for Africa:

``` r
africa <- wpb_table(region = "Africa")
names(africa)
#>  [1] "country"                 "prison_population_rate" 
#>  [3] "prison-population-total" "female-prisoners"       
#>  [5] "pre-trial-detainees"     "foreign-prisoners"      
#>  [7] "occupancy-level"         "iso_a2"                 
#>  [9] "name"                    "geometry"
```

The region choices are "Africa", "Asia", "Caribbean", "Central America", "Europe", "Middle East", "North America", "Oceania", "South America" and "All".

`wpb_table()` also provides geometric shapes for maps. For instance, you can download and plot the prison population rate in South America with only a few lines of code:

``` r
south_america <- wpb_table(region = "South America")

library(ggplot2)
ggplot(south_america, aes(fill = prison_population_rate)) +
        geom_sf() +
        scale_fill_distiller(palette = "YlOrRd", trans = "reverse") +
        theme_minimal()
```

![](http://i.imgur.com/JxO0wCr.png)

The function can also be used to retrieve data for a single country. The data returned are parsed from the single country tables, however, and are not ready for quantitative analysis without further cleaning (removing parentheses etc.). Since some of this information may be relevant, we have chosen to leave it in. Data from regions instead of a single country are fully prepared for automated analysis.

Finally, we have added the `wpb_series()` function to the package. The function downloads and tidies the tables describing the trends in the prison population total and the prison population rate for every jurisdiction included in the project. Below is an example taken from [Germany's country profile](http://www.prisonstudies.org/country/germany):

![](http://i.imgur.com/vtbrtg1.png)

You can retrieve the same information with the following code:

``` r
germany <- wpb_series(country = "Germany")
germany
#> # A tibble: 8 x 4
#>   Country  Year `Prison population total` `Prison population rate`
#>     <chr> <dbl>                     <dbl>                    <dbl>
#> 1 germany  2000                     70252                       85
#> 2 germany  2002                     70977                       86
#> 3 germany  2004                     79452                       96
#> 4 germany  2006                     76629                       93
#> 5 germany  2008                     72259                       88
#> 6 germany  2010                     69385                       85
#> 7 germany  2012                     65889                       82
#> 8 germany  2014                     61872                       76
```

`wpb_series()` can also be combined with `wpb_list()` to make interesting time series graphs. The code below downloads data for all countries then plots the prison population rate for Brazil, Germany, Russia and the United States:

``` r
x <- list()
countries <- wpb_list()
for(i in 1:nrow(countries)){
  y <- try(wpb_series(country = countries$country_url[i]), silent = FALSE)
  if(class(y) != 'try-error'){
    x[[i]] <- y
  } else{
    next
  }
}
X <- data.table::rbindlist(x, fill = TRUE) %>% 
  dplyr::full_join(countries, by = c("Country" = "country_url"))

X %>% dplyr::filter(country_name %in% c("Brazil",
                                        "Germany",
                                        "Russian Federation",
                                        "United States of America")) %>%
        ggplot(aes(x = Year, y = `Prison population rate`,
                   group = country_name, colour = country_name)) +
        geom_line() +
        theme_minimal()
```

![](http://i.imgur.com/lIUhO5E.png)

Contributions
-------------

`prisonbrief` was written by [Danilo Freire](http://danilofreire.com/) and [Robert Myles McDonnell](https://robertmyles.github.io/). Feedback and comments are welcome. If you have any suggestions on how to improve the package feel free to [open an issue on GitHub](https://github.com/danilofreire/prisonbrief/issues).

Citation
--------

If you use the `prisonbrief` package, you can cite it with:

``` r
citation("prisonbrief")
#> 
#> To cite 'prisonbrief' in publications, please use:
#> 
#>   Danilo Freire and Robert Myles McDonnell (2017). prisonbrief:
#>   Downloads and Parses World Prison Brief Data. R package version
#>   0.1.0. URL: https://CRAN.R-project.org/package=prisonbrief
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {{prisonbrief}: Downloads and Parses World Prison Brief Data},
#>     author = {Danilo Freire and Robert Myles McDonnell},
#>     note = {R package version 0.1.0},
#>     year = {2017},
#>     url = {https://CRAN.R-project.org/package=prisonbrief},
#>   }
```

Please also cite the source as [World Prison Brief, Institute for Criminal Policy Research](http://www.prisonstudies.org/about-us).
