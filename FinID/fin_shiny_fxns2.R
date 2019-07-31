require(shiny)
require(rsconnect)
require(DT)
require(shinyTime)
require(shinyjs)
require(rdrop2)
library(leaflet)
library(leaflet.extras)
library(tidyverse)
library(shinyalert)

#list of observers available to checkbox
flds <- list(
  observers = c("PK", "SA", "SJ", "JM", "TC", "TW", "EM", "OJ"),
  sites = c("PR", "FAR", "AN", "APT"),
  mandatory = c("user", "sex", "size"),
  coords = list(matrix(c(-123.00, 38.24), nrow=1), #Tomales station
                 matrix(c(-123.00, 37.69), nrow=1), #MiroungaBay station
                 matrix(c(-122.34, 37.11), nrow=1), #Ano tation
                 matrix(c(-121.93, 36.97), nrow=1))
)

#add a red star next to mandatory fields
labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}