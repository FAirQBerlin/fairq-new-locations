#' Load all data for novelty detection
#'
#' Loads all necessary data for novelty detection.
#' Save data in a Rdata file
#' and return data as list of data frames
#'
#' @return list of data.frames
#' 
#' @export
load_data <- function() {
  data_raw <- list(grid = send_query("grid"),
                   stations = send_query("station"))
  
  save(data_raw,
       file = "./inst/extdata/data_raw.Rds")
  
  return(data_raw)
}
