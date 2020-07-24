#' @title Download and parse World Prison Brief data
#' @description Download and parse World Prison Brief data
#' @import rnaturalearthdata
#' @import sf
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_node html_table
#' @importFrom tidyr spread
#' @importFrom dplyr bind_cols funs case_when select rename
#' @importFrom dplyr mutate_all full_join contains mutate
#' @importFrom passport parse_country as_country_name
#' @importFrom rnaturalearth ne_countries
#' @importFrom stringr str_replace_all
#' @param region \code{character}. Return details for all the countries in the
#' particular region. For a list of the countries in each region, use
#' \code{wbp_region_list()}.
#' @param country \code{character}. If details of a specific country are
#' required, the country can be specified by name. A non-\code{NULL} value for
#'  this parameter will void the \code{region} argument. For a list of country
#'   names, use \code{wpb_list()}.
#' @return Data Frame with 10 variables:
#' \itemize{
#'   \item country \code{character}.
#'   \item prison_population_rate \code{integer},  per 100,000 of the national
#'   population.
#'   \item prison_population_total \code{integer}.
#'   \item female_prisoners \code{numeric}, (percentage of total prison pop.).
#'   \item pre_trial_detainees \code{numeric}, (percentage of total prison pop.).
#'   \item foreign_prisoners \code{numeric}, (percentage of total prison pop.).
#'   \item occupancy_level \code{numeric},  (percentage based on official capacity).
#'   \item iso_a2 \code{character}. See notes.
#'   \item geometry \code{sfc_MULTIPOLYGON}.
#' }
#' @note We recommend calling this function using the region argument, as the data
#' come back in a format more useful for analysis. Querying a specific country will
#' return a dataframe in which certain columns contain items such as parentheses
#' and auxiliary text, rendering follow-on analysis more cumbersome.
#' As regards the spatial information, the \code{geometry} column will be an
#' empty list where it has not matched every entry in \code{country}. This is due
#' to the way territories are coded according to ISO A2 codes. For example,
#' \code{country} will contain "Jersey (United Kingdom)", whereas \code{geometry}
#' contains information for only the United Kingdom as a whole. We hope to improve
#' this in future releases of prisonBrief.
#' @examples
#' \dontrun{
#' # Get details for Spain:
#' espana <- wpb_table(country = "Spain")
#'
#' # Get details for Central America:
#' CA <- wpb_table(region = "Central America")
#' }
#' @export

wpb_table <- function(region = c(
                        "Africa", "Asia", "Caribbean",
                        "Central America", "Europe",
                        "Middle East", "North America",
                        "Oceania", "South America", "All"
                      ),
                      country = NULL) {

  # parse tables from country pages:
  parse_urls <- function(x) {
    result <- read_html(x) %>%
      html_nodes(css = "div#basic_data") %>%
      html_nodes("table") %>%
      html_table(fill = TRUE)

    head <- result[[1]] %>% spread(X1, X2)
    contacts <- result[[2]] %>% spread(X1, X2)
    head <- bind_cols(head, contacts)

    main <- result[[3]] %>% spread(X1, X2)
    out <- bind_cols(head, main)
    return(out)
  }

  # parse ranking API:
  api_parse <- function(continent = NULL, type = NULL) {
    base <- "http://www.prisonstudies.org/highest-to-lowest/"
    query <- "?field_region_taxonomy_tid="
    result <- GET(paste0(base, type, query, continent)) %>%
      read_html() %>%
      html_node("#views-aggregator-datatable") %>%
      html_table() %>%
      select(-Ranking) %>%
      rename(country = Title)

    return(result)
  }

  # continent tables:
  if (is.null(country)) {
    continent <- match.arg(region, choices = c(
      "Africa", "Asia", "Caribbean", "Central America",
      "Europe", "Middle East", "North America",
      "Oceania", "South America", "All"
    ))

    continent <- case_when(
      continent == "Africa" ~ "15",
      continent == "Asia" ~ "16",
      continent == "Caribbean" ~ "17",
      continent == "Central America" ~ "18",
      continent == "Europe" ~ "14",
      continent == "Middle East" ~ "21",
      continent == "North America" ~ "22",
      continent == "Oceania" ~ "23",
      continent == "South America" ~ "24",
      TRUE ~ continent
    )

    rate <- api_parse(continent = continent, type = "prison_population_rate")
    total <- api_parse(continent = continent, type = "prison-population-total")
    female <- api_parse(continent = continent, type = "female-prisoners")
    pretrial <- api_parse(continent = continent, type = "pre-trial-detainees")
    foreign <- api_parse(continent = continent, type = "foreign-prisoners")
    occupancy <- api_parse(continent = continent, type = "occupancy-level")

    result <- suppressMessages(
      full_join(rate, total) %>%
        full_join(female) %>%
        full_join(pretrial) %>%
        full_join(foreign) %>%
        full_join(occupancy)
    ) %>%
      mutate(iso_a2 = parse_country(country))

    geometry <- ne_countries(
      type = "map_units",
      returnclass = "sf"
    )
    geometry <- dplyr::select(geometry, iso_a2, geometry)

    out <- suppressMessages(
      full_join(result, geometry) %>%
        dplyr::filter(!is.na(country)) %>% 
              st_as_sf()
    )

    colnames(out) <- c(
      "country", "prison_population_rate",
      "prison_population_total", "female_prisoners",
      "pre_trial_detainees", "foreign_prisoners",
      "occupancy_level", "iso_a2", "geometry"
    )

    return(out)
  } else {
    # country tables:
    url <- paste0("http://www.prisonstudies.org/country/", country)

    country_table <- parse_urls(url)

    country_table <- country_table %>%
      select(
        country = Country,
        ministry_responsible = `Ministry responsible`,
        prison_admin = `Prison administration`,
        female_prisoners = contains("Female prisoners "),
        foreign_prisoners = contains("Foreign prinsoners "),
        juvenile_prisoners = contains("Juveniles "),
        occupancy_level = contains("Occupancy level "),
        number_institutions = contains("Number of establishments"),
        official_capacity = contains("Official capacity "),
        pre_trial_prisoners = contains("Pre-trial "),
        prison_population_rate = contains("Prison population rate "),
        prison_population_total = contains("Prison population total ")
      ) %>%
      mutate_all(.funs = funs(
              str_replace_all,
              .args = list(pattern = "\n", replacement = "")
              )) %>% 
      rename("pre_trial_prisoners" = "pre_trial_prisoners1")
    
    return(country_table)
  }
}
