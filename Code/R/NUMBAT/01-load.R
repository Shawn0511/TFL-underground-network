# Data‐loading functions
library(readxl)

# internal helper
.read_sheet <- function(path, sheet) {
  tryCatch({
    read_excel(path, sheet = sheet, skip = 2) %>% clean_names()
  }, error = function(e) {
    warning(sprintf("Sheet '%s' not found in %s", sheet, basename(path)))
    tibble()
  })
}

load_link_loads <- function(path) {
  df <- .read_sheet(path, "Link_Loads")
  cols <- grep("^x\\d", names(df), value = TRUE)
  df %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(across(all_of(cols), ~ as.numeric(replace_na(.x, 0)))) %>%
    rowwise() %>%
    mutate(total_passengers = sum(c_across(all_of(cols)), na.rm = TRUE)) %>%
    ungroup() %>%
    select(from_station, to_station, line, dir, total_passengers)
}

load_link_freq <- function(path) {
  df <- .read_sheet(path, "Link_Frequencies")
  cols <- grep("^x\\d", names(df), value = TRUE)
  df %>%
    filter(!is.na(from_station), !is.na(to_station)) %>%
    mutate(across(all_of(cols), ~ as.numeric(replace_na(.x, 0)))) %>%
    rowwise() %>%
    mutate(total_trains = sum(c_across(all_of(cols)), na.rm = TRUE)) %>%
    ungroup() %>%
    select(from_station, to_station, line, dir, total_trains)
}

load_station_entries <- function(path) {
  df <- .read_sheet(path, "Station_Entries")
  if (nrow(df) == 0) return(tibble(station=character(), total_entries=numeric()))
  df %>%
    pivot_longer(starts_with("x"), names_to="time_bin", values_to="entries") %>%
    group_by(station) %>% summarise(total_entries=sum(entries, na.rm=TRUE), .groups="drop")
}

load_station_exits <- function(path) {
  df <- .read_sheet(path, "Station_Exits")
  if (nrow(df) == 0) return(tibble(station=character(), total_exits=numeric()))
  df %>%
    pivot_longer(starts_with("x"), names_to="time_bin", values_to="exits") %>%
    group_by(station) %>% summarise(total_exits=sum(exits, na.rm=TRUE), .groups="drop")
}

load_nbt <- function(year, day) {
  day2 <- resolve_day(year, day)
  path <- make_nbt_path(year, day2)
  message("Loading ", basename(path))
  list(
    loads_raw = .read_sheet(path, "Link_Loads"),
    loads     = load_link_loads(path),
    freq      = load_link_freq(path),
    entries   = load_station_entries(path),
    exits     = load_station_exits(path)
  )
}