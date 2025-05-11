# Main Driver: load, process, EDA & network for different file

source("R/00-config.R")
source("R/01-load.R")
source("R/02-process.R")
source("R/03-eda.R")
source("R/04-network.R")

# Example for 2023 TWT
data23_twt <- load_nbt(2023, "TWT")
links23   <- process_links(data23_twt$loads, data23_twt$freq)
stns23    <- process_stations(data23_twt$entries, data23_twt$exits)
by_period <- make_link_by_period(data23_twt$loads)

# EDA
plot_top20_od(links23)
plot_top20_crowded(links23)
plot_station_flow(stns23)
plot_scatter_trains_vs_passengers(links23)
plot_hist_ppt(links23)
plot_line_period_profile(by_period)

# Network diagrams
plot_chord_diagrams(by_period)
