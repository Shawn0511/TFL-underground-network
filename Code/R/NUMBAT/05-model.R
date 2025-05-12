# Modelling and clustering

library(dplyr)
library(tidyr)
library(cluster)
library(factoextra)
library(caret)
library(randomForest)
library(tidygraph)
library(ggraph)
library(igraph)
library(ggplot2)
library(tibble)

#–– 1. K-Means on Overcrowded OD Pairs
cluster_overcrowded_od <- function(year, day, pct = .75, k = 3) {
  od <- run_pipeline(year, day)$links
  thr <- quantile(od$passengers_per_train, pct, na.rm = TRUE)
  od_h <- od %>%
    filter(passengers_per_train >= thr) %>%
    select(total_passengers, total_trains, passengers_per_train) %>%
    na.omit()
  mat <- scale(od_h)
  set.seed(123)
  km <- kmeans(mat, centers = k, nstart = 25)
  od_h$cluster <- factor(km$cluster)
  ggplot(od_h, aes(passengers_per_train, total_passengers, color = cluster)) +
    geom_point(alpha = .7, size = 3) +
    labs(title = paste0("K-means (k=",k,") on top ", pct*100, "% crowded OD pairs"),
         x = "Passengers per Train", y = "Total Passengers") +
    theme_minimal()
}

#–– 2. Hierarchical Clustering of Stations by Time-of-Day Profile
cluster_stations_by_profile <- function(year, day, k = 4) {
  byp <- run_pipeline(year, day)$byp_all
  mat <- byp %>%
    pivot_wider(names_from = period, values_from = passenger_flow, values_fill = 0) %>%
    column_to_rownames("station") %>%
    scale()
  distm <- dist(mat)
  hc <- hclust(distm, method = "ward.D2")
  fviz_dend(hc, k = k, rect = TRUE, show_labels = FALSE) +
    labs(title = paste0("Station clusters (k=",k,") by time-of-day"))
}

#–– 3. Random Forest to Predict Passenger Flow
rf_predict_flow <- function(years_to_use, day_rule = function(y) if (y<2022) "MTT" else "TWT") {
  # assemble data
  df <- map_dfr(years_to_use, function(y){
    d <- day_rule(y)
    rp <- run_pipeline(y, d)$byp_all
    rp$year <- y
    rp
  })
  # split
  set.seed(42)
  idx <- createDataPartition(df$passenger_flow, p = .8, list = FALSE)
  tr <- df[idx,]; te <- df[-idx,]
  rf <- randomForest(passenger_flow ~ line + period + year,
                     data = tr, ntree = 200, importance = TRUE)
  pred <- predict(rf, te)
  # plot obs vs pred
  ggplot(data.frame(obs = te$passenger_flow, pred), aes(obs, pred))+
    geom_point(alpha = .5)+ geom_abline(lty="dashed", col="red")+
    labs(title = "RF: Observed vs Predicted Flow", x="Observed", y="Predicted")+
    theme_minimal()
}

#–– 4. Louvain Community Detection on OD Network
detect_od_communities <- function(year, day, top_n = 1000) {
  links <- run_pipeline(year, day)$links
  edges <- links %>% arrange(desc(total_passengers)) %>% slice_head(top_n)
  g <- tbl_graph(
    edges = edges %>% select(from = from_station, to = to_station, weight = total_passengers),
    directed = FALSE
  )
  ig <- as.igraph(g)
  com <- cluster_louvain(ig, weights = E(ig)$weight)
  V(ig)$community <- membership(com)
  g2 <- as_tbl_graph(ig)
  ggraph(g2, layout="fr") +
    geom_edge_link(aes(width = weight), alpha = .3) +
    geom_node_point(aes(color = factor(community)), size = 2) +
    geom_node_text(aes(label = name, filter = degree(.)>50), repel=TRUE, size=2) +
    labs(title = "Louvain communities of top OD flows") +
    theme_graph()
}

