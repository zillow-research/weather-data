readGsodFwf <- function(fwf)
{
    ###########################################################################
    # Read NOAA Global Surface Summary of Day (GSOD) fixed-width file (fwf).
    ###########################################################################
    
    
    widths <- c(6, 1, 5, 2, 4, 4, 2, 6, 1, 2, 2, 6, 1, 2, 2, 6, 1, 2, 2,
                6, 1, 2, 2, 5, 1, 2, 2, 5, 1, 2, 2, 5, 2, 5, 2, 6, 1, 1,
                6, 1, 1, 5, 1, 1, 5, 2, 6)
    
    dcol <- "drop"
    cols <- c("STN---", dcol, "WBAN", dcol, "YEAR", "MODA", dcol,
              "TEMP", dcol, "TEMPCount", dcol, "DEWP", dcol,
              "DEWPCount", dcol, "SLP", dcol, "SLPCount", dcol,
              "STP", dcol, "STPCount", dcol, "VISIB", dcol,
              "VISIBCount", dcol, "WDSP", dcol, "WDSPCount", dcol,
              "MXSPD", dcol, "GUST", dcol, "MAX", "MAXFlag", dcol,
              "MIN", "MINFlag", dcol, "PRCP", "PRCPFlag", dcol, "SNDP",
              dcol, "FRSHTT")
    
    N <- "NULL"
    n <- "numeric"
    i <- "integer"
    h <- "character"
    classes <- c(i, N, i, N, i, i, N, rep(c(n, N, i, N), 6), n, N, n, N,
                 rep(c(n, h, N), 2), n, h, N, n, N, i)
    
    metrics <- read.fwf(file       = fwf,
                        widths     = widths,
                        skip       = 1,
                        col.names  = cols,
                        colClasses = classes)
    
    return(metrics)
}