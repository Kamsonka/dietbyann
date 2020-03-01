require(purrr)

get_dish_ingredients <- function(dish) {
  filename <- glue("data/dishes/{dish}.json")
  dish <- jsonlite::read_json(filename, simplifyVector = TRUE)
  dish$ingredients
}

multiply_measurements <- function(measurements, count) {
  measurements$amount <- map(measurements$amount, ~ . * count)
  measurements
}

multiply_ingredients <- function(old_ingredients, count) {
  new_ingredients <- rlang::duplicate(old_ingredients)
  old_measurements <- new_ingredients[[1]]$measurements
  new_ingredients[[1]]$measurements <- map2(old_measurements, count, multiply_measurements)
  new_ingredients
}

collect_measurements <- function(measurements) {
  units <- map(measurements, ~ .$unit) %>% unlist %>% unique
  units_ok <- map_lgl(units, function(check_unit) {
    all(map_lgl(measurements, ~ check_unit %in% .$unit))
  })
  if (!any(units_ok)) {
    print(measurements)
    warning("All units failed!")
  }
  units_keep <- units[units_ok]
  map(measurements, ~ filter(., unit %in% units_keep)) %>%
    bind_rows() %>%
    select(amount, unit, text) %>%
    mutate(amount = unlist(amount), unit = unlist(unit), text = unlist(text)) %>%
    group_by(unit) %>%
    summarise(total = sum(amount))
}

create_shopping_list <- function(dates) {
  dishes <- map(dates, function(date) {
    filename <- glue("data/plan/{date}.json")
    if (file.exists(filename)) {
      jsonlite::read_json(filename, simplifyVector = TRUE) %>% unlist
    }
  }) %>%
    unlist %>%
    keep(~ . != "") %>%
    table
  add_ingredients <- tibble(name = names(dishes), count = dishes) %>%
    mutate(single_ingredients = map(name, get_dish_ingredients)) %>%
    mutate(ingredients = map2(single_ingredients, count, multiply_ingredients)) %>%
    select(ingredients) %>%
    unlist(recursive = FALSE) %>%
    unlist(recursive = FALSE) %>%
    bind_rows() %>%
    filter(name != "Woda") %>%
    mutate(name = unlist(name))
  add_ingredients %>%
    as_tibble() %>%
    group_by(name) %>%
    summarize(total = list(collect_measurements(measurements)))
}

# x <- create_shopping_list(seq(ymd("2020-02-29"), ymd("2020-03-06"), by = "day"))
