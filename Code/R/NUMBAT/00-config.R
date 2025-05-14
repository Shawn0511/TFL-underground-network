# Configuration: paths, libraries, parameters, palette

# core libraries needed
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(janitor)
library(stringr)
library(ggplot2)
library(tidygraph)
library(ggraph)
library(purrr)
library(ggh4x)


# Root NUMBAT folder
numbat_root <- here("Data", "Raw", "NUMBAT")

# Year folders and values
year_folders <- list.dirs(numbat_root, full.names = FALSE, recursive = FALSE)
year_folders <- year_folders[str_detect(year_folders, "^NUMBAT \\d{4}$")]
years        <- year_folders %>% str_remove("^NUMBAT ") %>% as.integer()

# Day labels & period levels
DAYS     <- c("TWT","MON","FRI","SAT","SUN")
PERIODS  <- c("total","early","am_peak","midday","pm_peak","evening","late")

# Pre-computed grids
NOPERIOD <- PERIODS[PERIODS != "total"]
# helper function for qhr
QHR_COLUMNS <- function(df) grep("^x\\d{1,2}$", names(df), value = TRUE)


# helper to build each Excel path
make_nbt_path <- function(year, day) {
  year_folder <- paste("NUMBAT", year)
  file_name <- sprintf("NBT%02d%s_outputs.xlsx", year %% 100, day)
  here("Data", "Raw", "NUMBAT", year_folder, file_name)
}

# Resolve day of TWT and MTT (TWT -> MTT)
resolve_day <- function(year, day) {
  path <- make_nbt_path(year, day)
  if (day == "TWT" && !file.exists(path)) {
    alt_path <- make_nbt_path(year, "MTT")
    if (file.exists(alt_path)) return("MTT")
  }
  return(day)
}

# TFL colour palette for each line
tube_line_colors <- c(
  Bakerloo               = "#B36305",
  Central                = "#E32017",
  DLR                    = "#00AFAD",
  District               = "#00782A",
  `Elizabeth Line`       = "#6950A1",
  `H&C and Circle`       = "#F3A9BB",
  Jubilee                = "#A0A5A9",
  `LO East London`       = "#EE7C0E",
  `LO Gospel Oak-Barking`= "#EE7C0E",
  `LO North London`      = "#EE7C0E",
  `LO Romford–Upminster` = "#EE7C0E",
  `LO Watford-Euston`    = "#EE7C0E",
  `LO West Anglia`       = "#EE7C0E",
  `London Trams`         = "#84B817",
  Metropolitan           = "#9B0056",
  Northern               = "#000000",
  Piccadilly             = "#003688",
  Victoria               = "#0098D4",
  `Waterloo & City`      = "#95CDBA"
)

FULL_DAY_GRID <- expand_grid(line = names(tube_line_colors), period = NOPERIOD, day = DAYS)
FULL_YEAR_GRID <- function(years) expand_grid(year = years, line = names(tube_line_colors), period = NOPERIOD)


#  seats_per_train = full-load capacity (seats + standing @ 6 pax/m²)
#  sources: TFL Rolling-stock Data Sheet 4th Ed. & Class 345 FOI docs
# But some of them are approximated and roughly estimated
SEATS_PER_TRAIN <- c(
  Bakerloo          = 876,
  Central           = 876,
  DLR               = 550,         
  District          = 1008,       
  "Elizabeth Line"  = 1500,
  "H&C and Circle"  = 1008,        
  Jubilee           = 1048,
  Metropolitan      = 1276,       
  Northern          = 952,
  Piccadilly        = 986,
  Victoria          = 950,
  "Waterloo & City" = 600
)

