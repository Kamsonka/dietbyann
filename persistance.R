get_meal <- function(source_date, meal) {
  filename <- glue("data/plan/{source_date}.json")
  if (file.exists(filename)) {
    day_plan <- jsonlite::read_json(filename, simplifyVector = TRUE)
    day_plan[[meal]]
  } else {
    ""
  }
}
save_meal <- function(id, value) {
  split <- strsplit(id, "_", fixed = T)[[1]]
  meal <- split[1]
  source_date <- lubridate::ymd(split[2])
  filename <- glue("data/plan/{source_date}.json")
  day_plan <- list()
  if (file.exists(filename)) {
    day_plan <- jsonlite::read_json(filename, simplifyVector = TRUE)
  }
  day_plan[[meal]] <- value
  jsonlite::write_json(day_plan, filename, simplifyVector = TRUE)
}

duplicate_tomorrow <- function(id) {
  split <- strsplit(id, "_", fixed = T)[[1]]
  source_date <- lubridate::ymd(split[1])
  target_date <- source_date + days(1)
  filename <- glue("data/plan/{source_date}.json")
  target <- glue("data/plan/{target_date}.json")
  file.copy(filename, target, overwrite = TRUE)
}
