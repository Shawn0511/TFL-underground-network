# Main Driver: load, process, EDA & network for different file

# Load scripts
source("Code/R/NUMBAT/00-config.R")
source("Code/R/NUMBAT/01-load.R")
source("Code/R/NUMBAT/02-process.R")
source("Code/R/NUMBAT/03-eda.R")
source("Code/R/NUMBAT/04-network.R")
source("Code/R/NUMBAT/05-model.R")

# Define main pipeline
run_pipeline <- function(year, day, include_qhr = FALSE) {
  message("------ Running pipeline for: ", year, " ", day, "------")
  data <- load_nbt(year, day)
  link_by_period <- make_link_by_period(data$loads_raw, use_qhr = FALSE) %>% mutate(day = day)
  
  list(
    loads_raw = data$loads_raw,
    links     = process_links(data$loads, data$freq),
    stns      = process_stations(data$entries, data$exits),
    byp_all   = link_by_period,
    byp       = drop_total_periods(link_by_period),
    qhr_wide  = if (include_qhr) make_link_by_qhr(data$loads_raw) else NULL
  )
}

run_pipeline_memo <- memoise::memoise(run_pipeline)

# Use of QHR data
qhr_data <- run_pipeline(2023, "TWT", include_qhr = TRUE)$qhr_wide
head(qhr_data)

# Modelling data for 2019 and 2023
link_delta_19_23 <- make_link_delta(2019, 2023, "MTT", "TWT")
station_delta_19_23 <- make_station_delta(2019, 2023, "MTT", "TWT")

# Run for one example, use NUMBAT data for 2023 TWT output first
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

# Matrix plot: Line-period passenger load across days (2023 TWT)
byp_all_days <- map_dfr(DAYS, ~ run_pipeline(2023, .x)$byp)
plot_line_period_by_day_matrix(byp_all_days)

# Matrix plot: Passenger load by Line-period across years (TWT & MTT)
byp_years <- map_dfr(years, function(y) {
  day <- resolve_day(y, "TWT")
  if (file.exists(make_nbt_path(y, day))) {
    df <- run_pipeline(y, day)$byp
    df$year <- y
    return(df)
  } else {
    return(tibble())
  }
})

plot_line_period_by_year_matrix(byp_years)

# EDA: Pre vs Post COVID Comparison (Total passenger flow by period and line)
byp_all_years <- map_dfr(years, function(y) {
  df <- run_pipeline(y, resolve_day(y, "TWT"))$byp_all
  df$year <- y
  df
})

plot_demand_by_period_all_years(byp_all_years)
plot_demand_by_line_all_years(byp_all_years)


# Network visualisation: Chord Diagrams
plot_chord_diagrams(results$byp_all)


# Modelling & Clustering
# K-means clustering with visible OD patterns
cluster_overcrowded_od(2023, "TWT", pct = .75, k = 3, top_label = 3)

# Dendrogram
cluster_stations_by_profile(2023, "TWT", k = 4)

# Station cluster time-profile
plot_station_cluster_profiles(2023, "TWT", k = 4)

# train crowding-alert model
res <- train_crowding_xgb(2019, 2023, "MTT", "TWT")

# Evaluate crowding-alert model
eval <- evaluate_crowd_model(
  model_obj = res$model,
  X_test    = res$X_test,
  y_true    = res$y_test,
  preds     = res$preds,
  plot_title = "2019→2023 MTT→TWT"
)


