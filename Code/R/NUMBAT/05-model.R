# Modelling and clustering

library(cluster)
library(factoextra)
library(caret)
library(randomForest)
library(igraph)
library(tibble)
library(xgboost)
library(SHAPforxgboost)
library(pROC)

# K-Means on Overcrowded OD Pairs
cluster_overcrowded_od <- function(year, day, pct = .75, k = 3, top_label = 3) {
  library(ggrepel)
  
  od <- run_pipeline(year, day)$links %>%
    mutate(od_pair = paste(from_station, "→", to_station))
  
  thr <- quantile(od$passengers_per_train, pct, na.rm = TRUE)
  
  od_h <- od %>%
    filter(passengers_per_train >= thr) %>%
    select(od_pair, total_passengers, total_trains, passengers_per_train) %>%
    na.omit()
  
  mat <- scale(od_h %>% select(-od_pair))
  set.seed(1234)
  km <- kmeans(mat, centers = k, nstart = 25)
  od_h$cluster <- factor(km$cluster)
  
  # Label top OD pair per cluster
  label_df <- od_h %>%
    group_by(cluster) %>%
    slice_max(total_passengers, n = top_label) %>%
    ungroup()
  
  ggplot(od_h, aes(passengers_per_train, total_passengers, color = cluster)) +
    geom_point(alpha = .6, size = 2.5) +
    geom_text_repel(
      data = label_df,
      aes(label = od_pair),
      size = 3,
      box.padding = 0.3,
      segment.color = "grey50"
    ) +
    labs(
      title = glue::glue("K-means (k={k}) on top {pct*100}% crowded OD pairs"),
      x = "Passengers per Train", y = "Total Passengers"
    ) +
    theme_minimal()
}


# Time Profile plot by cluster
plot_station_cluster_profiles <- function(year, day, k = 4) {
  # Read and pivot to station × time_bin
  path    <- make_nbt_path(year, day)
  entries <- .read_sheet(path, "Station_Entries") %>% clean_names()
  
  long <- entries %>%
    pivot_longer(starts_with("x"), names_to = "time_bin", values_to = "entries") %>%
    group_by(station, time_bin) %>%
    summarise(entries = sum(entries, na.rm = TRUE), .groups = "drop")
  
  # Build the wide matrix and scale it
  wide <- long %>%
    pivot_wider(names_from = time_bin, values_from = entries, values_fill = 0)
  mat  <- wide %>%
    select(-station) %>%
    as.matrix() %>%
    scale()
  rownames(mat) <- wide$station
  
  # Cluster
  hc <- hclust(dist(mat), method = "ward.D2")
  cl <- cutree(hc, k)       
  
  # Join clusters back into the long data
  long2 <- long %>%
    left_join(
      tibble(station = names(cl), cluster = factor(cl)),
      by = "station"
    )
  
  # Plot average profiles
  long2 %>%
    group_by(cluster, time_bin) %>%
    summarise(mean_entries = mean(entries), .groups = "drop") %>%
    ggplot(aes(x = time_bin, y = mean_entries, color = cluster, group = cluster)) +
    geom_line(linewidth = 1) +
    labs(
      title = glue::glue("Avg Entry Profiles by Cluster (k={k})"),
      x     = "Time Bin",
      y     = "Avg Entries",
      color = "Cluster"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Hierarchical Clustering Dendrogram 
cluster_stations_by_profile <- function(year, day, k = 4) {
  path    <- make_nbt_path(year, day)
  entries <- .read_sheet(path, "Station_Entries")
  if (!"station" %in% names(entries)) stop("Missing 'station' column")
  
  mat <- entries %>%
    pivot_longer(starts_with("x"), names_to = "time_bin", values_to = "entries") %>%
    group_by(station, time_bin) %>%
    summarise(entries = sum(entries, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = time_bin, values_from = entries, values_fill = 0) %>%
    column_to_rownames("station") %>%
    scale()
  
  hc <- hclust(dist(mat), method = "ward.D2")
  fviz_dend(as.dendrogram(hc), k = k, rect = TRUE,
            show_labels = TRUE,
            cex = 0.6) +
    labs(title = glue::glue("Station clusters (k={k}) by time-of-day")) +
    theme_minimal()
}



# Modelling: Feature builder
build_crowding_features <- function(year1, year2,
                                    day1        = "MTT",
                                    day2        = "TWT",
                                    lf_threshold= NULL,
                                    lf_pct      = 0.90) {
  
  delta <- make_link_delta(year1, year2, day1, day2, lf_threshold = Inf)
  
  # choose either absolute threshold or percentile
  thr <- if (!is.null(lf_threshold)) {
    lf_threshold
  } else {
    quantile(delta$load_factor_2, lf_pct, na.rm = TRUE)
  }
  
  df <- delta %>%
    mutate(target = as.numeric(coalesce(load_factor_2 > thr, FALSE))) %>%
    replace_na(list(
      pct_delta          = 0,
      load_factor_1      = 0,
      total_passengers_1 = 0,
      total_passengers_2 = 0
    )) %>%
    select(
      target,
      pct_delta,
      load_factor_1,
      total_passengers_1,
      total_passengers_2,
      line
    ) %>%
    mutate(
      line = as.integer(factor(line))
    ) %>%
    mutate(across(
      c(pct_delta, load_factor_1, total_passengers_1, total_passengers_2),
      scale
    ))
  
  return(df)
}

# Training + stratified CV + held-out evaluation
train_crowding_xgb <- function(year1, year2,
                               day1          = "MTT",
                               day2          = "TWT",
                               lf_threshold  = NULL,
                               lf_pct        = 0.90,
                               nrounds       = 400,
                               p_train       = 0.8,
                               early_stop    = 20,
                               cv_folds      = 5,
                               eta_vals        = c(0.05, 0.1),
                               max_depth_vals  = c(3, 5),
                               subsample       = 0.8,
                               colsample_bytree= 0.8) {
  
  # build features & labels
  df      <- build_crowding_features(year1, year2, day1, day2, lf_threshold, lf_pct)
  X       <- as.matrix(df %>% select(-target))
  y       <- df$target
  
  # stratified train/test split
  set.seed(1234)
  tr_idx <- caret::createDataPartition(factor(y), p = p_train, list = FALSE)
  X_train <- X[tr_idx, ]
  y_train <- y[tr_idx]
  X_test  <- X[-tr_idx, ]
  y_test  <- y[-tr_idx]
  
  dtrain  <- xgb.DMatrix(X_train, label = y_train)
  
  # hyper-parameter grid
  grid <- expand.grid(eta = eta_vals,
                      max_depth = max_depth_vals,
                      subsample = subsample,
                      colsample_bytree = colsample_bytree)
  
  # find the best params via xgb.cv
  best_auc     <- 0
  best_params  <- list()
  best_nrounds <- NULL
  
  # 5-fold stratified CV with early stopping
  for (i in seq_len(nrow(grid))) {
    params <- list(
      objective        = "binary:logistic",
      eval_metric      = "auc",
      eta              = grid$eta[i],
      max_depth        = grid$max_depth[i],
      subsample        = grid$subsample[i],
      colsample_bytree = grid$colsample_bytree[i]
    )
    
    cvres <- xgb.cv(
      params                = params,
      data                  = dtrain,
      nrounds               = nrounds,
      nfold                 = cv_folds,
      stratified            = TRUE,
      early_stopping_rounds = early_stop,
      verbose               = FALSE
    )
    
    mean_auc  <- max(cvres$evaluation_log$test_auc_mean)
    nbest     <- cvres$best_iteration
    
    if (mean_auc > best_auc) {
      best_auc     <- mean_auc
      best_params  <- params
      best_nrounds <- nbest
    }
  }
  
  message("Best CV AUC = ", round(best_auc, 4),
          "  (nrounds = ", best_nrounds, ")")
  
  
  # final model
  bst <- xgboost(data    = dtrain,
                 nrounds = best_nrounds,
                 params  = best_params,
                 verbose = 0)
  
  # predict on held-out
  preds <- predict(bst, X_test)
  
  # return everything for evaluation
  list(
    model   = bst,
    X_test  = X_test,
    y_test  = y_test,
    preds   = preds
  )
}

# evaluation
evaluate_crowd_model <- function(model_obj, X_test, y_true, preds, plot_title = "Crowd Alert") {
  # Sanity check
  valid_idx <- complete.cases(y_true, preds)
  y_true    <- y_true[valid_idx]
  preds     <- preds[valid_idx]
  X_test    <- X_test[valid_idx, , drop = FALSE]
  
  # ROC & AUC
  roc_obj <- pROC::roc(y_true, preds)
  auc_val <- pROC::auc(roc_obj)
  message("AUC = ", round(auc_val, 4))
  plot(roc_obj, main = paste0("ROC: ", plot_title))
  
  # Calibration plot
  calib_df <- tibble(true = y_true, prob = preds) %>%
    mutate(bin = ntile(prob, 10)) %>%
    group_by(bin) %>%
    summarise(obs = mean(true), pred = mean(prob), .groups = "drop")
  
  print(
    ggplot(calib_df, aes(x = pred, y = obs)) +
      geom_point() +
      geom_abline(lty = 2) +
      labs(
        title = paste0("Calibration: ", plot_title),
        x     = "Mean predicted probability",
        y     = "Observed fraction crowded"
      )
  )
  
  # SHAP importance
  sv <- shap.values(xgb_model = model_obj, X_train = X_test)
  shap_long <- shap.prep(shap_contrib = sv$shap_score, X_train = X_test)
  shap.plot.summary(shap_long)
  
  # Prediction histogram probability
  df_hist <- data.frame(prob = res$preds, actual = factor(res$y_test))
  
  ggplot(df_hist, aes(x = prob, fill = actual)) +
    geom_histogram(bins = 20, alpha = 0.7, position = "identity") +
    labs(title = "Predicted Probabilities by Actual Class",
         x = "Predicted Probability", fill = "Actual Crowded")
  
  invisible(list(
    auc   = auc_val,
    roc   = roc_obj,
    calib = calib_df,
    shap  = shap_long
  ))
}




