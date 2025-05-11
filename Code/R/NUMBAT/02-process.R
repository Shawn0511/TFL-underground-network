# Data processing and feature engineering

process_links <- function(loads, freq) {
  loads %>%
    group_by(from_station, to_station, line, dir) %>%
    summarise(total_passengers = sum(total_passengers), .groups = "drop") %>%
    inner_join(
      freq %>% group_by(from_station, to_station, line, dir) %>%
        summarise(total_trains = sum(total_trains), .groups = "drop"),
      by = c("from_station","to_station","line","dir")
    ) %>%
    mutate(passengers_per_train = total_passengers / total_trains)
}

process_stations <- function(entries, exits) {
  full_join(entries, exits, by = "station") %>%
    replace_na(list(total_entries = 0, total_exits = 0)) %>%
    mutate(total_flow = total_entries + total_exits)
}

make_link_by_period <- function(loads_raw) {
  loads_raw %>%
    clean_names() %>%
    select(from_station:dir, total, early:late) %>%
    pivot_longer(total:late,
                 names_to = "period",
                 values_to = "passenger_flow") %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(
      passenger_flow = as.numeric(passenger_flow),
      period = factor(period, levels = period_levels)
    )
}
