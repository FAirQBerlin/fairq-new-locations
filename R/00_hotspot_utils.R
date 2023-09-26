#' Divide a vector into chunks and format them as comma-separated strings
#'
#' @description The chunks can be used for example in SQL queries
#'
#' @param vec a vector, e.g., of x coordinates
#' @param chunk_length (integer) maximal chunk size; Inf to return exactly one chunk
#'
#' @return list of strings like, e.g., "3, 4, 5"
#'
#' @export
comma_separated_chunks <- function(vec, chunk_length) {
  chunks <- split(vec, ceiling(seq_along(vec) / chunk_length))
  lapply(chunks, paste, collapse = ", ")
}


#' Get all x coordinates of Berlin city raster as numeric vector
#'
#' @return numeric vector containing all x coords sorted
#'
#' @export
get_all_x_coords <- function() {
  
  . <- NULL # fix linting
  
  x_choords <- send_query("all_x_coords_stadt_berlin") %>%
    .$x %>%
    sort()
}

#' Gets relevant model id for hotspot full model
#'
#' @param pollutant (string) "no2", "pm10" or "pm25"
#'
#' @return scalar (numeric)
#'
#' @export
get_relevant_model_id <- function(pollutant) {
  model_ids <- list(no2 = 3,
                    pm10 = 2,
                    pm25 = 1)
  model_id <- model_ids[[pollutant]]
  print(model_id)
  return(model_id) # Return scalar
}


#' Gets hotspot data for one chunk of x coords
#'
#' @param relevant_model_id (integer) Output of get_relevant_model_id, refers
#' to one pollutant implicitly
#' @param x_coord_chunk (vector of numerics) Vector of x coordinates to query
#' 
#' @return data.frame with cols x, y, avg, max, quantile_90
#'
#' @export
get_partial_hotspot_data <- function(relevant_model_id,
                                     x_coord_chunk) {
  partial_hotspot_data <- send_query(
    "predictions_grid_for_hotspots",
    model_id = relevant_model_id,
    x_coords = x_coord_chunk,
    database = Sys.getenv("DB_SCHEMA_TARGET")
  )
  return(partial_hotspot_data)
}


#' Gets hotspot data for all x coords
#'
#' @param pollutant (string) "no2", "pm10" or "pm25
#' @param x_coords_chunk_length (integer) How many x coordinates should be
#' queried at once?
#'
#' @return data.frame with cols x, y, avg, max, quantile_90
#'
#' @export
get_hotspot_data <- function(pollutant, x_coords_chunk_length) {
  ### Get model ID
  model_id <- get_relevant_model_id(pollutant)
  
  ### Prepare x coord chunks
  all_x_coords <- get_all_x_coords()
  all_x_coord_chunks <- comma_separated_chunks(all_x_coords,
                                               x_coords_chunk_length)
  n_chunks <- length(all_x_coord_chunks) # for logging
  
  ### Query by x coord chunk & append to hotspot_data dataframe
  logging("~ Starting to query hotspot data for %s chunks of x coords. ~",
          n_chunks)
  
  hotspot_data <- data.frame()
  for (x_coord_chunk in all_x_coord_chunks) {
    logging(
      "~~~ %s/%s query running ~~~",
      which(x_coord_chunk == all_x_coord_chunks),
      n_chunks
    )
    
    partial_hotspot_data <-
      suppressWarnings(get_partial_hotspot_data(model_id,
                                                x_coord_chunk))
    hotspot_data <- rbind(hotspot_data, partial_hotspot_data)
  }
  
  logging("~~~ Final hotspot data has dim of %s ~~~",
          dim(hotspot_data))
  
  return(hotspot_data)
}


#' Turn hotspot data into a filtered, spatial sf object
#'
#' @param hotspot_data (data.frame) dataframe for one pollutant with
#' @param metric (string) filter on this metric (must be a column in
#' hotspot_data)
#' @param frac (numeric) What share of all data should be filtered? Top
#' frac_render*100 % of the data will be kept.
#'
#' @return data.frame with cols x, y, avg, max, quantile_90
#'
#' @export
create_cells_sf <- function(hotspot_data, metric, frac) {
  
  .data <- NULL # fix linting
  
  cells <- hotspot_data %>%
    slice_max(.data[[metric]], prop = frac)
  cells_sf <- st_as_sf(cells,
                       coords = c("x", "y"),
                       crs = st_crs(25833))
  return(cells_sf)
}


#' Get Coordinates of measuring stations and turn them into a sf object (points)
#'
#' @return sf object with points
#'
#' @export
create_stations_sf <- function() {
  stations <- send_query("station_coords")
  stations_sf <- st_as_sf(stations,
                          coords = c("station_x", "station_y"),
                          crs = st_crs(25833))
  return(stations_sf)
}
