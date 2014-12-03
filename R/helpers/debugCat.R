debugCat <- function(..., sep = " ")
{
    cat(as.character(Sys.time()), ..., "\n", sep = sep)
}