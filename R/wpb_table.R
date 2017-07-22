#' @title Download and parse World Prison Brief data
#' @description Download and parse World Prison Brief data
#' @import rnaturalearthdata
#' @importFrom httr GET
#' @importFrom rlang UQ
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_table
#' @importFrom magrittr set_colnames
#' @importFrom magrittr '%>%'
#' @importFrom tidyr spread
#' @importFrom dplyr bind_cols
#' @importFrom dplyr funs
#' @importFrom dplyr mutate_all
#' @importFrom dplyr full_join
#' @importFrom dplyr select
#' @importFrom dplyr mutate
#' @importFrom data.table ':='
#' @importFrom passport parse_country
#' @importFrom passport as_country_name
#' @importFrom rnaturalearth ne_countries
#' @importFrom stringr str_replace_all
#' @param region \code{character}. Return details for all the countries in the particular region. For a list of the countries in each region, use \code{wbp_region_list()}.
#' @param country \code{character}. If details of a specific country are required, the country can be specified by name. A non-\code{NULL} value for this parameter will void the \code{region} argument. For a list of country names, use \code{wpb_list()}.
#' @examples
#' \dontrun{
#' # Get details for Spain:
#' espana <- wpb_table(country = "Spain")
#'
#' # Get details for Central America:
#' CA <- wpb_table(region = "Central America")
#' }
#' @export

wpb_table <- function(region = c("Africa", "Asia", "Caribbean",
                                  "Central America", "Europe",
                                  "Middle East", "North America",
                                  "Oceania", "South America", "All"),
                       country = NULL){
        
        # parse tables from country pages:
        parse_urls <- function(x){
                result <- xml2::read_html(x) %>%
                        rvest::html_nodes(css = "div#basic_data") %>%
                        rvest::html_nodes("table") %>%
                        rvest::html_table(fill = TRUE)
                
                head <- result[[1]] %>% tidyr::spread(X1, X2)
                contacts <- result[[2]] %>% tidyr::spread(X1, X2)
                head <- dplyr::bind_cols(head, contacts)
                
                main <- result[[3]] %>% tidyr::spread(X1, X2)
                out <- dplyr::bind_cols(head, main)
                return(out)
        }
        
        # parse ranking API:
        api_parse <- function(base = "http://www.prisonstudies.org/highest-to-lowest/",
                              type = NULL,
                              query = "?field_region_taxonomy_tid=",
                              continent = NULL){
                
                result <- httr::GET(paste0(base, type, query, continent)) %>%
                        xml2::read_html() %>%
                        rvest::html_node("#views-aggregator-datatable") %>%
                        rvest::html_table() %>%
                        dplyr::select(country = 2, rlang::UQ(type) := 3)
                
                return(result)
        }
        
        
        # continent tables:
        if(is.null(country)){
                
                continent <- match.arg(region, choices = c("Africa", "Asia", "Caribbean",
                                                           "Central America", "Europe",
                                                           "Middle East", "North America",
                                                           "Oceania", "South America", "All"))
                
                continent <- ifelse(
                        continent == "Africa", "15",
                        ifelse(
                                continent == "Asia", "16",
                                ifelse(
                                        continent == "Caribbean", "17",
                                        ifelse(
                                                continent == "Central America", "18",
                                                ifelse(
                                                        continent == "Europe", "14",
                                                        ifelse(
                                                                continent == "Middle East", "21",
                                                                ifelse(
                                                                        continent == "North America", "22",
                                                                        ifelse(
                                                                                continent == "Oceania", "23",
                                                                                ifelse(
                                                                                        continent == "South America", "24", continent
                                                                                )))))))))
                
                
                rate <- api_parse(continent = continent,
                                  type = "prison_population_rate")
                total <- api_parse(continent = continent,
                                   type = "prison-population-total")
                female <- api_parse(continent = continent,
                                    type = "female-prisoners")
                pretrial <- api_parse(continent = continent,
                                      type = "pre-trial-detainees")
                foreign <- api_parse(continent = continent,
                                     type = "foreign-prisoners")
                occupancy <- api_parse(continent = continent,
                                       type = "occupancy-level")
                
                result <- suppressMessages(
                        dplyr::full_join(rate, total) %>%
                                dplyr::full_join(female) %>%
                                dplyr::full_join(pretrial) %>%
                                dplyr::full_join(foreign) %>%
                                dplyr::full_join(occupancy)
                ) %>%
                        dplyr::mutate(iso_a2 = passport::parse_country(country))
                
                geometry <-  rnaturalearth::ne_countries(type = "map_units",
                                                         returnclass = "sf")
                geometry <- geometry[, c(18, 44, 64)]
                
                out <- suppressMessages(
                        dplyr::full_join(result, geometry, by = ) %>%
                                dplyr::filter(!is.na(country))
                )
                
                return(out)
                
        } else {
                
                # country tables:
                
                url <- paste0("http://www.prisonstudies.org/country/", country)
                
                country_table <- parse_urls(url)
                
                country_table <- country_table %>% 
                        magrittr::set_colnames(., 
                                               value = c("country",
                                                "ministry_responsible",
                                                "prison_admin",
                                                "female_prisoners",
                                                "foreign_prisoners",
                                                 "juvenile_prisoners",
                                                 "number_institutions",
                                                 "occupancy_level",
                                                 "official_capacity",
                                                    "pre_trial_prisoners",
                                                    "prison_population_rate",
                                                  "prison_population_total")) %>%
                        dplyr::mutate_all(.funs = dplyr::funs(stringr::str_replace_all, 
                                               .args = list(pattern = "\n",
                                                           replacement = "")))
                        
                return(country_table)
                
        }
}