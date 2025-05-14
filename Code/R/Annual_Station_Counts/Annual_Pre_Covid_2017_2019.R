# Load libraries
library(ggplot2)
library(openxlsx)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(reshape2)
library(ggthemes)
library(corrplot)
library(here)
library(tibble)
library(tidytext)


# ------Load Dataset-----

# Data file path
entry_exit_file <- here("Data", "filtered", "Annual_Station_Counts", "filtered_csv", "AC2017-2019_AnnualisedEntryExit_filtered.csv")

# Load Annual Entry/Exit Data
df_tapcount_pre_covid <- read_csv(entry_exit_file, show_col_types = FALSE)

# Clean numeric columns
num_cols <- c(
  "Weekday (Mon-Thu) Entries", "Friday Entries", "Saturday Entries", "Sunday Entries",
  "Weekday (Mon-Thu) Exits", "Friday Exits", "Saturday Exits", "Sunday Exits", "Annualised En/Ex"
)

df_tapcount_pre_covid[num_cols] <- lapply(df_tapcount_pre_covid[num_cols], function(x) as.numeric(gsub(",", "", x)))

# Add derived totals
df_tapcount_pre_covid <- df_tapcount_pre_covid %>%
  mutate(
    Weekly_Entries = rowSums(across(contains("Entries")), na.rm = TRUE),
    Weekly_Exits   = rowSums(across(contains("Exits")), na.rm = TRUE),
    Total          = `Annualised En/Ex`
  ) %>%
  filter(!is.na(year), !is.na(Total))

# Plot 1: Top Stations per Year
df_top_stations <- df_tapcount_pre_covid %>%
  group_by(year) %>%
  slice_max(order_by = Total, n = 20) %>%
  ungroup()

df_tapcount_pre_covid$year <- factor(df_tapcount_pre_covid$year)

ggplot(df_top_stations, aes(x = reorder_within(Station, Total, year), y = Total)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  facet_wrap(~ year, scales = "free_y") +
  scale_x_reordered() +
  labs(
    title = "Top 20 Busiest Stations per Year (2017–2019)",
    x = "Station",
    y = "Annual Volume"
  ) +
  theme_minimal()

# Plot 2: Annual volume Distribution for a single year (Pre_Covid)
ggplot(df_tapcount_pre_covid %>% filter(!is.na(Total), Total > 0),
       aes(x = Total)) +
  geom_histogram(bins = 30, fill = "darkorange", color = "white") +
  scale_x_log10() +
  facet_wrap(~ year, ncol = 1) +
  labs(title = "Annual Passenger Volume Distribution by Year (2017–2019, Log Scale)",
       x = "Annual Volume (log10 scale)", y = "Number of Stations") +
  theme_minimal()


# Plot 3: Combined distribution
ggplot(df_tapcount_pre_covid %>% filter(!is.na(Total), Total > 0),
       aes(x = Total)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "white") +
  scale_x_log10() +
  labs(title = "Combined Distribution of Annual Passenger Volume (2017–2019)",
       x = "Annual Volume (log10 scale)", y = "Number of Stations") +
  theme_minimal()


# Plot 4: Tap-in/Out imbalance
df_station_totals <- df_tapcount_pre_covid %>%
  group_by(Station) %>%
  summarise(
    TotalEntry = sum(Weekly_Entries, na.rm = TRUE),
    TotalExit = sum(Weekly_Exits, na.rm = TRUE)
  ) %>%
  mutate(
    Imbalance = TotalEntry - TotalExit,
    AbsImbalance = abs(Imbalance)
  ) %>%
  arrange(desc(AbsImbalance))

top_imbalance <- df_station_totals %>% slice(1:10)

ggplot(top_imbalance, aes(x = reorder(Station, AbsImbalance), y = Imbalance, fill = Imbalance > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("firebrick", "steelblue"), labels = c("More Exits", "More Entries")) +
  labs(title = "Top 10 Stations by Net Tap-in vs Tap-out Imbalance (2017–2019)",
       x = "Station", y = "Total Net Imbalance", fill = "Direction") +
  theme_minimal()


# Plot 5: Daily counts across network
daily_summary_pre_covid <- df_tapcount_pre_covid %>%
  summarise(
    Monday_Thu_Entries = sum(`Weekday (Mon-Thu) Entries`, na.rm = TRUE),
    Friday_Entries     = sum(`Friday Entries`, na.rm = TRUE),
    Saturday_Entries   = sum(`Saturday Entries`, na.rm = TRUE),
    Sunday_Entries     = sum(`Sunday Entries`, na.rm = TRUE),
    Monday_Thu_Exits   = sum(`Weekday (Mon-Thu) Exits`, na.rm = TRUE),
    Friday_Exits       = sum(`Friday Exits`, na.rm = TRUE),
    Saturday_Exits     = sum(`Saturday Exits`, na.rm = TRUE),
    Sunday_Exits       = sum(`Sunday Exits`, na.rm = TRUE)
  ) %>%
  pivot_longer(cols = everything(), names_to = "Day_Type", values_to = "Count") %>%
  mutate(
    Day = case_when(
      grepl("Monday_Thu", Day_Type) ~ "Mon-Thu",
      grepl("Friday", Day_Type)     ~ "Friday",
      grepl("Saturday", Day_Type)   ~ "Saturday",
      grepl("Sunday", Day_Type)     ~ "Sunday"
    ),
    Day = factor(Day, levels = c("Mon-Thu", "Friday", "Saturday", "Sunday")),
    Type = ifelse(grepl("Entries", Day_Type), "Entry", "Exit")
  )

ggplot(daily_summary_pre_covid, aes(x = Day, y = Count, fill = Type)) +
  geom_col(position = "dodge") +
  labs(title = "Network-wide Daily Demand (2017–2019)",
       x = "Day Type", y = "Passenger Count", fill = "Tap Type") +
  theme_minimal()


# Plot 6: Weekday vs Weekend Demand Comparison
df_Demand_Comparison <- df_tapcount_pre_covid %>%
  mutate(
    Weekday_Total = `Weekday (Mon-Thu) Entries` + `Weekday (Mon-Thu) Exits` +
      `Friday Entries` + `Friday Exits`,
    Weekend_Total = `Saturday Entries` + `Saturday Exits` +
      `Sunday Entries` + `Sunday Exits`,
    Total_Volume = Weekday_Total + Weekend_Total
  )

top10_stations <- df_Demand_Comparison %>%
  arrange(desc(Total_Volume)) %>%
  slice(1:10) %>%
  pull(Station)

df_Demand_Comparison <- df_Demand_Comparison %>%
  mutate(Label = ifelse(Station %in% top10_stations, Station, NA))

ggplot(df_Demand_Comparison, aes(x = Weekday_Total, y = Weekend_Total)) +
  geom_point(alpha = 0.5, color = "steelblue", size = 2) +
  geom_text(aes(label = Label), hjust = 1.1, vjust = 0.5, size = 3.2, check_overlap = TRUE) +
  labs(title = "Weekday vs Weekend Passenger Volume (2017–2019)",
       x = "Total Weekday Volume", y = "Total Weekend Volume") +
  theme_minimal()


# Plot 7: Mode Comparison
df_mode_summary <- df_tapcount_pre_covid %>%
  group_by(Mode) %>%
  summarise(Total = sum(Total, na.rm = TRUE))

ggplot(df_mode_summary, aes(x = reorder(Mode, Total), y = Total)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  labs(title = "Total Volume by Transport Mode (2017–2019)",
       x = "Mode", y = "Total Volume") +
  theme_minimal()

# Plot 8: Clustering
df_cluster_raw <- df_tapcount_pre_covid %>%
  select(Station, contains("Entries"), contains("Exits")) %>%
  group_by(Station) %>%
  summarise(across(everything(), sum, na.rm = TRUE)) %>%
  ungroup()

df_cluster_scaled <- df_cluster_raw %>%
  column_to_rownames("Station") %>%
  scale()

set.seed(123)
km <- kmeans(df_cluster_scaled, centers = 3)

df_cluster_plot <- as.data.frame(df_cluster_scaled)
df_cluster_plot$Cluster <- as.factor(km$cluster)

autoplot(prcomp(df_cluster_scaled),
         data = df_cluster_plot,
         colour = "Cluster", label = TRUE) +
  labs(title = "K-means Clustering of Stations Based on Demand",
       color = "Cluster") +
  theme_minimal()