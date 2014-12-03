cleanMetrics <- function(
    metricsRaw,
    projDir,
    isDebug = TRUE
)

{
    # ######################################################################### 
    # Recode missing values in NOAA GSOD data and subset for relevant columns.
    # 
    # Input: raw data (data.table).
    # 
    # Output: cleaned data (data.table). 
    # #########################################################################
    
    
    library(data.table)
    
    # Define paths, function name, etc.
    fun <- "cleanMetrics"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    if (isDebug) debugCat(fun, "subsetting cols...")
    keepCols <- c("STN...", "WBAN", "YEAR", "MODA", "TEMP", "MAX",
                  "MIN", "PRCP", "PRCPFlag", "SNDP", "FRSHTT")
    metricsClean <- subset(metricsRaw, select = keepCols)
    
    # Create month and day of month cols
    if (isDebug) debugCat(fun, "creating additional date cols...")
    metricsClean[, `:=`(DayOfMonth = substr(MODA, nchar(MODA) - 1, nchar(MODA)),
                        Month      = substr(MODA, 1,               nchar(MODA) - 2))]
    metricsClean[, MODA := NULL]
    
    # Turn "missing" codes to NAs
    if (isDebug) debugCat(fun, "recoding \"missing\" codes to NAs...")
    colsToNa <- list()
    colsToNa[["9999.9"]] <- c("TEMP", "DEWP", "SLP",  "STP", "MAX", "MIN")
    colsToNa[["999.9"]]  <- c("VISIB", "WDSP", "MXSPD", "GUST")
    
    naCodes <- c(9999.9, 999.9)
    for (naCode in naCodes)
    {
        cols <- colsToNa[[as.character(naCode)]]
        for (.col in cols)
        {
            if (.col %in% names(metricsClean))
            {
                metricsClean[[.col]] <- ifelse(metricsClean[[.col]] == naCode,
                                               NA,
                                               metricsClean[[.col]])
            }
        }
    }
    
    # Set these variables' missing codes to zero instead of to NA
    if ("PRCP" %in% names(metricsClean)) metricsClean[PRCP == 99.99, PRCP := 0]
    if ("SNDP" %in% names(metricsClean)) metricsClean[SNDP == 999.9, SNDP := 0]
    
    if (isDebug) debugCat(fun, "done!")
    
    return(metricsClean)
}