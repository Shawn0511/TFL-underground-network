# Configuration: paths, libraries, parameters, palette

# core libraries
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(janitor)
library(stringr)
library(ggplot2)
library(tidygraph)
library(ggraph)

# Each years exist under Data/Raw/NUMBAT/
numbat_root   <- here("Data","Raw","NUMBAT")
year_folders  <- list.dirs(numbat_root, full.names = FALSE, recursive = FALSE)
year_folders  <- year_folders[str_detect(year_folders, "^NUMBAT \\d{4}$")]
years         <- year_folders %>% 
  str_remove("^NUMBAT ") %>% 
  as.integer()

# Days of week for each year
days <- c("TWT","MON","FRI","SAT","SUN")

# helper to build each Excel path
make_nbt_path <- function(year, day) {
  year_folder <- paste("NUMBAT", year)
  file_name   <- sprintf("NBT%02d%s_outputs.xlsx", year %% 100, day)
  here("Data", "Raw", "NUMBAT", year_folder, file_name)
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

# time-period ordering
period_levels <- c("total","early","am_peak","midday","pm_peak","evening","late")

