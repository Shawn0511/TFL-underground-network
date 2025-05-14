# network visualisation
library(ggraph)
library(tidygraph)
library(dplyr)
library(stringr)

# Chord network diagrams
plot_chord_diagrams <- function(df, top_n = 50) {
  df <- df %>% enforce_factors(c("line", "period"))
  plots <- list()
  
  for (p in levels(df$period)) {
    top_flows <- df %>% filter(period == p) %>% slice_max(passenger_flow, n = top_n) %>%
      enforce_factors("line")
    
    graph <- tidygraph::tbl_graph(
      nodes = tibble(name = unique(c(top_flows$from_station, top_flows$to_station))),
      edges = top_flows %>% select(from = from_station, to = to_station, line, passenger_flow),
      directed = TRUE
    )
    
    plot <- ggraph(graph, layout = "linear", circular = TRUE) +
      geom_edge_arc(aes(width = passenger_flow, color = line), alpha = 0.8) +
      geom_node_text(aes(label = name), size = 3, colour = "white", repel = TRUE) +
      scale_edge_width(range = c(0.3, 2.5)) +
      scale_edge_colour_manual(values = tube_line_colors, drop = FALSE) +
      theme_graph(background = "grey20", text_colour = "white") +
      labs(title = paste("Chord Diagram –", toupper(p)))
    
    print(plot)
    plots[[p]] <- plot
  }
  
  invisible(plots)
}
