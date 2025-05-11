# network visualization

# Chord network diagrams
plot_chord_diagrams <- function(link_by_period_df, top_n = 50) {
  link_by_period_df %>%
    group_by(period) %>%
    group_walk(~ {
      df <- .x %>%
        arrange(desc(passenger_flow)) %>%
        slice_head(top_n) %>%
        mutate(
          line = str_trim(line) %>%
            recode(
              "Circle"             = "H&C and Circle",
              "Hammersmith & City" = "H&C and Circle",
              .default = line
            ) %>%
            factor(levels = names(tube_line_colors))
        )
      
      graph <- tbl_graph(
        nodes = tibble(name = unique(c(df$from_station, df$to_station))),
        edges = df %>% select(from = from_station, to = to_station, line, passenger_flow),
        directed = TRUE
      )
      
      p <- ggraph(graph, layout = "linear", circular = TRUE) +
        geom_edge_arc(aes(width = passenger_flow, colour = line), alpha = 0.8) +
        scale_edge_colour_manual(values = tube_line_colors, drop = FALSE) +
        theme_graph(background = "grey20", text_colour = "white") +
        labs(title = paste("Chord Diagram –", toupper(df$period[1])))
      print(p)
    })
}

