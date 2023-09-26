# fairq-new-locations

This repository hosts the R-functions & scripts we employed for identifying suitable locations for new measurement stations. 
Our selection process was guided by two principal methods:

1. **Hotspots:** This method aids in the identification of locations where our model consistently forecasts high concentrations of air pollutants.
2. **Novelty Detection:** This method helps in pinpointing locations that show significant disparities from the previously measured sites.

## How to get started

- Create an .Renviron file in the project folder, see `.Renviron_template` for the structure
- Build the R package
- Create database as described in https://github.com/INWT/fairq-data/tree/main/inst/db (schema fairq_raw)

## Most important files

The scripts for the two methods can be found in the `inst/RScripts` directory

```
inst/RScripts
├── hotspots.R  - creates the hotspot maps of air pollutants
└── novelties.R - creates maps of regions with a high potential for new measurment stations
```

Additional analyses can be found here:

```
scripts
├── example_plot_novelty_detection.R 
├── novelties_014_diff.R
├── novelties_descriptive_analysis.Rmd
└── validate_feature.R
```

## Input and output

### Input

- Database, schema `fairq_features`

### Output

- no output

## Code style

Please use the RStudio code autoformatter by pressing `Ctrl + Shift + A`
to format the selected code.

## Dependencies

To reproduce the analyses contained in this repository, you'll need to install certain dependencies. The following instructions are tailored for Ubuntu 18.04 and later versions:

```
sudo apt-get -y update \
   && apt-get install -y --no-install-recommends \
   libgdal-dev \
   libgeos-dev \
   libproj-dev \
   libudunits2-dev \
   && apt-get autoremove -y \
   && apt-get autoclean -y1
```

## Map Generation with Mapview

In this project, we extensively use the `mapview` package in R for map visualization. Here are a few tips on using this package:

* **Layering Maps:** Maps can be layered by using the `+` operator. For instance, if you have two map objects `map1` and `map2`, you can layer them like so: `map1 + map2`.

* **Side-by-Side Maps:** If you wish to place two maps side by side for comparison, you can use the `sync()` function. Example: `sync(map1, map2)`.

* **Side-By-Side Slider:** To put two maps on the same layer with a side-by-side slider (helpful in comparing two maps), you can use the pipe operator `|` (reminiscent of Unix-style piping). For example, `map1 | map2` will give you a single output where you can slide between `map1` and `map2`.

[Source](https://www.infoworld.com/article/3644848/astonishingly-easy-mapping-in-r-with-mapview.html)
