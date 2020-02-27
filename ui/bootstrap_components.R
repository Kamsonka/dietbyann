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
      bs4SidebarMenuItem("By date", tabName = "creator-by-date", icon = "id-card"),
      bs4SidebarMenuItem("By dish", tabName = "creator-by-dish", icon = "sliders")
    )
  )
}

body <- function() {
  bs4DashBody(
    bs4TabItems(
      bs4TabItem(
        tabName = "creator-by-date",
        dateInput("selectedDate", "Pick date"),
        uiOutput("dateUI")
      ),
      bs4TabItem(
        tabName = "creator-by-dish",
        bs4Card(
          title = "Card with messages",
          width = 9,
          userMessages(
            width = 12,
            status = "success",
            userMessage(
              author = "Alexander Pierce",
              date = "20 Jan 2:00 pm",
              src = "https://adminlte.io/themes/AdminLTE/dist/img/user1-128x128.jpg",
              side = NULL,
              "Is this template really for free? That's unbelievable!"
            ),
            userMessage(
              author = "Dana Pierce",
              date = "21 Jan 4:00 pm",
              src = "https://adminlte.io/themes/AdminLTE/dist/img/user5-128x128.jpg",
              side = "right",
              "Indeed, that's unbelievable!"
            )
          )
        )
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
