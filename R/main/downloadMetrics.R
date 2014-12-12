downloadMetrics <- function(
    yrs,
    projDir = getwd(),
    isDebug = TRUE
)
    
{
    # ######################################################################### 
    # Populate priDir/rawData/ with NOAA Global Surface Summary of Day (GSOD) 
    # weather metrics. 
    # #########################################################################
    
    # Define paths, function name, etc.
    fun <- "downloadMetrics"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    # Create folder for raw data if it doesn't already exist
    dirRawData <- file.path(projDir, "rawData")
    dir.create(dirRawData, showWarnings = FALSE)
    
    for (yr in yrs)
    {
        # Download .tar file
        if (isDebug) debugCat(fun, "downloading .tar for", paste0(yr, "..."))
        gsodPath <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod"
        tarFilename <- paste0("gsod_", yr, ".tar")
        tarUrl <- file.path(gsodPath, yr, tarFilename)
        tarPath <- file.path(dirRawData, tarFilename)
        download.file(url      = tarUrl,
                      destfile = tarPath,
                      method   = "auto",
                      mode     = "wb")
        
        # Create folder for untarred files. Test to see if file for year already
        # exists. If it does, remove all files in that folder
        yrDir <- file.path(dirRawData, paste0("gsod_", yr))
        dirHasFiles <- file.exists(yrDir) && length(dir(yrDir)) > 0
        if (dirHasFiles)
        {
            warning(paste0("Folder for ", yr, " data already exists. ",
                           "Removing any files and populating with ",
                           "new files."))
            file.remove(dir(yrDir, full.names = TRUE))
        }
        dir.create(yrDir, showWarnings = FALSE)
        
        # Untar into new folder and delete .tar file
        if (isDebug) debugCat(fun, "extracting files for", paste0(yr, "..."))
        untar(tarfile = tarPath, exdir = yrDir)
        file.remove(tarPath)
    }
    
    if (isDebug) debugCat(fun, "done!")
    
    return(invisible(TRUE))
}