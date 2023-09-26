#' Plots a Heatmap of for FAirQ Novelty Detection
#'
#' This Functions Plots a Heatmap
#'
#' @param data (list of 5) 1. grid, 2. stations 3. selected_vars 4. weights
#' 5. name of pollutant
#' @param zcol (string) name of column, which should be
#' displayed on the heat map
#' @return (mapView Object) heat map of mimimal distances
#' @export
generate_heat_map <- function(data, zcol = "min_dist") {
  x <- y <- NULL #fix linting
  grid <- data[["grid"]] %>%
    mutate(x_coord = x,
           y_coord = y)
  
  grid_coords_sf <- st_as_sf(grid,
                             coords = c("x_coord", "y_coord"),
                             crs = st_crs(25833))
  map <- mapView(
    grid_coords_sf,
    zcol = zcol,
    layer.name = data[["pollutant"]],
    col.regions = hcl.colors(n_distinct(grid[[zcol]]),
                             palette = "heat",
                             rev = TRUE),
    map.types = "CartoDB.Positron",
    # No border for the symbols:
    lwd = 0,
    cex = 3
  )
  return(map)
}

#' Plots a Map of Berlin with all 18 stations
#'
#' @param data (list of data.frames) 1. Grid with x,y Coordinates and a Distance
#'  2.Station
#' @return (mapView Object) map with stations
#' @export
generate_station_map <- function(data) {
  stations <- data[["stations"]]
  
  stations_coords_sf <- st_as_sf(stations,
                                 coords = c("station_x", "station_y"),
                                 crs = st_crs(25833))
  
  return(
    mapView(
      stations_coords_sf,
      color = "black",
      alpha = 1,
      cex = 5,
      col.regions = "white",
      alpha.regions = 1,
      legend = FALSE
    )
  )

}

#' Save mapview Object as html file
#'
#' This function saves a mapview object map as html file under the
#' same name as the name of the map variable.
#'
#' @param map (mapview object) the map to be saved
#' @param path (string) output path where html
#' @export
save_map <- function(map, path = "./inst/reports/") {
  mapshot(map,
          url = paste0(path,
                       "novelty_detection_",
                       deparse(substitute(map)),
                       ".html"))
}


#' Plots a Map of Berlin with all 18 stations
#'
#' @return map with stations (mapView Object)
#' @export
create_stations_map <- function() {
  mapView(
    create_stations_sf(),
    # color = "black",
    alpha = 1,
    cex = 5,
    col.regions = "white",
    alpha.regions = 1,
    legend = FALSE,
    layer.name = "Messstationen"
  )
}

#' Plots a map of filtered raster cells for a certain layer
#'
#' @param hotspot_data (data.frame) dataframe for a certain pollutant
#' @param column (string) column of dataframe to plot in map as layer
#' @param extra_layer_info (string) additional string to name layer - will be
#' used as a prefix for default layer name. Defaults to empty string.
#' @param frac_render (numeric) (numeric) What share of all data should be
#' rendered? Top frac_render*100% of data will be kept. Defaults to 10% (=0.1)
#' @param hide_layer (bool) Defaults to FALSE - should layer be hidden?
#' (= unticked)
#'
#' @return map with stations (mapView Object)
#' @export
create_cells_map <- function(hotspot_data,
                             column,
                             extra_layer_info = "",
                             frac_render = 0.1,
                             hide_layer = FALSE) {
  # Prep data
  cells_sf <- create_cells_sf(hotspot_data, column, frac_render)

  # Prep map inputs
  layer_name <-
    paste0(extra_layer_info, " ", column, " top ", frac_render * 100, "%")
  map_colors <- hcl.colors(n_distinct(cells_sf[[column]]),
                           palette = "heat",
                           rev = TRUE)
  # Create map
  mapView(
    cells_sf,
    zcol = column,
    col.regions = map_colors,
    alpha.regions = 0.6,
    map.types = "CartoDB.Positron",
    lwd = 0,
    # No border for the symbols
    cex = 3,
    layer.name = layer_name,
    hide = hide_layer
  )
}


#' Create hotspot maps for all three pollutants
#' @param hotspot_data (data.frame) dataframe for a certain pollutant
#' @param metric (string) ("avg", "quantile_90", or "max"
#' @param frac_render (numeric) (numeric) What share of all data should be
#' rendered? Top frac_render*100% of data will be kept. Defaults to 10% (=0.1)
#' @param type (string) "layered" or "synced"
#' @param save (bool) save file?
#' @export
create_all_pollutants_map <-
  function(hotspot_data,
           metric,
           frac_render,
           type = "layered",
           save = FALSE) {
    stations_map <- create_stations_map()
    
    if (type == "layered") {
      all_pollutants_map <-
        create_cells_map(hotspot_data[["no2"]], metric, "no2", frac_render) +
        create_cells_map(hotspot_data[["pm25"]], metric, "pm2.5", frac_render, hide_layer = T) +
        create_cells_map(hotspot_data[["pm10"]], metric, "pm10", frac_render, hide_layer = T) +
        stations_map
    }
    
    if (type == "synced") {
      all_pollutants_map <- sync(
        create_cells_map(hotspot_data[["no2"]], metric, "no2", frac_render) + stations_map,
        create_cells_map(hotspot_data[["pm25"]], metric, "pm2.5", frac_render) + stations_map,
        create_cells_map(hotspot_data[["pm10"]], metric, "pm10", frac_render, ) + stations_map
      )
    }
    
    if (save == TRUE) {
      map_filename <- sprintf(
        "hotspots_all_polls_%s_prop%s_%s_%s.html",
        metric,
        frac_render,
        type,
        format(Sys.time(), "%y_%m_%d-%Hh%Mm")
      )
      mapshot(all_pollutants_map,
              url = file.path("results", map_filename),
              title = map_filename)
    }
    
    return(all_pollutants_map)
  }
