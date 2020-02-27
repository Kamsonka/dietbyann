library(shiny)
library(bs4Dash)
library(glue)
library(jsonlite)
library(purrr)
library(purrrlyr)
library(dplyr)

source("ui/bootstrap_components.R")

page_title <- "Diet by Kami"
icon_img <- "https://resize.goldenline.io/1/display/resize?url=https%3A%2F%2Fstatic.goldenline.pl%2Fuser_photo%2F045%2Fuser_3558701_70f711_huge.jpg&width=170&height=170&key=d4088ba7a08d4f8fb8c38f03db3949e4"

shiny::shinyApp(
  ui = bs4DashPage(title = page_title, old_school = FALSE, sidebar_mini = TRUE,
    sidebar_collapsed = FALSE, controlbar_collapsed = TRUE, controlbar_overlay = TRUE,
    navbar = navigation,
    sidebar = sidebar(page_title, icon_img),
    controlbar = controlbar,
    body = body()
  ),
  server = function(input, output) {

    output$dateUI <- renderUI({
      filename <- glue("data/raw/{input$selectedDate}.json")
      diet <- fromJSON(filename)
      meals <- diet$data$me$dayPlan$events %>%
        select(name, preparationTime, dishes) %>%
        as_tibble()
      fluidRow(
        map(1:nrow(meals), function(row) {
          meal <- meals[row, ]
          dishes <- meal$dishes[[1]]
          bs4Sortable(
            width = 4,
            p(class = "text-center", meal$name),
            map(1:nrow(dishes), function(dish_number) {
              dish <- dishes[dish_number, ]
              ingredients <- dish$ingredients[[1]]
              ingredients_note_args <- map(1:nrow(ingredients), function(ingredient_nr) {
                ingredient <- ingredients[ingredient_nr, ]
                measurements_raw <- map(ingredient$measurements, ~ glue("{.$amount} {.$unit}")) %>% unlist %>% as.list
                measurements_raw$sep <- " / "
                measurements <- do.call(paste, measurements_raw)
                glue("{ingredient$name} [{measurements}]")
              })
              ingredients_note_args$sep <- "<br />"
              ingredients_note <- do.call(paste, ingredients_note_args)

              bs4Card(
                title = dish$name,
                width = 12,
                HTML(ingredients_note),
                footer = HTML(gsub(pattern = "\\n", replacement = "<br/>", dish$recipe))
              )
            })
            )
          })
      )
    })
  }
)
