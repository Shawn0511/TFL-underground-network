# Data processing

process_links <- function(loads, freq) {
  loads %>%
    group_by(from_station, to_station, line, dir) %>%
    summarise(total_passengers = sum(total_passengers), .groups = "drop") %>%
    inner_join(
      freq %>%
        group_by(from_station, to_station, line, dir) %>%
        summarise(total_trains = sum(total_trains), .groups = "drop"),
      by = c("from_station", "to_station", "line", "dir")
    ) %>%
    mutate(passengers_per_train = dplyr::if_else(
      total_trains == 0, NA_real_, total_passengers / total_trains)
    )
}

process_stations <- function(entries, exits) {
  full_join(entries, exits, by = "station") %>%
    replace_na(list(total_entries = 0, total_exits = 0)) %>%
    mutate(total_flow = total_entries + total_exits)
}

make_link_by_period <- function(loads_raw, use_qhr = FALSE) {
  if (use_qhr) stop("QHR not yet implemented")
  available_periods <- intersect(PERIODS, names(loads_raw))
  missing <- setdiff(PERIODS, names(loads_raw))
  if (length(missing) > 0) warning("Missing: ", paste(missing, collapse=", "))
  loads_raw %>%
    pivot_longer(cols = all_of(available_periods), names_to = "period", values_to = "passenger_flow") %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(
      line = standardise_line_name(line),
      passenger_flow = as.numeric(passenger_flow),
      period = factor(period, levels = PERIODS)
    )
}

make_link_by_qhr <- function(loads_raw) {
  # QHR: quarter-hourly columns
  qhr_cols <- grep("^q\\d{4}$", names(loads_raw), value = TRUE)
  
  loads_raw %>%
    clean_names() %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(across(all_of(qhr_cols), ~ as.numeric(replace_na(.x, 0)))) %>%
    group_by(from_station, to_station, line, dir) %>%
    summarise(across(all_of(qhr_cols), sum, na.rm = TRUE), .groups = "drop") %>%
    mutate(line = standardise_line_name(line))
}


# link-level delta builder
make_link_delta <- function(year1, year2,
                            day1 = "MTT", day2 = "TWT",
                            lf_threshold = 1.20) {
  
  seats_tbl <- tibble(line = names(SEATS_PER_TRAIN),
                      seats = unname(SEATS_PER_TRAIN))
  
  load_one <- function(y, d) {
    run_pipeline_memo(y, d)$links %>%
      left_join(seats_tbl, by = "line") %>%
      mutate(load_factor = total_passengers / (total_trains * seats))
  }
  
  base <- load_one(year1, day1) %>%
    select(from_station, to_station, line,
           total_passengers_1 = total_passengers,
           load_factor_1      = load_factor)
  
  post <- load_one(year2, day2) %>%
    select(from_station, to_station, line,
           total_passengers_2 = total_passengers,
           load_factor_2      = load_factor)
  
  base %>%
    inner_join(post, by = c("from_station", "to_station", "line")) %>%
    mutate(
      delta_pax = total_passengers_2 - total_passengers_1,
      pct_delta = delta_pax / total_passengers_1,
      delta_lf  = load_factor_2 - load_factor_1,
      crowded_2 = load_factor_2 > lf_threshold
    )
}

# station-level delta builder
make_station_delta <- function(year1, year2,
                               day1 = "MTT", day2 = "TWT") {
  
  st <- function(y, d) run_pipeline_memo(y, d)$stns %>%
    select(station, total_flow)
  
  st1 <- st(year1, day1) %>% rename(flow_1 = total_flow)
  st2 <- st(year2, day2) %>% rename(flow_2 = total_flow)
  
  inner_join(st2, st1, by = "station") %>%
    mutate(pct_delta = (flow_2 - flow_1) / flow_1)
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

# Drop total period for some EDA plot
drop_total_periods <- function(df) {
  if (!"period" %in% names(df)) return(df)
  df %>% filter(period %in% NOPERIOD)
}

