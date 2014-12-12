readMetrics <- function(
    yrs,                                        # Years of raw data to read in.
    projDir = getwd(),
    isDebug = TRUE,                             # Show debug statements?
    nodes = max(1, floor(detectCores() * 4/5))  # No. of clusters to be used.
)

{
    # ######################################################################### 
    # Reads in NOAA GSOD data. If raw data for a selected year doesn't exist in
    # gsod_[yyyy] folders within rawData folder then an error is thrown. The raw
    # files are read in parallel. If a year's data is incomplete (in that it
    # doesn't have data from Jan 1 to Dec 31), then that year is dropped and the
    # user is given a warning. See README for data sources and more info.
    # 
    # Input: years (num vector); refers to years of raw data to be read in.
    # 
    # Output: aggregated raw data (data.table).
    # #########################################################################
    
    
    # Load libs
    libs <- c("data.table", "foreach", "doParallel")
    invisible(sapply(libs, library, character.only = TRUE))
    
    # Define paths, function name, etc.
    fun <- "readMetrics"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    dirRawData <- file.path(projDir, "rawData")
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    # Collect files for selected years
    if (isDebug) debugCat(fun, "collecting file names...")
    yrsRawGsod <- dir(dirRawData, "^gsod_[0-9]{4}$")
    yrsRaw <- as.numeric(gsub("^gsod_", "", yrsRawGsod))
    yrsRawMissing <- setdiff(yrs, yrsRaw)
    if (length(yrsRawMissing) > 0L)
    {
        stop(paste0("No raw data for year(s): ",
                    paste(yrsRawMissing, collapse = ", "),
                    "."))
    }
    fwfs <- dir(path = file.path(dirRawData,
                                 paste0("gsod_", yrs)),
                pattern = "\\.op",
                full.names = TRUE)
    
    # Split into groups for %dopar% loop (uses "nodes" groups or fewer)
    if (isDebug) debugCat(fun, "grouping for parallelization...")
    fwfsList <- split(fwfs, seq_along(fwfs) %% nodes)
    
    # Register and start nodes
    if (isDebug) debugCat(fun, "registering nodes...")
    cl <- makeCluster(nodes)
    on.exit(stopCluster(cl), add = TRUE)
    registerDoParallel(cl)
    if (!getDoParRegistered()) warning("doPar backend failed to register.")
    if (isDebug) debugCat(fun, "registered", getDoParWorkers(), "node(s).")
    
    # Read data in parallel
    if (isDebug) debugCat(fun, "reading raw data (in parallel)...")
    metricsRaw <- foreach(i = seq_along(fwfsList),
                          .combine = "rbind",
                          .multicombine = TRUE,
                          .packages = "data.table") %dopar%
    {
        rbindlist(lapply(fwfsList[[i]], readGsodFwf))
    }

    # Check to make sure imported data has complete years
    if (isDebug) debugCat(fun, "checking data completeness...")
    wrongDays <- metricsRaw[, list(FirstDay   = min(MODA),
                                   LastDay    = max(MODA),
                                   ActualDays = length(unique(MODA))),
                            by = "YEAR"]
    wrongDays <- wrongDays[, ExpectedDays := daysInYear(YEAR)]
    wrongDays <- wrongDays[ActualDays != ExpectedDays]
    badYrs <- wrongDays[, YEAR]
    if (length(badYrs) > 0L)
    {
        print(wrongDays)
        metricsRaw <- metricsRaw[!YEAR %in% badYrs]
        warning(paste("Days are missing for certain years (see above).",
                      "Subsetting data to exclude years with missing data."))
    }
    
    idVars <- c("STN...", "WBAN", "YEAR", "MODA")
    setkeyv(metricsRaw, idVars)
    
    # Remove dupes
    if (isDebug) debugCat(fun, "checking for duplicate rows...")
    dupes <- duplicated(metricsRaw)
    nDupes <- sum(dupes)
    if (nDupes > 0L)
    {
        metricsRaw <- metricsRaw[!dupes]
        warning(paste(nDupes, "duplicate rows removed."))
    }
    
    if (isDebug) debugCat(fun, "done!")
    
    return(metricsRaw)
}