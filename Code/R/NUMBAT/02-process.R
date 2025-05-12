# Data processing and feature engineering

process_links <- function(loads, freq) {
  loads %>%
    group_by(from_station, to_station, line, dir) %>%
    summarise(total_passengers = sum(total_passengers), .groups="drop") %>%
    inner_join(
      freq %>% group_by(from_station, to_station, line, dir) %>%
        summarise(total_trains = sum(total_trains), .groups="drop"),
      by = c("from_station","to_station","line","dir")
    ) %>%
    mutate(passengers_per_train = total_passengers / total_trains)
}

process_stations <- function(entries, exits) {
  full_join(entries, exits, by = "station") %>%
    replace_na(list(total_entries=0, total_exits=0)) %>%
    mutate(total_flow = total_entries + total_exits)
}

make_link_by_period <- function(loads_raw) {
  available <- intersect(PERIODS, names(loads_raw))
  missing <- setdiff(PERIODS, available)
  if (length(missing)>0) warning("Missing: ", paste(missing, collapse=", "))
  
  loads_raw %>%
    clean_names() %>%
    pivot_longer(cols = all_of(available), names_to="period", values_to="passenger_flow") %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(
      line = standardise_line_name(line),  # <-- ADD THIS LINE HERE
      passenger_flow = as.numeric(passenger_flow),
      period = factor(period, levels = PERIODS)
    )
}

# Factor enforcement helper
enforce_factors <- function(df, on = c("line", "period", "day", "year")) {
  if ("line" %in% on) df$line <- factor(df$line, levels = names(tube_line_colors))
  if ("period" %in% on) df$period <- factor(df$period, levels = PERIODS)
  if ("day" %in% on) df$day <- factor(df$day, levels = DAYS)
  if ("year" %in% on && "year" %in% names(df)) df$year <- factor(df$year, levels = sort(unique(df$year)))
  df
}

# Standardize line names
standardise_line_name <- function(line) {
  recode(as.character(line),
         "Circle" = "H&C and Circle",
         "Hammersmith & City" = "H&C and Circle",
         .default = as.character(line))
}

drop_total_periods <- function(df) {
  if (!"period" %in% names(df)) return(df)
  df %>% filter(period %in% NOPERIOD)
}

