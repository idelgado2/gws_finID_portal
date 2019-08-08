require(shiny)
require(rsconnect)
require(DT)
require(shinyTime)
require(shinyjs)
require(rdrop2)
library(leaflet)
library(leaflet.extras)
library(tidyverse)
#library(shinyalert)
finPhotoPath <- "/Users/isaacdelgado/Desktop/Testing/Photos/"  #"/home/ubuntu/Dropbox/FinID_curator2/FinPhotos/"
finCSVPath <-   "/Users/isaacdelgado/Desktop/Testing/CSVs/"  #"/home/ubuntu/Dropbox/FinID_curator2/FinCSVs/"

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

names(flds$coords) <- flds$sites

#add a red star next to mandatory fields
labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

epochTime <- function(){
  as.integer(Sys.time())
}

saveData <- function(dat){
  dat <- as.data.frame(dat)
  if(file.exists(paste0(finCSVPath,"test.csv"))){
    #append if file exists
    write.table(x = dat, file=paste0(finCSVPath,"/test.csv"),
                row.names = F, col.names = F,
                quote = T, append=T, sep = ",")
  }else{
    #write csv if file doesn't
    write.table(dat, file=paste0(finCSVPath,"/test.csv"),
                row.names = F, col.names = T,
                quote = T, append=F, sep = ",")
  }
}

savePhoto <- function(photo, photo_id){
  if(is.null(photo)){
    return()
  }else{
    file.copy(from = photo$datapath, to = paste0(finPhotoPath,photo_id,".", tools::file_ext(photo$datapath)))
  }
}

