sidebar <- function(page_title, icon_img) {
  bs4DashSidebar(
    skin = "light",
    status = "primary",
    title = page_title,
    brandColor = "primary",
    url = "https://www.google.com",
    src = icon_img,
    elevation = 3,
    opacity = 0.8,
    bs4SidebarMenu(
      bs4SidebarHeader("Diet creator"),
      bs4SidebarMenuItem("View diet by Ann", tabName = "view-ann", icon = "id-card"),
      bs4SidebarMenuItem("Compose diet", tabName = "compose-diet", icon = "sliders"),
      bs4SidebarMenuItem("Add recipe", tabName = "add-recipe", icon = "sliders"),
      bs4SidebarMenuItem("Shopping list", tabName = "shopping-list", icon = "sliders")
    )
  )
}

body <- function() {
  bs4DashBody(
    bs4TabItems(
      bs4TabItem(
        tabName = "view-ann",
        dateInput("selectedDate", "Pick date"),
        uiOutput("dateUI")
      ),
      bs4TabItem(
        tabName = "compose-diet",
        dateRangeInput("coposeDietDateRange", "Pick dates", start = today(), end = today() + days(6)),
        uiOutput("composeDietUI")
      ),
      bs4TabItem(
        tabName = "shopping-list",
        dateRangeInput("shoppingListDateRange", "Pick dates", start = today(), end = today() + days(6)),
        uiOutput("shoppingListUI")
      )
    )
  )
}

navigation <- bs4DashNavbar(
  skin = "light",
  status = "white",
  border = TRUE,
  sidebarIcon = "bars",
  controlbarIcon = "th",
  fixed = FALSE,
  rightUi = bs4DropdownMenu(
    show = FALSE,
    status = "danger",
    src = "https://www.google.fr",
    bs4DropdownMenuItem(
      message = "message 1",
      from = "Divad Nojnarg",
      src = "https://adminlte.io/themes/v3/dist/img/user3-128x128.jpg",
      time = "today",
      status = "danger",
      type = "message"
    ),
    bs4DropdownMenuItem(
      message = "message 2",
      from = "Nono Gueye",
      src = "https://adminlte.io/themes/v3/dist/img/user3-128x128.jpg",
      time = "yesterday",
      status = "success",
      type = "message"
    )
  )
)

controlbar <- bs4DashControlbar(
  skin = "light",
  title = "My right sidebar",
  sliderInput(
    inputId = "obs",
    label = "Number of observations:",
    min = 0,
    max = 1000,
    value = 500
  ),
  column(
    width = 12,
    align = "center",
    radioButtons(
      inputId = "dist",
      label = "Distribution type:",
      c("Normal" = "norm",
        "Uniform" = "unif",
        "Log-normal" = "lnorm",
        "Exponential" = "exp")
    )
  )
)
