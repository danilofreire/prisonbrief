#' @title Download and parse World Prison Brief time series data
#' @description Download and parse World Prison Brief time series data
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_table
#' @importFrom magrittr set_colnames
#' @importFrom magrittr %>%
#' @importFrom tidyr spread
#' @importFrom dplyr bind_cols
#' @importFrom dplyr slice
#' @importFrom dplyr select
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_all
#' @importFrom dplyr everything
#' @param country Country name, in the url-style used by the World Prison Brief. See note below.
#' @note Important: the country names must be the \emph{url} names associated with the country. These can be seen in the second column of the dataframe returned from \code{wpb_list()}. Most of these are simply lower-case versions of the country name, such as 'algeria'. Some, such as "American Samoa  (USA)" are in the following format: \code{american-samoa-usa}.
#' @export

wpb_series <- function(country = NULL){

  if(is.null(country)){
    stop("'country' argument is needed.")
  }
  country <- tolower(country)

  '%ni%' <- Negate('%in%')
  ccc <- wpb_list()

  if(country %ni% ccc$country_url){
    stop("No country matches your request. Please see wpb_list() for a list of available countries,")
  }

  url <- paste0("http://www.prisonstudies.org/country/", country)

  result <- xml2::read_html(url) %>%
    rvest::html_nodes(css = "div#basic_data") %>%
    rvest::html_nodes("table") %>%
    rvest::html_table(fill = TRUE)

  series <- result[[4]]
  # find duplicated line, move index to one less this value:
  duplicate <- grep("Year", series$X1) %>% .[[2]] %>% -1

  series <- series[1:duplicate, ] %>%
    dplyr::select(1:3) %>%
    dplyr::slice(-1:-2) %>%
    dplyr::mutate(X2 = gsub(",", "", X2),
                  X2 = gsub("c", "", X2),
                  X3 = gsub("c", "", X3)) %>%
    magrittr::set_colnames(value = c("Year", "Prison population total",
                                     "Prison population rate")) %>%
    dplyr::mutate_all(as.numeric) %>%
    dplyr::mutate(Country = country) %>%
    dplyr::select(Country, dplyr::everything())

  return(series)

}

