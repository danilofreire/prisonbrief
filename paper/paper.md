---
title: 'prisonbrief: An R package that returns tidy data from the World Prison Brief website'
tags:
  - data
  - prison
  - rstats
  - world prison data
authors:
 - name: Danilo Freire
   orcid: 0000-0002-4712-6810
   affiliation: 1
 - name: Robert Myles McDonnell
   affiliation: 2
affiliations:
 - name: Department of Political Economy, King's College London
   index: 1
 - name: Avanade
   index: 2
bibliography: paper.bib
date: 1 November 2017
---

# Summary

`prisonbrief` is an R package that downloads, cleans and returns tidy data [@wickham2014tidy] from the [World Prison Brief website](http://www.prisonstudies.org/) [@icpr2017prison]. The World Prison Brief (WPB) is an online database compiled by the [Institute for Criminal Policy Research](http://www.icpr.org.uk/) with information on prison systems around the world. WPB data currently cover 223 jurisdictions and have been collected from public sources. The `prisonbrief` package provides three easy-to-use functions that convert WPB data into a format convenient for statistical analysis. Researchers interested in comparative prison systems -- such as criminologists, sociologists and economists -- can use the output from functions in the package to create maps, plot time series graphs and calculate descriptive statistics with only a few lines of code.

# References
