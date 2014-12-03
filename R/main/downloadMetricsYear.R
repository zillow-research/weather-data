downloadMetricsYear <- function(
    yr,
    projDir,
    email,         # Your email address.
    nFiles = NULL, # For testing: number of files you want to read in for each year
    isDebug = TRUE
)
    
{
    # ######################################################################### 
    # Populate priDir/rawData/ with NOAA GSOD weather metrics. 
    # #########################################################################
    
    
    library(RCurl)
    
    # Define paths, function name, etc.
    fun <- "downloadMetricsYear"
    dirHelpers <- file.path(projDir, "R", "helpers")
    helpers <- dir(dirHelpers, "\\.R$", full.names = TRUE)
    
    # Source helper funs
    e <- environment()
    invisible(sapply(helpers, sys.source, envir = e))
    
    if (isDebug) debugCat(fun, "running for year", paste0(yr, "..."))
    
    # Collect file names from FTP
    if (isDebug) debugCat(fun, "finding file names...")
    userpwd <- paste("ftp", email, sep = ":")
    gsodUrl <- paste0("ftp://ftp.ncdc.noaa.gov/pub/data/gsod/", yr, "/")
    fwfsFtpDirty <- getURL(gsodUrl,
                           ftp.use.epsv = FALSE,
                           dirlistonly = TRUE,
                           userpwd = userpwd)
    fwfsFtp <- paste0(gsodUrl, strsplit(fwfsFtpDirty, "(\r){0,1}\n")[[1]])
    fwfsFtp <- fwfsFtp[grepl("\\.op\\.gz", fwfsFtp)]  # Exclude .tar file
    
    # Create folder for year (and for raw data if it doesn't already exist)
    dirYear <- file.path(projDir, "rawData", paste0("gsod_", yr))
    dir.create(dirYear, showWarnings = FALSE, recursive = TRUE)
    
    # Determine which files have already been downloaded. Don't download them 
    # again. Create data.frame of downloading information (e.g., from/to paths 
    # for each file, whether file is new / will be downloaded / has been
    # successfully downloaded / etc.) for potential debugging
    if (isDebug) debugCat(fun, "excluding downloaded files...")
    fwfsShort <- gsub(".*/", "", fwfsFtp)  # "Short" meaning not the full path
    fwfs <- data.frame(Short = fwfsShort,
                       Ftp = fwfsFtp,
                       Local = file.path(dirYear, fwfsShort),
                       New = ifelse(fwfsShort %in% dir(dirYear), 0, 1),
                       stringsAsFactors = FALSE)
    nFiles <- ifelse(is.null(nFiles),
                     length(fwfsFtp),
                     min(length(fwfsFtp), nFiles))
    fwfs$InNFiles <- ifelse(1:nrow(fwfs) <= nFiles, 1, 0)
    fwfs$ToDownload <- ifelse(fwfs$New & fwfs$InNFiles, 1, 0)
    fwfs$DlComplete <- 0  # Will switch to 1 when download completed
    nNewFiles <- sum(fwfs$New == 1 & fwfs$InNFiles)  # Number of new files
    nOldFiles <- sum(fwfs$New == 0 & fwfs$InNFiles)  # Number of old files
    if (nOldFiles > 0)
    {
        warning(paste0(nOldFiles, " files already downloaded.",
                       " Downloading ", nNewFiles, " new files."))
    }
    
    if (nNewFiles > 0)
    {
        # Download files
        if (isDebug) debugCat(fun, "downloading files...")
        ids <- which(fwfs$ToDownload == 1)  # Download files in these rows
        pb <- txtProgressBar(min = 0, max = length(ids), style = 3)
        on.exit(close(pb), add = TRUE)
        pbCount <- 0
        for (i in ids)  # sapply not cooperating, using loop
        {
            download.file(url      = fwfs$Ftp[i],
                          destfile = fwfs$Local[i],
                          method   = "auto",
                          quiet    = TRUE)
            pbCount <- pbCount + 1
            setTxtProgressBar(pb, pbCount)
            fwfs[i, "DlComplete"] <- 1
        }
        cat("\n")
    }
    
    if (isDebug) debugCat(fun, "done!")
    
    return(invisible(fwfs))
}