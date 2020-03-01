library(shiny)
library(bs4Dash)
library(glue)
library(jsonlite)
library(purrr)
library(purrrlyr)
library(dplyr)
library(htmlTable)

source("ui/bootstrap_components.R")
source("meals.R")
source("persistance.R")
source("shopping_list.R")

page_title <- "Diet by Kami"
icon_img <- "https://resize.goldenline.io/1/display/resize?url=https%3A%2F%2Fstatic.goldenline.pl%2Fuser_photo%2F045%2Fuser_3558701_70f711_huge.jpg&width=170&height=170&key=d4088ba7a08d4f8fb8c38f03db3949e4"

MEALS <- c("Breakfast", "Snack A", "Lunch", "Snack B", "Dinner")

shiny::shinyApp(
  ui = bs4DashPage(title = page_title, old_school = FALSE, sidebar_mini = TRUE,
    sidebar_collapsed = FALSE, controlbar_collapsed = TRUE, controlbar_overlay = TRUE,
    navbar = navigation,
    sidebar = sidebar(page_title, icon_img),
    controlbar = controlbar,
    body = body()
  ),
  server = function(input, output) {
    refresh <- reactiveVal(value = 0)

    output$composeDietUI <- renderUI({
      dietDateRange <- input$coposeDietDateRange
      dateRange <- seq(dietDateRange[1], dietDateRange[2], by = "day")
      tagList(
        div(style = "display:none", refresh()),
        bs4Table(cardWrap = TRUE, bordered = TRUE, striped = TRUE,
                 headTitles = c("Meal", as.character(dateRange)),
                 map(MEALS, function(meal) {
                   bs4TableItems(
                     bs4TableItem(meal),
                     map(dateRange, ~
                           bs4TableItem(
                             selectInput(inputId = glue("{meal}_{.}"),
                                         selected = get_meal(., meal),
                                         label = NULL,
                                         choices = c(Choose='', ALL_DISHES$name),
                                         selectize = TRUE,
                                         multiple = TRUE,
                                         width = "100%")
                           )
                     )
                   )
                 }),
                 bs4TableItems(
                   bs4TableItem("Actions"),
                   map(dateRange, ~
                         bs4TableItem(actionButton(
                           glue("{.}_duplicate_tomorrow"), label = "Tomorrow", icon = icon("copy")
                         ))
                   )
                 )
        )
      )
    })

    observe({
      dietDateRange <- input$coposeDietDateRange
      dateRange <- seq(dietDateRange[1], dietDateRange[2], by = "day")
      map(dateRange, function(date) {
        id <- glue("{date}_duplicate_tomorrow")
        observeEvent(input[[id]], {
          duplicate_tomorrow(id)
          refresh(isolate(refresh()) + 1)
        })
        map(MEALS, function(meal) {
          id <- glue("{meal}_{date}")
          observeEvent(input[[id]], {save_meal(id, input[[id]])})
        })
      })
    })

    output$shoppingListUI <- renderUI({
      shoppingDateRange <- input$shoppingListDateRange
      dateRange <- seq(shoppingDateRange[1], shoppingDateRange[2], by = "day")
      shopping_list <- create_shopping_list(dateRange)
      shopping_list %>% by_row(function(item) {
        bs4Card(
          title = item$name,
          width = 12,
          HTML(htmlTable(item$total[[1]]))
        )
      }) %>% {.$.out}
    })

    output$dateUI <- renderUI({
      diet <- read_plan(input$selectedDate)
      meals <- get_meals(diet)
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
