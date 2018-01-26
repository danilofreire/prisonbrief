#' @title Download and parse World Prison Brief data
#' @description Download and parse World Prison Brief data
#' @import rnaturalearthdata
#' @importFrom httr GET
#' @importFrom rlang UQ
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_node
#' @importFrom rvest html_table
#' @importFrom tidyr spread
#' @importFrom dplyr bind_cols
#' @importFrom dplyr funs
#' @importFrom dplyr mutate_all
#' @importFrom dplyr full_join
#' @importFrom dplyr select
#' @importFrom dplyr contains
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
        api_parse <- function(base = "http://www.prisonstudies.org/highest-to-lowest/",
                              type = NULL,
                              query = "?field_region_taxonomy_tid=",
                              continent = NULL){
                
                result <- GET(paste0(base, type, query, continent)) %>%
                        read_html() %>%
                        html_node("#views-aggregator-datatable") %>%
                        html_table() %>%
                        select(country = 2, UQ(type) := 3)
                
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
                                   type = "prison_population_total")
                female <- api_parse(continent = continent,
                                    type = "female_prisoners")
                pretrial <- api_parse(continent = continent,
                                      type = "pre_trial_detainees")
                foreign <- api_parse(continent = continent,
                                     type = "foreign_prisoners")
                occupancy <- api_parse(continent = continent,
                                       type = "occupancy_level")
                
                result <- suppressMessages(
                        full_join(rate, total) %>%
                                full_join(female) %>%
                                full_join(pretrial) %>%
                                full_join(foreign) %>%
                                full_join(occupancy)
                ) %>%
                        mutate(iso_a2 = parse_country(country))
                
                geometry <-  ne_countries(type = "map_units",
                                           returnclass = "sf")
                geometry <- dplyr::select(geometry, name, iso_a2, geometry)
                
                out <- suppressMessages(
                        full_join(result, geometry) %>%
                                dplyr::filter(!is.na(country))
                )
                
                return(out)
                
        } else {
                
                # country tables:
                
                url <- paste0("http://www.prisonstudies.org/country/", country)
                
                country_table <- parse_urls(url)
                
                country_table <- country_table %>% 
                        select(country = Country, 
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
                        mutate_all(.funs = funs(str_replace_all,
                                                .args = list(pattern = "\n",
                                                             replacement = "")))
                colnames(country_table)[grep(
                        "pre_trial_prisoners1", 
                        colnames(country_table)
                        )] <- "pre_trial_prisoners" 
                        
                return(country_table)
                
        }
}