library(dplyr)
library(lubridate)

compute_panel_costs2 <- function(data,
                                 issue_costs,
                                 issue_col = "failure_type",
                                 id_col = "panel_id",
                                 install_col = "install_date",
                                 visits_col = "n_maintenances",
                                 routine_cost_per_visit = 300,
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
      maintenance_cost = visits * routine_cost_per_visit,
      replacement_cost = ifelse("event" %in% names(.) & event == 1, unit_cost, 0),
      total_cost = maintenance_cost + replacement_cost
    )
  
  # ---- Output summaries ----
  per_panel <- df %>%
    select(panel_id, failure_type, install_date, visits,
           maintenance_cost, replacement_cost, total_cost)
  
  totals <- list(
    total_failure_cost = sum(per_panel$replacement_cost, na.rm = TRUE),
    total_maintenance_cost = sum(per_panel$maintenance_cost, na.rm = TRUE),
    total_cost = sum(per_panel$total_cost, na.rm = TRUE)
  )
  
  list(per_panel = per_panel, totals = totals)
}
