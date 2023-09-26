###############################################################################
# This Script calculates the difference in min_dist of a computation with     #
# all stations vs all station minus station 014                               #
###############################################################################
library(fairqNewLocations)
library(dplyr)
library(tidyr)
library(rdist)

# Variable selection for different polluntants
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

# Load Data
data_raw <- load_data()

# Computation with all Stations
data_PM10 <- data_raw %>%
  add_var_info(PM10) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
data_PM2.5 <- data_raw %>%
  add_var_info(PM2.5) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
data_NO2 <- data_raw %>%
  add_var_info(NO2) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()

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

grid_all <- data_mean[["grid"]]

# Computation without station 014
data_raw[["stations"]] <- data_raw[["stations"]] %>%
  filter(
    station_id %in% c(
      "010",
      #"014",
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

data_PM10 <- data_raw %>%
  add_var_info(PM10) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
data_PM2.5 <- data_raw %>%
  add_var_info(PM2.5) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()
data_NO2 <- data_raw %>%
  add_var_info(NO2) %>%
  select_var_from_data() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight() %>%
  add_eucl_dist()

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

grid_without_014 <- data_mean[["grid"]]

# The absolute differences between grid
test <- list(
  grid = data.frame(
    x = grid_all$x,
    y = grid_all$y,
    min_dist = abs(grid_all$min_dist - grid_without_014$min_dist)
  ),
  stations = data_raw[["stations"]],
  pollutant = "mean"
)

station_map <- generate_station_map(data_raw)

map_diff <- generate_heat_map(test %>%
                                filter_distances(QUANTILE_PCT, 1) %>%
                                join_raw_data(data_raw),
                              "min_dist") +
  station_map

save_map(map_diff)

################################################################################
# Check the distances between all stations                                     #
################################################################################
DIFF <- list(
  selected_vars = c(
    "wohnnutzung",
    "kfz_per_24h",
    "traffic_intensity",
    "building_density",
    "nox_h",
    "nox_v"
  ),
  weights = c(1, 1, 1, 1, 1, 1)
)

data_raw <- load_data()

data_diff <- data_raw %>%
  add_var_info(DIFF) %>%
  select_var_from_data() %>%
  drop_gridpoints_eq_to_station() %>%
  standardization(quantile = 0.95, cutoff = 1.0) %>%
  multiply_by_weight()

A <- data_diff[["stations"]] %>%
  select(-c("station_id", "x", "y")) %>%
  as.matrix()

dist_stations <- cdist(A, A)

dist_stations %>% heatmap(Colv = NA, Rowv = NA)
