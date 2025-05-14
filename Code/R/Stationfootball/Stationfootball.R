# Load Libraries
library(ggplot2)
library(dplyr)
library(readr)
library(lubridate)
library(here)

# Root Stationfootball folder
data_dir <- here("Data", "filtered", "Network_Demand")

# Load CSVs
footfall_files <- c(
  "filtered_StationFootfall_2019-2020.csv",
  "filtered_StationFootfall_2021-2025.csv"
)

# Read and combine the dataset
df_footfall <- footfall_files %>%
  file.path(data_dir, .) %>%
  lapply(read_csv) %>%
  bind_rows() %>%
  mutate(Date = as.Date(as.character(TravelDate), format = "%Y%m%d"))

# Daily Summary
daily_summary <- df_footfall %>%
  group_by(Date) %>%
  summarise(
    TotalEntry = sum(EntryTapCount, na.rm = TRUE),
    TotalExit = sum(ExitTapCount, na.rm = TRUE),
    .groups = "drop"
  )

# Weekly Average
weekly_summary <- daily_summary %>%
  mutate(Week = floor_date(Date, unit = "week")) %>%
  group_by(Week) %>%
  summarise(
    AvgEntry = mean(TotalEntry, na.rm = TRUE),
    AvgExit = mean(TotalExit, na.rm = TRUE),
    .groups = "drop"
  )

# Yearly Overlay
yearly_summary <- daily_summary %>%
  mutate(
    Year = year(Date),
    DayOfYear = yday(Date)
  ) %>%
  filter(DayOfYear <= 366)

# Define y axis scale to help comparison
y_max <- max(
  max(daily_summary$TotalEntry, daily_summary$TotalExit, na.rm = TRUE),
  max(weekly_summary$AvgEntry, weekly_summary$AvgExit, na.rm = TRUE),
  max(yearly_summary$TotalEntry, na.rm = TRUE)
)

# Custom Theme
custom_theme <- theme_minimal(base_size = 12) +
  theme(legend.position = "top")

# === Station Football EDA Plot ===
# Plot 1: Daily Tap-ins vs Tap-outs
ggplot(daily_summary, aes(x = Date)) +
  geom_line(aes(y = TotalEntry, color = "Entry Tap-ins"), size = 0.7) +
  geom_line(aes(y = TotalExit, color = "Exit Tap-outs"), size = 0.7) +
  scale_color_manual(values = c("Entry Tap-ins" = "steelblue", "Exit Tap-outs" = "firebrick")) +
  labs(title = "Daily Tap-ins and Tap-outs (2019–2025)",
       x = "Date", y = "Count", color = "Tap Type") +
  ylim(0, y_max) +
  custom_theme

# Plot 2: Weekly Average Tap-ins and Tap-outs
ggplot(weekly_summary, aes(x = Week)) +
  geom_line(aes(y = AvgEntry, color = "Avg Entry"), size = 0.8) +
  geom_line(aes(y = AvgExit, color = "Avg Exit"), size = 0.8) +
  scale_color_manual(values = c("Avg Entry" = "blue", "Avg Exit" = "red")) +
  labs(title = "Weekly-Averaged Tap-ins and Tap-outs (2019–2025)",
       x = "Week", y = "Average Count", color = "Tap Type") +
  ylim(0, y_max) +
  custom_theme

# Plot 3: Yearly Trends
ggplot(yearly_summary, aes(x = DayOfYear, y = TotalEntry)) +
  geom_line(color = "steelblue", size = 0.7) +
  facet_wrap(~ Year, ncol = 3, scales = "fixed") +
  ylim(0, y_max) +
  labs(title = "Yearly Entry Tap-in Trends by Day of Year",
       x = "Day of Year", y = "Total Tap-ins") +
  custom_theme
