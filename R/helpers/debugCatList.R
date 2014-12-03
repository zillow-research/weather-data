debugCatList <- function(project, ..., v)
{
    debugCat(project,
             paste0(..., "\n   "),
             paste(v, collapse = "\n    "))
}