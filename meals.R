require(lubridate)
require(progress)
require(readr)

read_plan <- function(date) {
  filename <- glue("data/raw/{date}.json")
  fromJSON(filename)
}

get_meals <- function(plan) {
  plan$data$me$dayPlan$events %>%
    select(name, preparationTime, dishes) %>%
    as_tibble()
}

all_dishes <- function(start, end) {
  dates <- seq(ymd(start), ymd(end), by = "days")
  bar <- progress_bar$new(total = length(dates))
  map(dates, ~ {bar$tick(); read_plan(.)}) %>%
    map(get_meals) %>%
    map(~ .$dishes) %>%
    unlist(recursive = FALSE) %>%
    map(~ select(., -c("recipeNote", "portions", "portionsTotal", "triangleOfPower"))) %>%
    bind_rows
}

ALL_DISHES_CACHE <- "data/cache/all_dishes.csv"

cache_all_dishes <- function() {
  ALL_DISHES <- all_dishes("2019-11-17", "2020-03-15") %>%
    select(name, recipe) %>%
    unique() %>%
    as_tibble() %>%
    apply(2, as.character)
  write.csv2(ALL_DISHES, ALL_DISHES_CACHE, row.names = FALSE)
}

ALL_DISHES <- readr::read_csv2(ALL_DISHES_CACHE) %>%
  select(name, recipe)
