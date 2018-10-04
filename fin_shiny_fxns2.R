#clean sheet to help functional development
require(shiny)
require(rsconnect)
require(DT)
require(shinyTime)
require(shinyjs)
require(rdrop2)

#dirs
#dropbox spot
dropdd <- "FinID_curator/archive"
dropsc <- "FinID_curator/scratch"
dropfin <- "FinID_curator/FinIDs_staging"

#list of observers available to checkbox
flds <- list(
  observers = c("PK", "SA", "SJ", "JM", "TC", "TW", "EM", "OJ"),
  sites = c("PR", "FAR", "AN", "APT"),
  mandatory = c("user", "sex", "size")
)


##
#attempt to generalize
entries <- list(
  #list(id = "site.phid", type = "select", title = "Monitoring Site", choices = flds$sites),
  list(id = "date.phid", type = "date", title = "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
  list(id = "sighting", type = "text", title = "Sighting #", placeholder = "0?"),
  list(id = "matchsugg", type = "text", title = "Suggested Match", placeholder = "handle, tag#?"),
  list(id = "time", type = "text", title = "Time of sighting", placeholder = "0915")
  #list(id = "sex", type = "select", title = "Sex (U if unknown", choices = c("U","M","F"), selected="U"),
  #list(id = "size", type = )
)


  

labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}


#get data
loadData <- function(dir) {
  #add pattern for unique fN for survey
  files <- list.files(file.path(dir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- dplyr::bind_rows(data)
  data
}
#dropbox load
loadData2 <- function(phid.only = NULL) {
  #survey.only takes a phid & subsets files to that survey
  #get list of files
  if(!is.null(phid.only)){
    #extract only files w/in the survey
    files <- as.character(drop_dir(dropsc)$path_display)[
      grepl(substr(phid.only, 0, nchar(phid.only)-2), 
            as.character(drop_dir(dropsc)$path_display))]
  }else{
    files <- as.character(drop_dir(dropsc)$path_display)
  }
  
  #read in data
  data <- lapply(files, drop_read_csv, stringsAsFactors = F)
  data <- dplyr::bind_rows(data)
  data
}

############
##STORAGE FXNS
############
#write & save data (if no file); LOCALLY
saveData <- function(dat){
  #fileName <- sprintf("here_lies_data.csv")
  # write.table(x = dat, file=file.path(dd, fN),
  #             row.names = F, quote = T, append=T, sep = ",")
  dat <- as.data.frame(dat)
  if(file.exists(file.path(dd, fN))){
    #append if file exists
    write.table(x = dat, file=file.path(dd, fN),
                row.names = F, col.names = F,
                quote = T, append=T, sep = ",")
    # file.create(file.path(dd, 'igothere.csv'))
  }else{
    #write csv if file doesn't
    write.table(dat, file = file.path(dd, fN),
                row.names = F, col.names = T,
                quote = T, append=F, sep = ",")
  }
}
#using dropbox, individual files for entries
saveData2 <- function(data) {
  # get positioned
  data <- data.frame(data, stringsAsFactors = F)
  dropPath <- file.path(dropsc, data$dfN)
  tempPath <- file.path(tempdir(),
                        data$dfN)
  print(paste("storing data in this file", dropPath))
  #one entry per file
  write.csv(data, tempPath, row.names = F, quote = TRUE)
  drop_upload(tempPath, path = dropsc, mode = "add")
}


#save photo uploads w/ photoID
#dropbox style
savePhoto2 <- function(photo, phid){
  
  #set pathways
  dropPath <- file.path(dropfin)
  cat("drop here: ", dropPath, "\n")
  tempPath <- file.path(tempdir(), paste0(phid,
                        ".", tools::file_ext(photo$datapath)))
 
  #write data & upload
  cat("Copying file to:", tempPath ,"\n")
  file.copy(from = photo$datapath, to = tempPath)
  print(paste0("the local instance existence is ", file.exists(tempPath)))
  drop_upload(tempPath, dropPath, mode = "add")
}

#timestamping
epochTime <- function(){
  as.integer(Sys.time())
}
  
humanTime <- function(){
  as.Date(as.character(Sys.time()))
}
#####
#RESOURCES
#####
#https://github.com/daattali/shinyforms/blob/master/R/shinyform.R
#https://github.com/JayMox/shinyforms
#Multiple user lock out: https://community.rstudio.com/t/persistent-data-storage-in-apps-with-multiple-users/1308
#reset https://stackoverflow.com/questions/49344468/resetting-fileinput-in-shiny-app
#https://github.com/karthik/rdrop2#accessing-dropbox-on-shiny-and-remote-servers
#https://deanattali.com/blog/shiny-persistent-data-storage/