
library(dplyr)
library(lubridate)

compute_panel_costs <- function(data,
                                issue_costs,
                                issue_col = "failure_type",
                                id_col = "panel_id",
                                install_col = "install_date",
                                routine_cost_per_visit = 800,
                                schedule_years = 1,    # 1 = yearly, 2 = every 2 years
                                as_of = Sys.Date(),
                                strict = TRUE) {
  
  # Load CSV if needed
  if (is.character(data) && length(data) == 1) {
    if (requireNamespace("readr", quietly = TRUE)) {
      data <- readr::read_csv(data, show_col_types = FALSE)
    } else {
      data <- utils::read.csv(data, stringsAsFactors = FALSE)
    }
  }
  
  # stopifnot(is.data.frame(data))
  # stopifnot(all(c("issue", "unit_cost") %in% names(issue_costs)))
  # stopifnot(issue_col %in% names(data))
  # stopifnot(install_col %in% names(data))
  
  # Convert dates
  data <- data %>%
    mutate(install_date = as.Date(.data[[install_col]]),
           failure_type = .data[[issue_col]],
           panel_id = .data[[id_col]])
  
  # Join failure type with cost table
  missing_issues <- setdiff(unique(data$failure_type), unique(issue_costs$issue))
  # if (length(missing_issues) > 0) {
  #   msg <- paste("No unit_cost for:", paste(missing_issues, collapse = ", "))
  #   if (isTRUE(strict)) stop(msg) else message(msg, " — treating as $0.")
  # }

  df_costed <- data %>%
    left_join(issue_costs, by = c("failure_type" = "issue")) %>%
    mutate(unit_cost = ifelse(is.na(unit_cost), 0, unit_cost))
  
  # Maintenance visits from install date until "now"
  df_costed <- df_costed %>%
    mutate(years_in_service = as.numeric(difftime(as_of, install_date, units = "days")) / 365.25,
           visits = floor(years_in_service / schedule_years),
           maintenance_cost = visits * routine_cost_per_visit,
           total_cost = unit_cost + maintenance_cost)
  
  # Output per panel + total
  per_panel <- df_costed %>%
    select(panel_id, failure_type, install_date, visits,
           maintenance_cost, unit_cost, total_cost)
  
  totals <- list(
    total_failure_cost = sum(per_panel$unit_cost, na.rm = TRUE),
    total_maintenance_cost = sum(per_panel$maintenance_cost, na.rm = TRUE),
    total_cost = sum(per_panel$total_cost, na.rm = TRUE)
  )
  
  list(per_panel = per_panel, totals = totals)
}
