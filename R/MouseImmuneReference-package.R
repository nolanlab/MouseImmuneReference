#' MouseImmuneReference
#'
#' @name MouseImmuneReference
#' @docType package
#' @import shiny
#' @import plyr
#' @importFrom reshape melt
#' @import ggplot2
#' @import igraph
#' @import cluster


#' @export
MouseImmuneReference.run <- function(launch.browser = TRUE, ...)
{
    runApp(appDir = file.path(system.file(package = "MouseImmuneReference"), "shinyGUI"), launch.browser = launch.browser, ...)
}



