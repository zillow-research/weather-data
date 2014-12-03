downloadMetrics <- function(
    yrs,
    projDir,
    email,
    nFiles = NULL,  # nFiles argument from downloadGsod
    isDebug = TRUE
)

{
    # ######################################################################### 
    # Populate priDir/rawData/ with NOAA Global Surface Summary of Day (GSOD) 
    # weather metrics (loops over other function). 
    # #########################################################################
    
    # Define paths, function name, etc.
    fun <- "downloadMetrics"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    fwfsList <- list()
    for (yr in yrs)
    {
        fwfsList[[as.character(yr)]] <- downloadMetricsYear(
            yr      = yr,
            projDir = projDir,
            email   = email,
            nFiles  = nFiles,
            isDebug = isDebug
        )
    }
    
    fwfs <- do.call(rbind, fwfsList)
    
    return(invisible(fwfs))
}