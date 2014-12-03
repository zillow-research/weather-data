mergeForLatLon <- function(pleasant, projDir, isDebug = TRUE)

{
    # ######################################################################### 
    # Merges pleasant days data with station info for lat/lon coords.
    # 
    # Input: pleasant days data (by station) (data.table).
    # 
    # Output: same data with cols for lat/lon coords (data.table).
    # #########################################################################
    
    
    library(data.table)
    
    # Define paths, function name, etc.
    fun <- "mergeForLatLon"
    dirRawData <- file.path(projDir, "rawData")
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    if (isDebug) debugCat(fun, "Merging for lat/lon info...")
    
    stnInfo <- fread(file.path(dirRawData, "isd-history.csv"))
    suppressWarnings(stnInfo[, `:=`(USAF      = as.integer(USAF),
                                    WBAN      = as.integer(WBAN),
                                    LAT       = as.numeric(LAT),
                                    LON       = as.numeric(LON),
                                    `ELEV(M)` = as.numeric(`ELEV(M)`),
                                    BEGIN     = as.integer(BEGIN),
                                    END       = as.integer(END))])
    setnames(stnInfo, "USAF", "STN...")
    latlon <- merge(pleasant, stnInfo, by = c("STN...", "WBAN"), all.x = TRUE)
    keepVars <- c("STN...", "WBAN", "PleasantDays", "LAT", "LON")
    latlon <- subset(latlon, select = keepVars)
    
    if (isDebug) debugCat(fun, "done!")
    
    return(latlon)
}