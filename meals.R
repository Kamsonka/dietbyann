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

cache_dish <- function(dish_name, FULL_DISHES) {
  dish <- FULL_DISHES[FULL_DISHES$name == dish_name, ] %>%
    select(-id, -key, -isFirstOccurance, -isLastOccurance, -`__typename`) %>%
    mutate(ingredients = map(ingredients, ~ select(., name, measurements)))
  filepath <- glue("data/dishes/{dish_name}.json")
  jsonlite::write_json(dish, filepath, simplifyVector = TRUE)
}

cache_all_dishes <- function() {
  FULL_DISHES <- all_dishes("2019-11-17", "2020-03-15")
  ALL_DISHES_PURE <- FULL_DISHES %>%
    select(name, recipe) %>%
    unique() %>%
    apply(2, as.character) %>%
    as_tibble() %>%
    set_names(c("name", "recipe"))
  map(ALL_DISHES_PURE$name, ~ cache_dish(., FULL_DISHES))
  write.csv2(ALL_DISHES_PURE, ALL_DISHES_CACHE, row.names = FALSE)
}

ALL_DISHES <- readr::read_csv2(ALL_DISHES_CACHE) %>%
  select(name, recipe)
