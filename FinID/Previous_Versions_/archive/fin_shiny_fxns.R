#functions to support r shiny
#built with significant roots in shinyforms, https://github.com/daattali/shinyforms
#forked here: https://github.com/JayMox/shinyforms
#JHMoxley, 


epochTime <- function(){
  as.integer(Sys.time())
}
humanTime <- function() format(Sys.time(), "%Y%m%d-%H%M%OS")
#save fxn
#saving
saveData <- function(dat){
  fileName <- sprintf("here_lies_data.csv")
  write.table(x = data, file=file.path(dd, fN),
            row.names = F, quote = T, append=T, sep = ",")
}

savePhoto <- function(photo){
  png("/Users/jmoxley/Downloads/here_lies_photo.png")
  fileName <- sprintf("here_lies_photo.png")
  file.copy(photo, "/Users/jmoxley/Downloads/here_lies_photo.png")
  dev.off()
}

loadData <- function() {
  files <- list.files(file.path(responseDir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- dplyr::bind_rows(data)
  data
}

combData <- function(dat){
  #get csv's in file
  files <- list.files(file.path(responseDir), full.names = T)
  data <- lapply(files, read.csv, stringsAsFactors = F)
  data <- dplyr::bind_rows(data)
  
  data <- dplyr::bind_rows(data, dat)
  data
}
# #set mandatory, does not work right now
# fieldsMandatory <- c("observer", "site", "date", "sighting", "fin.photo")
# labelMandatory <- function(label){
#   tagList(
#     label,
#     span("*", class = "mandatory_star")
#   )
# }
# appCSS <-
#   ".mandatory_star { color: red; }"