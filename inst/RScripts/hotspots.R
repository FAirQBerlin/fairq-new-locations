#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Create maps for hotspots for whole grid predictions nov21-oct22
# for all pollutants and the metrics avg, max, quantile_90
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(dplyr)
library(fairqDbtools)
library(fairqNewLocations)
library(mapview)
library(leafsync)
# devtools::document()
# devtools::load_all()

### 00 Set data variables ----
pollutants <- c("no2", "pm10", "pm25")
metrics <- c("avg", "quantile_90", "max")
# Should query to get new predictions be sent to DB? (takes a few minutes)
query_data <- FALSE
# How many x coordinates should be queried at once?
x_coords_chunk_length <- 30

### 01 Get and save data ----
if (query_data == TRUE) {
  data_no2 <- get_hotspot_data("no2", x_coords_chunk_length)
  data_pm10 <- get_hotspot_data("pm10", x_coords_chunk_length)
  data_pm25 <- get_hotspot_data("pm25", x_coords_chunk_length)
  hotspot_data <- list("no2" = data_no2,
                       "pm10" = data_pm10,
                       "pm25" = data_pm25)
  # Save data
  timestamp_query <- format(Sys.time(), "%y_%m_%d-%Hh%Mm")
  save(hotspot_data,
       file = paste0("data/hotspot_data_", timestamp_query, ".RData"))
}

if (query_data == FALSE) {
  load(file.path("data/hotspot_data_22_11_21-14h30m.RData"))
}

### 02 Correlations of metrics ----
# Does the metric make a difference?
for (pollutant in pollutants) {
  cor_name <- paste0("cor_table_", pollutant)
  cor_table <- cor(hotspot_data[[pollutant]] %>% select(metrics))
  print(pollutant)
  print(cor_table)
  assign(cor_name, cor_table)
}

### 03 Maps ----
frac_render <- 0.05

### Create map for all 3 pollutants maps by metric
# a.) With layers
for (metric in metrics) {
  map_name <- paste0(metric, "_all_pollutants_map_layered")
  pollutants_map <- create_all_pollutants_map(
    hotspot_data,
    metric,
    frac_render,
    save = TRUE,
    type = "layered")
  assign(map_name, pollutants_map)
}

# b.) With Sync
for (metric in metrics) {
  map_name <- paste0(metric, "_all_pollutants_map_synced")
  # Synced map cannot be saved via mapshot. must be saved manually
  pollutants_map <- create_all_pollutants_map(
    hotspot_data,
    metric,
    frac_render,
    save = FALSE,
    type = "synced")
  assign(map_name, pollutants_map)
}

### 04 Save all results as .RData
objects_to_save <- c(ls(pattern = "_map_"), ls(pattern = "_table_"))
save(
  list = objects_to_save,
  file = file.path("results", "hotspots_maps_corr_tables.RData")
  )
