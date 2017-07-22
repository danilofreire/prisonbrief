#' @title Available World Prison Brief countries
#' @description Prints a list of available countries to the console.
#' @importFrom xml2 read_html
#' @importFrom magrittr %>%
#' @importFrom tibble tibble
#' @importFrom rvest html_nodes
#' @importFrom rvest html_table
#' @importFrom rvest html_text
#' @export
wpb_list <- function(){

  lista <- xml2::read_html("http://www.prisonstudies.org/map/africa") %>%
    rvest::html_nodes("ul.menu") %>%
    rvest::html_nodes("div.item-list") %>%
    rvest::html_nodes("span.field-content") %>%
    rvest::html_text()

  lista <- sort(unique(lista))

  country_url = sort(c("algeria", "angola", "benin", "botswana", "burkina-faso", "burundi", "cameroon", "cape-verde-cabo-verde", "central-african-republic", "chad", "comoros", "congo-brazzaville", "cote-divoire", "democratic-republic-congo-formerly-zaire", "djibouti", "egypt", "equatorial-guinea", "eritrea", "ethiopia", "gabon", "gambia", "ghana", "guinea-bissau", "kenya", "lesotho", "liberia", "libya", "madagascar", "malawi", "mali", "mauritania", "mauritius", "mayotte-france", "morocco", "mozambique", "namibia", "niger", "nigeria", "republic-guinea", "reunion-france", "rwanda", "sao-tome-e-principe", "senegal", "seychelles", "sierra-leone", "somalia", "south-africa", "south-sudan", "sudan", "swaziland", "tanzania", "togo", "tunisia", "uganda", "zambia", "zimbabwe", "afghanistan", "bangladesh", "bhutan", "brunei-darussalam", "cambodia", "china", "democratic-peoples-republic-north-korea", "hong-kong-china", "india", "indonesia", "iran", "japan", "kazakhstan", "kyrgyzstan", "laos", "macau-china", "malaysia", "maldives", "mongolia", "myanmar-formerly-burma", "nepal", "pakistan", "philippines", "republic-south-korea", "singapore", "sri-lanka", "taiwan", "tajikistan", "thailand", "turkmenistan", "uzbekistan", "vietnam", "anguilla-united-kingdom", "antigua-and-barbuda", "aruba-netherlands", "bahamas", "barbados", "cayman-islands-united-kingdom", "cuba", "cura\u00a7ao-netherlands", "dominica", "Dominican Republic", "grenada", "guadeloupe-france", "haiti", "jamaica", "martinique-france", "puerto-rico-usa", "sint-maarten-netherlands", "st-kitts-and-nevis", "st-lucia", "st-vincent-and-grenadines", "trinidad-and-tobago", "virgin-islands-united-kingdom", "virgin-islands-usa", "belize", "costa-rica", "el-salvador", "guatemala", "honduras", "mexico", "nicaragua", "panama", "albania", "andorra", "armenia", "austria", "azerbaijan", "belarus", "belgium", "bosnia-and-herzegovina-federation", "bosnia-and-herzegovina-republika-srpska", "bulgaria", "croatia", "cyprus-republic", "czech-republic", "denmark", "estonia", "faeroe-islands-denmark", "finland", "france", "georgia", "germany", "gibraltar-united-kingdom", "greece", "guernsey-united-kingdom", "hungary", "iceland", "ireland-republic", "isle-man-united-kingdom", "italy", "jersey-united-kingdom)", "kosovokosova", "latvia", "liechtenstein", "lithuania", "luxembourg", "macedonia-former-yugoslav-republic", "malta", "moldova-republic", "monaco", "montenegro", "netherlands", "norway", "poland", "portugal", "romania", "russian-federation", "san-marino", "serbia", "slovakia", "slovenia", "spain", "sweden", "switzerland", "turkey", "ukraine", "united-kingdom-england-wales", "united-kingdom-northern-ireland", "united-kingdom-scotland", "bahrain", "iraq", "israel", "jordan", "kuwait", "lebanon", "oman", "qatar", "saudi-arabia", "syria", "united-arab-emirates", "yemen", "bermuda-united-kingdom", "canada", "greenland-denmark", "united-states-america", "american-samoa-usa", "australia", "cook-islands-new-zealand", "fiji", "french-polynesia-france", "guam-usa", "kiribati", "marshall-islands", "micronesia-federated-states", "nauru", "new-caledonia-france", "new-zealand", "northern-mariana-islands-usa", "palau", "papua-new-guinea", "samoa-formerly-western-samoa", "solomon-islands", "timor-leste-formerly-east-timor", "tonga", "tuvalu", "vanuatu", "argentina", "bolivia", "brazil", "chile", "colombia", "ecuador", "french-guianaguyane-france", "guyana", "paraguay", "peru", "suriname", "uruguay", "venezuela"))


  df <- tibble::tibble(
    country_name = lista,
    country_url = country_url
  )

  return(df)
}



#' @title Lists all countries in a region
#' @description Creates a list of all countries in a given region.
#' @param region \code{character}. Return details for all the countries in the particular region. For a list of the countries in each region, use \code{wbp_region_list()}.
#' @export
wbp_region_list <- function(region = c("Africa", "Asia", "Caribbean",
                                       "Central America", "Europe",
                                       "Middle East", "North America",
                                       "Oceania", "South America")){

  states <- match.arg(region, choices = c("Africa", "Asia", "Caribbean",
                                          "Central America", "Europe",
                                          "Middle East", "North America",
                                          "Oceania", "South America"))

  if(grepl("Africa", states)){

    region_list <- c("Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cameroon", "Cape Verde (Cabo Verde)", "Central African Republic", "Chad", "Comoros", "Congo (Brazzaville)", "Cote d'Ivoire", "Democratic Republic of Congo (formerly Zaire)", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea Bissau", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Mayotte (France)", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Republic of Guinea", "Reunion (France)", "Rwanda", "Sao Tome e Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe")

    } else if(grepl("Asia", states)){

    region_list <- c("Afghanistan", "Bangladesh", "Bhutan", "Brunei Darussalam", "Cambodia", "China", "Democratic People's Republic of (North) Korea", "Hong Kong (China)", "India", "Indonesia", "Iran", "Japan", "Kazakhstan", "Kyrgyzstan", "Laos", "Macau (China)", "Malaysia", "Maldives", "Mongolia", "Myanmar (formerly Burma)", "Nepal", "Pakistan", "Philippines", "Republic of (South) Korea", "Singapore", "Sri Lanka", "Taiwan", "Tajikistan", "Thailand", "Turkmenistan", "Uzbekistan", "Vietnam")

  } else if(grepl("Caribbean", states)){

      region_list <- c("Anguilla (United Kingdom)", "Antigua and Barbuda", "Aruba (Netherlands)", "Bahamas", "Barbados", "Cayman Islands (United Kingdom)", "Cuba", "Cura\u00a7ao (Netherlands)", "Dominica", "Dominican Republic", "Grenada", "Guadeloupe (France)", "Haiti", "Jamaica", "Martinique (France)", "Puerto Rico (USA)", "Sint Maarten (Netherlands)", "St. Kitts and Nevis", "St. Lucia", "St. Vincent and the Grenadines", "Trinidad and Tobago", "Virgin Islands (United Kingdom)", "Virgin Islands (USA)")

  } else if(grepl("Central America", states)){

      region_list <-  c("Belize", "Costa Rica", "El Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua", "Panama")

  } else if(grepl("Europe", states)){

      region_list <- c("Albania", "Andorra", "Armenia", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina: Federation", "Bosnia and Herzegovina: Republika Srpska", "Bulgaria", "Croatia", "Cyprus (Republic of)", "Czech Republic", "Denmark", "Estonia", "Faeroe Islands (Denmark)", "Finland", "France", "Georgia", "Germany", "Gibraltar (United Kingdom)", "Greece", "Guernsey (United Kingdom)", "Hungary", "Iceland", "Ireland, Republic of", "Isle of Man (United Kingdom)", "Italy", "Jersey (United Kingdom)", "Kosovo/Kosova", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia (former Yugoslav Republic of)", "Malta", "Moldova (Republic of)", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Russian Federation", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom: England & Wales", "United Kingdom: Northern Ireland", "United Kingdom: Scotland")

  } else if(grepl("Middle East", states)){

    region_list <- c("Bahrain", "Iraq", "Israel", "Jordan", "Kuwait", "Lebanon", "Oman", "Qatar", "Saudi Arabia", "Syria", "United Arab Emirates", "Yemen")

  } else if(grepl("North America", states)){

    region_list <- c("Bermuda (United Kingdom)", "Canada", "Greenland (Denmark)", "United States of America")

  } else if(grepl("Oceania", states)){

    region_list <- c("American Samoa (USA)", "Australia", "Cook Islands (New Zealand)", "Fiji", "French Polynesia (France)", "Guam (USA)", "Kiribati", "Marshall Islands", "Micronesia, Federated States of", "Nauru", "New Caledonia (France)", "New Zealand", "Northern Mariana Islands (USA)", "Palau", "Papua New Guinea", "Samoa (formerly Western Samoa)", "Solomon Islands", "Timor-Leste (formerly East Timor)", "Tonga", "Tuvalu", "Vanuatu")

  } else{
    region_list <- c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "French Guiana/Guyane (France)", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela")
  }

  print(region_list)
}
