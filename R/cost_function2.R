library(dplyr)
library(lubridate)
library(ggplot2)

compute_panel_costs2 <- function(data,
                                 issue_costs,
                                 issue_col,
                                 id_col,
                                 install_col,
                                 visits_col,
                                 routine_cost_per_visit,
                                 as_of = Sys.Date()) {
  
  # ---- Load CSV if needed ----
  if (is.character(data) && length(data) == 1) {
    if (requireNamespace("readr", quietly = TRUE)) {
      data <- readr::read_csv(data, show_col_types = FALSE)
    } else {
      data <- utils::read.csv(data, stringsAsFactors = FALSE)
    }
  }
  
  # ---- Basic validation ----
  if (!visits_col %in% names(data)) {
    stop(paste("Column", visits_col, "not found in dataset."))
  }
  if (!issue_col %in% names(data)) {
    stop(paste("Column", issue_col, "not found in dataset."))
  }
  
  # ---- Prepare dataset ----
  df <- data %>%
    mutate(
      install_date = as.Date(.data[[install_col]]),
      failure_type = .data[[issue_col]],
      panel_id = .data[[id_col]],
      visits = .data[[visits_col]]
    )
  
  # ---- Join with issue-specific repair costs ----
  df <- df %>%
    left_join(issue_costs, by = c("failure_type" = "issue")) %>%
    mutate(unit_cost = ifelse(is.na(unit_cost), 0, unit_cost))
  
  # ---- Calculate costs ----
  df <- df %>%
    mutate(
      # Replacement happens if there's an 'event' column and event == 1
      replacement_cost = ifelse("event" %in% names(.) & event == 1, unit_cost, 0),
      maintenance_cost = visits * routine_cost_per_visit,
      total_cost = maintenance_cost + replacement_cost,
      failed = replacement_cost > 0   # ← NEW: derive failure flag directly
    )
  
  # ---- Output summaries ----
  per_panel <- df %>%
    select(panel_id, failure_type, install_date, visits, failed,
           maintenance_cost, replacement_cost, total_cost)
  
  totals <- list(
    total_failure_cost = sum(per_panel$replacement_cost, na.rm = TRUE),
    total_maintenance_cost = sum(per_panel$maintenance_cost, na.rm = TRUE),
    total_cost = sum(per_panel$total_cost, na.rm = TRUE)
  )
  
  # ---- Plot: Maintenance count vs. Total cost ----
  p <- ggplot(per_panel, aes(x = visits, y = total_cost, color = failed)) +
    # geom_point(size = 3, alpha = 0.8) +
    geom_jitter(width = 0.2, height = 50, size = 3, alpha = 0.7) +
    scale_color_manual(
      values = c("TRUE" = "red", "FALSE" = "green"),
      labels = c("TRUE" = "Failed", "FALSE" = "Not Failed"),
      name = "Panel Status"
    ) +
    labs(
      title = "Maintenance vs. Total Cost per Panel",
      x = "Number of Maintenance Visits",
      y = "Total Cost ($)"
    ) +
    theme_minimal(base_size = 14)
  
  print(p)
  
  # ---- Return results ----
  list(per_panel = per_panel, totals = totals, plot = p)
}
