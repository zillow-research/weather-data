downloadMetrics <- function(
    yrs,
    projDir,
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
    
    for (yr in yrs)
    {
        # Download .tar file
        if (isDebug) debugCat(fun, "downloading .tar for", paste0(yr, "..."))
        gsodPath <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod"
        tarFilename <- paste0("gsod_", yr, ".tar")
        tarUrl <- file.path(gsodPath, yr, tarFilename)
        tarPath <- file.path(projDir, "rawData", tarFilename)
        download.file(url = tarUrl, destfile = tarPath, method = "auto", mode = "wb")
        
        # Untar into new folder and delete .tar file
        if (isDebug) debugCat(fun, "extracting files for", paste0(yr, "..."))
        yrDir <- file.path(projDir, "rawData", paste0("gsod_", yr))
        dir.create(yrDir, showWarnings = FALSE)
        untar(tarfile = tarPath, exdir = yrDir)
        file.remove(tarPath)
    }
    
    if (isDebug) debugCat(fun, "done!")
    
    return(invisible(TRUE))
}