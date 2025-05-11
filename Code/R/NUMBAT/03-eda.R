# Exploratory plots

plot_top20_od <- function(df_links) {
  df_links %>%
    arrange(desc(total_passengers)) %>% slice_head(20) %>%
    ggplot(aes(
      x = reorder(paste(from_station,"→",to_station), total_passengers),
      y = total_passengers
    )) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    theme_minimal()
}

plot_top20_crowded <- function(df_links) {
  df_links %>%
    arrange(desc(passengers_per_train)) %>% slice_head(20) %>%
    ggplot(aes(
      x = reorder(paste(from_station,"→",to_station), passengers_per_train),
      y = passengers_per_train
    )) +
    geom_col(fill = "firebrick") +
    coord_flip() +
    theme_minimal()
}

plot_station_flow <- function(df_st) {
  df_st %>%
    arrange(desc(total_flow)) %>% slice_head(20) %>%
    ggplot(aes(
      x = reorder(station, total_flow), y = total_flow
    )) +
    geom_col(fill = "darkgreen") +
    coord_flip() +
    theme_minimal()
}

plot_scatter_trains_vs_passengers <- function(df_links) {
  ggplot(df_links, aes(total_trains, total_passengers)) +
    geom_point(alpha = 0.5) +
    theme_minimal()
}

plot_hist_ppt <- function(df_links) {
  ggplot(df_links, aes(passengers_per_train)) +
    geom_histogram(bins = 50, fill = "orange", color = "white") +
    theme_minimal()
}

plot_line_period_profile <- function(link_by_period_df) {
  link_by_period_df %>%
    group_by(line, period) %>%
    summarise(flow = sum(passenger_flow), .groups = "drop") %>%
    mutate(line = factor(line, levels = names(tube_line_colors))) %>%
    ggplot(aes(x = period, y = flow, fill = line)) +
    geom_col(position = "dodge") +
    scale_fill_manual(values = tube_line_colors, drop = FALSE) +
    theme_minimal()
}

