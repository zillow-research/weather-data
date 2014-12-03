calcPleasantDays <- function(
    metricsClean,
    projDir,
    meanTempRange = c(55, 75),  # Upper and lower limits on mean temp
    minTempThresh = 45,         # Lower limit for min temp
    maxTempThresh = 85,         # Upper limit for max temp
    allowableIndicators = c(0, 100000),  # Allowable weather indicators for FRSHTT variable
    isDebug = TRUE
)

{
    # ######################################################################### 
    # Calculates pleasant days given cleaned NOAA GSOD data. Inputs let user
    # determine definition of pleasant day.
    # 
    # Input: cleaned data (data.table).
    # 
    # Output: number of pleasant days by station (data.table). 
    # #########################################################################
    
    
    library(data.table)
    
    # Define paths, function name, etc.
    fun <- "calcPleasantDays"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    if (isDebug) debugCat(fun, "calculating pleasant days...")
    
    pleasant <- metricsClean[!is.na(TEMP) & !is.na(MIN) & !is.na(MAX)]
    pleasant <- pleasant[!(Month == 2 & DayOfMonth == 29)]
    
    # Determine whether a day was pleasant at the level of station and day
    pleasant[, Pleasant := 0]
    pleasant[meanTempRange[1] <= TEMP & TEMP <= meanTempRange[2] &
                 MIN >= minTempThresh & MAX <= maxTempThresh &
                 PRCP == 0 & SNDP == 0 &
                 FRSHTT %in% allowableIndicators,
             Pleasant := 1]
    
    # Take average, grouping by station, month, and day of month
    pleasant <- pleasant[, list(PleasantMeanModa = mean(Pleasant)),
                         by = c("STN...", "WBAN", "Month", "DayOfMonth")]
    
    # Aggregate to the station level (no more time variables)
    pleasant <- pleasant[, list(PleasantDays = sum(PleasantMeanModa),
                                DaysInYearDataCnt = .N),
                         by = c("STN...", "WBAN")]
    
    pleasant <- pleasant[DaysInYearDataCnt == 365]
    pleasant[, DaysInYearDataCnt := NULL]
    
    if (isDebug) debugCat(fun, "done!")
    
    return(pleasant)
}