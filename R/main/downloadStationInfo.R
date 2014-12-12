downloadStationInfo <- function(projDir = getwd(), isDebug = TRUE)
    
{
    # ######################################################################### 
    # Populate priDir/rawData/ with NOAA Global Surface Summary of Day (GSOD) 
    # station info file.
    # #########################################################################
    
    
    # Define paths, function name, etc.
    fun <- "downloadStationInfo"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    # Create folder for raw data if it doesn't already exist
    dirRawData <- file.path(projDir, "rawData")
    dir.create(dirRawData, showWarnings = FALSE)
    
    # Download file
    if (isDebug) debugCat(fun, "downloading station info file...")
    pathFtp <- 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod/isd-history.csv'
    pathLocal <- file.path(projDir, "rawData", gsub(".*/", "", pathFtp))
    download.file(url      = pathFtp,
                  destfile = pathLocal,
                  method   = "auto",
                  quiet    = TRUE)
    
    if (isDebug) debugCat(fun, "done!")
    
    return(invisible(TRUE))
}