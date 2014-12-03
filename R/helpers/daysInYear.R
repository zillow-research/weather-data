daysInYear <- function(yr)
{
    d0 <- as.Date(ISOdate(yr,     1, 1))
    d1 <- as.Date(ISOdate(yr + 1, 1, 1)) - 1
    dif <- as.numeric(d1 - d0) + 1
    return(dif)
}