library(fairqNewLocations)
library(dplyr)
library(tidyr)
################################################################################
# Load Data
################################################################################
data_raw <- load_data()
################################################################################
# Variable selection for different polluntants
################################################################################
PM10 <- list(
  selected_vars = c("kfz_per_24h",
                    "traffic_intensity",
                    "building_density"),
  weights = c(0.6, 0.2, 0.2)
)

PM2.5 <- list(
  selected_vars = c("wohnnutzung",
                    "traffic_intensity",
                    "building_density"),
  weights = c(0.375, 0.375, 0.25)
)

NO2 <- list(
  selected_vars = c("kfz_per_24h",
                    "nox_v",
                    "nox_h"),
  weights = c(0.6, 0.3, 0.1)
)

QUANTILE_PCT <- 0.95
################################################################################
# Remove or add "virtual" station
################################################################################
# uncomment station number to remove a station
data_raw[["stations"]] <- data_raw[["stations"]] %>%
  filter(
    station_id %in% c(
      "010",
      "014",
      "018",
      "027",
      "032",
      "042",
      "077",
      "085",
      "115",
      "117",
      "124",
      "143",
      "145",
      "171",
      "174",
      "190",
      "221",
      "282"
    )
  )

## add station: e.g. Potsdamer Chaussee
data_raw[["stations"]] <- data_raw[["stations"]] %>%
  add_row(
    station_id = "666" ,
    station_x = 373775,
    station_y = 5817075,
    x = 373775,
    y = 5817075,
    wohnnutzung = 0,
    kfz_per_24h = 12900,
    traffic_intensity = 1.4261997342237995,
    building_density = 0,
    nox_h = 0,
    nox_v = 1.31
  )
################################################################################
# transform data
################################################################################
data_PM10 <- data_raw %>%
  add_var_info(PM10) %>%
  select_var_from_data() %>%
  drop_gridpoints_eq_to_station() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
data_PM2.5 <- data_raw %>%
  add_var_info(PM2.5) %>%
  select_var_from_data() %>%
  drop_gridpoints_eq_to_station() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()

data_NO2 <- data_raw %>%
  add_var_info(NO2) %>%
  select_var_from_data() %>%
  drop_gridpoints_eq_to_station() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
# Mean of all 3 pollutant
data_mean <- list(
  grid = data_NO2[["grid"]] %>%
    full_join(data_PM2.5[["grid"]], by = c("x", "y")) %>%
    full_join(data_PM10[["grid"]], by = c("x", "y")) %>%
    mutate(min_dist = (min_dist.x +
                         min_dist.y +
                         min_dist) / 3) %>%
    select(x, y, min_dist) %>%
    drop_na(),
  stations = data_raw[["stations"]],
  pollutant = "mean"
)
################################################################################
# generate maps
################################################################################
station_map <- generate_station_map(data_raw)
map_layered <- generate_heat_map(
  data_PM10 %>%
    filter_distances(QUANTILE_PCT, 1) %>%
    join_raw_data(data_raw),
  "min_dist"
) +
  generate_heat_map(
    data_PM2.5 %>%
      filter_distances(QUANTILE_PCT, 1) %>%
      join_raw_data(data_raw),
    "min_dist"
  ) +
  generate_heat_map(
    data_NO2 %>%
      filter_distances(QUANTILE_PCT, 1) %>%
      join_raw_data(data_raw),
    "min_dist"
  ) +
  generate_heat_map(
    data_mean %>%
      filter_distances(QUANTILE_PCT, 1) %>%
      join_raw_data(data_raw),
    "min_dist"
  ) +
  station_map

save_map(map_layered)
