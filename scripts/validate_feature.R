library(fairqNewLocations)
library(dplyr)

# Load Data
data_raw <- load_data()

data_wohn <- list(grid = data_raw[["grid"]] %>%
                    select(x, y, wohnnutzung) %>%
                    slice_max(prop = 0.05, order_by = wohnnutzung))


data_kfz_per_24h <- list(grid = data_raw[["grid"]] %>%
                           select(x, y, kfz_per_24h) %>%
                           slice_max(prop = 0.05, order_by = kfz_per_24h))

data_traffic_intensity <- list(
  grid = data_raw[["grid"]] %>%
    select(x, y, traffic_intensity) %>%
    slice_max(prop = 0.05, order_by = traffic_intensity)
)

data_building_density <- list(
  grid = data_raw[["grid"]] %>%
    select(x, y, building_density) %>%
    slice_max(prop = 0.05, order_by = building_density)
)

data_nox_h <- list(grid = data_raw[["grid"]] %>%
                     select(x, y, nox_h) %>%
                     slice_max(prop = 0.05, order_by = nox_h))

data_nox_v <- list(grid = data_raw[["grid"]] %>%
                     select(x, y, nox_v) %>%
                     slice_max(prop = 0.05, order_by = nox_v))


station_map <- generate_station_map(data_raw)


map_feature <- generate_heat_map(data_wohn, "wohnnutzung") +
  generate_heat_map(data_kfz_per_24h, "kfz_per_24h") +
  generate_heat_map(data_traffic_intensity, "traffic_intensity") +
  generate_heat_map(data_building_density, "building_density") +
  generate_heat_map(data_nox_h, "nox_h") +
  generate_heat_map(data_nox_v, "nox_v") +
  station_map

save_map(map_feature)
