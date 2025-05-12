# Exploratory plots
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggh4x)
library(RColorBrewer)

plot_top20_od <- function(df) {
  df %>% arrange(desc(total_passengers)) %>% slice_head(n = 20) %>%
    ggplot(aes(x = reorder(paste(from_station, "→", to_station), total_passengers),
               y = total_passengers)) +
    geom_col(fill = "steelblue") + coord_flip() +
    labs(title = "Top 20 OD Pairs by Total Passenger Flow",
         x = "OD Pair", y = "Total Passengers") + theme_minimal()
}

plot_top20_crowded <- function(df) {
  df %>% arrange(desc(passengers_per_train)) %>% slice_head(n = 20) %>%
    ggplot(aes(x = reorder(paste(from_station, "→", to_station), passengers_per_train),
               y = passengers_per_train)) +
    geom_col(fill = "firebrick") + coord_flip() +
    labs(title = "Top 20 Most Crowded Links",
         x = "OD Pair", y = "Passengers per Train") + theme_minimal()
}

plot_station_flow <- function(df) {
  df %>% arrange(desc(total_flow)) %>% slice_head(n = 20) %>%
    ggplot(aes(x = reorder(station, total_flow), y = total_flow)) +
    geom_col(fill = "darkgreen") + coord_flip() +
    labs(title = "Top 20 Busiest Stations",
         x = "Station", y = "Entries + Exits") + theme_minimal()
}

plot_scatter_trains_vs_passengers <- function(df) {
  ggplot(df, aes(x = total_trains, y = total_passengers)) +
    geom_point(alpha = 0.5) +
    labs(title = "Passenger Flow vs Train Supply",
         x = "Total Trains", y = "Total Passengers") + theme_minimal()
}

plot_hist_ppt <- function(df) {
  ggplot(df, aes(x = passengers_per_train)) +
    geom_histogram(bins = 50, fill = "orange", color = "white") +
    labs(title = "Distribution of Passengers per Train",
         x = "Passengers per Train", y = "Frequency") + theme_minimal()
}

plot_line_period_profile <- function(df) {
  df %>% group_by(line, period) %>% summarise(flow = sum(passenger_flow), .groups = "drop") %>%
    enforce_factors(c("line", "period")) %>%
    ggplot(aes(x = period, y = flow, fill = line)) +
    geom_col(position = "dodge") +
    scale_fill_manual(values = tube_line_colors, drop = FALSE) +
    labs(title = "Passenger Load by Line and Period",
         x = "Period", y = "Flow", fill = "Tube Line") + theme_minimal()
}

plot_station_crowding <- function(df) {
  df %>% mutate(crowding_ratio = total_entries / total_exits) %>%
    ggplot(aes(x = crowding_ratio)) +
    geom_histogram(bins = 40, fill = "purple", color = "white") +
    labs(title = "Distribution of Station Crowding Ratios",
         x = "Crowding Ratio", y = "Stations") + theme_minimal()
}

plot_avg_ppt_by_line <- function(df) {
  df %>% group_by(line) %>%
    summarise(avg_ppt = mean(passengers_per_train, na.rm = TRUE)) %>%
    arrange(desc(avg_ppt)) %>%
    ggplot(aes(x = reorder(line, avg_ppt), y = avg_ppt)) +
    geom_col(fill = "darkred") + coord_flip() +
    labs(title = "Average Passengers per Train by Line",
         x = "Line", y = "Avg Passengers per Train") + theme_minimal()
}

plot_top5_od_per_period <- function(df) {
  drop_total_periods(df) %>%
    group_by(period, from_station, to_station) %>%
    summarise(flow = sum(passenger_flow), .groups = "drop") %>%
    group_by(period) %>% slice_max(flow, n = 5) %>%
    ggplot(aes(x = reorder(paste(from_station, "→", to_station), flow),
               y = flow, fill = period)) +
    geom_col(show.legend = FALSE) + coord_flip() +
    facet_wrap(~ period, scales = "free_y") +
    labs(title = "Top 5 OD Pairs per Time Period",
         x = "OD Pair", y = "Passengers") + theme_minimal()
}




# Matrix plot:  passenger load by line and period, for all days
plot_line_period_by_day_matrix <- function(df) {
  df %>%
    filter(period %in% NOPERIOD) %>%
    group_by(line, period, day) %>% summarise(flow = sum(passenger_flow), .groups = "drop") %>%
    right_join(FULL_DAY_GRID, by = c("line", "period", "day")) %>%
    replace_na(list(flow = 0)) %>% enforce_factors(c("line", "period", "day")) %>%
    ggplot(aes(x = period, y = flow, fill = line)) +
    geom_col(position = "dodge") +
    ggh4x::facet_wrap2(~ day, ncol = 3, scales = "fixed", axes = "all") +
    scale_fill_manual(values = tube_line_colors, drop = FALSE) +
    labs(title = "Passenger Load by Line & Period (All Days)",
         x = "Period", y = "Flow", fill = "Tube Line") + theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          panel.spacing.y = unit(1.5, "lines"))
}


# Matrix plot: passenger load by line and period, for TWT of different years
plot_line_period_by_year_matrix <- function(df) {
  df %>%
    filter(period %in% NOPERIOD) %>%
    group_by(year, line, period) %>% summarise(flow = sum(passenger_flow), .groups = "drop") %>%
    right_join(FULL_YEAR_GRID(unique(df$year)), by = c("year", "line", "period")) %>%
    replace_na(list(flow = 0)) %>% enforce_factors(c("line", "period", "year")) %>%
    ggplot(aes(x = period, y = flow, fill = line)) +
    geom_col(position = "dodge") +
    ggh4x::facet_wrap2(~ year, ncol = 3, scales = "fixed", axes = "all") +
    scale_fill_manual(values = tube_line_colors, drop = FALSE) +
    labs(title = "Passenger Load by Line & Period (Across Years)",
         x = "Period", y = "Flow", fill = "Tube Line") + theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          panel.spacing.y = unit(1.5, "lines"))
}



# Compare total demand by period
plot_demand_by_period_all_years <- function(df) {
  df %>%
    group_by(year, period) %>%
    summarise(total_flow = sum(passenger_flow), .groups = "drop") %>%
    enforce_factors(c("period", "year")) %>%
    ggplot(aes(x = period, y = total_flow, fill = factor(year))) +
    geom_col(position = "dodge") +
    scale_fill_brewer(palette = "Set1") + 
    labs(title = "Total Passenger Flow by Period (All Years)",
         x = "Period", y = "Total Flow", fill = "Year") +
    theme_minimal()
}


# Compare total demand by line
plot_demand_by_line_all_years <- function(df) {
  df %>%
    group_by(year, line) %>%
    summarise(total_flow = sum(passenger_flow), .groups = "drop") %>%
    enforce_factors(c("line", "year")) %>%
    ggplot(aes(x = reorder(line, total_flow), y = total_flow, fill = factor(year))) +
    geom_col(position = "dodge") + coord_flip() +
    scale_fill_brewer(palette = "Set1") + 
    labs(title = "Total Passenger Flow by Line (All Years)",
         x = "Line", y = "Total Flow", fill = "Year") +
    theme_minimal()
}




