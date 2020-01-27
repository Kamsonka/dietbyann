library(jsonlite)
library(httr)
library(purrr)
library(dplyr)
library(lubridate)

RAW_HEADERS <- c("X-AppEnvironment" = "prod",
                    "X-AppVersion" = "ReactWebApp/1.25.220",
                    "X-Authentication" = "882cf4f3e54d02ca8b8360e93c2ae149f51b38f4")

# 
# QUERY <- "query DayPlanForTomorrow($date: Date!) {  me {    id    dayPlanForTomorrow: dayPlan(date: $date) {      __typename      ... on UserDayPlanSuccess {        date        events {          __typename          ... on Meal {            id            name            dishes {              name              recipeNoteForPreviousDay              __typename            }            __typename          }        }        __typename      }    }    __typename  }}"
# variables <- list(date	= "2020-01-28")
# url <- "https://apiv1.trainingbyann.pl/graphql"
# 
# body <- list(operationName = "DayPlanForTomorrow", query = QUERY, variables = variables)
# response <- POST(url = url,
#                  encode = "json",
#                  add_headers(.headers = RAW_HEADERS),
#                  body = body)
# content = httr::content(response)



QUERY <- {"query DayPlan($date: Date!, $canBeCopiedToDate: Date!) {
  me {
    id
    dayPlan(date: $date) {
      __typename
      ... on UserDayPlanSuccess {
        date
        canBeCopiedToDate(targetDate: $canBeCopiedToDate)
        events {
          __typename
          ... on Meal {
            name
            id
            key
            original {
              id
              dishes {
                id
                name
                __typename
              }
              __typename
            }
            kcal
            preparationTime {
              hours
              minutes
              __typename
            }
            dishes {
              id
              key
              name
              recipe
              recipeNote
              hasReplacement
              isPortioned
              portions
              portionsTotal
              isFirstOccurance
              isLastOccurance
              triangleOfPower {
                body
                mind
                libido
                __typename
              }
              ingredients {
                key
                productAmountId
                productId
                name
                hasReplacement
                category {
                  id
                  isSeasoning
                  isOptional
                  name
                  __typename
                }
                measurements {
                  amount
                  unit
                  text
                  __typename
                }
                original {
                  productId
                  name
                  measurements {
                    amount
                    unit
                    text
                    __typename
                  }
                  __typename
                }
                replacements {
                  productId
                  name
                  measurements {
                    amount
                    unit
                    text
                    __typename
                  }
                  __typename
                }
                saleProductVariant {
                  link
                  __typename
                }
                __typename
              }
              __typename
            }
            __typename
          }
          ... on Training {
            duration
            burnedCalories
            activities {
              duration
              timeOfDay
              burnedCalories
              type {
                fullName
                __typename
              }
              __typename
            }
            __typename
          }
        }
        __typename
      }
    }
    isTimeToNagForCurrentMeasurement
    __typename
  }
}"}

ymd('2019-11-27'):ymd('2020-01-27')
variables <- list(date	= "2020-01-27",
                  canBeCopiedToDate = "2020-01-28")

body <- list(operationName = "DayPlan", query = QUERY, variables = variables)
response <- POST(url = url,
                 encode = "json",
                 add_headers(.headers = RAW_HEADERS),
                 body = body)
content = httr::content(response)
content
