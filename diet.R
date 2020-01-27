library(jsonlite)
library(httr)
library(purrr)
library(crayon)
library(glue)
library(lubridate)

# Function expects date as a string in YYYY-MM-DD format
get_diet_day <- function(date = "2020-01-27") {
  QUERY <- 'query DayPlan($date: Date!, $canBeCopiedToDate: Date!) {  me {    id    goal { reachedBecauseOfLoseWeight reachedBecauseOfPutOnWeight lostBecauseOfLoseWeight lostBecauseOfPutOnWeight __typename    }    dayPlan(date: $date) { __typename ... on UnauthorizedException {   code   __typename } ... on UserDayPlanDoesNotExistDisplayAnotherDay {   date   __typename } ... on DietOutsideAccess {   __typename } ... on PendingPayment {   token   description   __typename } ... on DietWillBeAvailableInFuture {   date   __typename } ... on UserDayPlanSuccess {   date   canBeCopiedToDate(targetDate: $canBeCopiedToDate)   events {     __typename     ... on Meal {  name  id  key  original {    id    dishes {      id      name      __typename    }    __typename  }  kcal  macro {    protein {      grams      kcal      percentage      __typename    }    animalProtein {      grams      kcal      percentage      __typename    }    fat {      grams      kcal      percentage      __typename    }    carbohydrates {      grams      kcal      percentage      __typename    }    __typename  }  preparationTime {    years    months    days    hours    minutes    seconds    __typename  }  dishes {    id    key    name    recipe    recipeNote    hasReplacement    isPortioned    portions    portionsTotal    isFirstOccurance    isLastOccurance    triangleOfPower {      body      mind      libido      __typename    }    ingredients {      key      productAmountId      productId      name      hasReplacement      category {   id   isSeasoning   isOptional   name   __typename      }      measurements {   amount   unit   text   __typename      }      original {   productId   name   measurements {     amount     unit     text     __typename   }   __typename      }      replacements {   productId   name   measurements {     amount     unit     text     __typename   }   __typename      }      saleProductVariant {   link   __typename      }      __typename    }    __typename  }  __typename     }     ... on Training {  duration  burnedCalories  activities {    duration    timeOfDay    burnedCalories    type {      fullName      __typename    }    __typename  }  __typename     }   }   diet {     id     kcal     macro {  protein {    grams    kcal    percentage    __typename  }  animalProtein {    grams    kcal    percentage    __typename  }  fat {    grams    kcal    percentage    __typename  }  carbohydrates {    grams    kcal    percentage    __typename  }  __typename     }     __typename   }   __typename }    }    diet { availableDays {   date   holiday {     identifier     name     description     icon     __typename   }   __typename } accessTo nextDaySet: set(date: $canBeCopiedToDate) {   ... on UserDietSet {     dietSetId     __typename   }   __typename } set(date: $date) {   ... on UserDietSet {     dietSetId     holiday {  identifier  name  description  icon  __typename     }     __typename   }   __typename } __typename    }    activeSubscriptions { givesAccessToDiet __typename    }    isTimeToNagForCurrentMeasurement    __typename  }}'
  tomorrow <- as.character(ymd(date) + days(1))
  variables <- list(canBeCopiedToDate	= tomorrow, date	= date)
  url <- "https://apiv1.trainingbyann.pl/graphql"

  body <- list(operationName = "DayPlan", query = QUERY, variables = variables)
  response <- POST(url = url,
                   encode = "json",
                   add_headers(.headers = c("X-AppEnvironment" = "prod",
                                            "X-AppVersion" = "ReactWebApp/1.25.220",
                                            "X-Authentication" = "882cf4f3e54d02ca8b8360e93c2ae149f51b38f4")),
                   body = body)
  httr::stop_for_status(response)
  dietPlan <- httr::content(response)
}

print_diet_day <- function(dietPlan) {
  dailyMeals <- dietPlan$data$me$dayPlan$events
  dailyMeals %>% map(function(meal) {
    cat(bgGreen(meal$name))
    flush.console()
    cat("\r\n")
    map(meal$dishes, function(dish) {
      cat(glue("{dish$name}\r\n{red('Składniki')}:\r\n"))
      flush.console()
      map2(dish$ingredients, seq_along(dish$ingredients), function(ingredient, id) {
        measurements_raw <- map(ingredient$measurements, ~ glue("{.$amount} {.$unit}"))
        measurements_raw$sep <- " / "
        measurements <- do.call(paste, measurements_raw)
        cat(glue("\r\n {id}. {ingredient$name} [{measurements}]\r\n"))
      })
      cat(glue("\r\n {red('Przepis')}:\r\n"))
      flush.console()
      cat(glue("\r\n {dish$recipe}\r\n"))
      cat("\r\n")
    })
  }) %>% invisible()
}



