# Main Driver: load, process, EDA & network for different file
library(purrr)
library(dplyr)

# Load scripts
source("Code/R/NUMBAT/00-config.R")
source("Code/R/NUMBAT/01-load.R")
source("Code/R/NUMBAT/02-process.R")
source("Code/R/NUMBAT/03-eda.R")
source("Code/R/NUMBAT/04-network.R")
source("Code/R/NUMBAT/05-model.R")

# Define main pipeline
run_pipeline <- function(year, day) {
  message("=== Running pipeline for: ", year, " ", day, " ===")
  data <- load_nbt(year, day)
  
  list(
    links   = process_links(data$loads, data$freq),
    stns    = process_stations(data$entries, data$exits),
    byp_all = make_link_by_period(data$loads_raw) %>% mutate(day = day),
    byp     = make_link_by_period(data$loads_raw) %>% mutate(day = day) %>% drop_total_periods()
  )
}


# === Run for one example: 2023 TWT ===
results <- run_pipeline(2023, "TWT")

# EDA
plot_top20_od(results$links)
plot_top20_crowded(results$links)
plot_station_flow(results$stns)
plot_scatter_trains_vs_passengers(results$links)
plot_hist_ppt(results$links)
plot_line_period_profile(results$byp)
plot_station_crowding(results$stns)
plot_avg_ppt_by_line(results$links)
plot_top5_od_per_period(results$byp)

# --- Matrix plot by DAY (2023 only) ---
byp_all_days <- map_dfr(DAYS, ~ run_pipeline(2023, .x)$byp)
plot_line_period_by_day_matrix(byp_all_days)

# --- Matrix plot across YEARS ---
byp_years <- map_dfr(years, function(y) {
  if (file.exists(make_nbt_path(y, resolve_day(y, "TWT")))) {
    df <- run_pipeline(y, "TWT")$byp
    df$year <- y
    return(df)
  } else {
    return(tibble())
  }
})

plot_line_period_by_year_matrix(byp_years)


# --- Pre vs Post COVID Comparison (All years) ---
byp_all_years <- map_dfr(years, function(y) {
  df <- run_pipeline(y, resolve_day(y, "TWT"))$byp_all
  df$year <- y
  df
})

plot_demand_by_period_all_years(byp_all_years)
plot_demand_by_line_all_years(byp_all_years)


# --- Chord Diagrams ---
plot_chord_diagrams(results$byp_all)


# MODELLING & CLUSTERING
# 1) K-means clusters
cluster_overcrowded_od(2023, "TWT", pct = .75, k = 3)

# 2) Station profile clusters
cluster_stations_by_profile(2023, "TWT", k = 4)

# 3) Predict with RF
rf_predict_flow(years)

# 4) Louvain on OD network
detect_od_communities(2023, "TWT", top_n = 1000)
