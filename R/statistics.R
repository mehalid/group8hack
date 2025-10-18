# statistics.R
#install.packages(c("readr", "hms"), dependencies = TRUE)

library(dplyr)  
library(readr)  
library(ggplot2)
library(ggpubr)  
library(moments) 

# ---- Helper: robust date parsing without extra packages ----
.parse_date_vec <- function(x) {
  if (inherits(x, "Date")) return(x)
  d <- suppressWarnings(as.Date(x))                           # ISO, e.g., 2000-02-18
  if (all(is.na(d))) d <- suppressWarnings(as.Date(x, "%m/%d/%Y"))
  if (all(is.na(d))) d <- suppressWarnings(as.Date(x, "%d/%m/%Y"))
  if (all(is.na(d)) && is.numeric(x)) d <- as.Date(x, origin = "1899-12-30") # Excel serials
  d
}

# ---- Core: compute MTTF, failure rate (λ), and exponential survival S(t) ----
# Uses ONLY rows with known failure_date (no censoring math).
panel_stats <- function(csv_path,
                        install_col = "install_date",
                        failure_col = "failure_date",
                        horizons    = c(365, 730, 1825)) {
  
  dat_raw <- readr::read_csv(csv_path, show_col_types = FALSE)

  
  dat <- dat_raw %>%
    mutate(
      .install = .parse_date_vec(.data[[install_col]]),
      .failure = .parse_date_vec(.data[[failure_col]])
    ) %>%
    filter(!is.na(.install)) %>%                                # need install date
    filter(is.na(.failure) | .failure >= .install)              # keep valid rows
  
  n_total  <- nrow(dat)
  n_failed <- sum(!is.na(dat$.failure))
  
  # Time-to-failure for *failed* rows only
  ttf_days <- dat %>%
    filter(!is.na(.failure)) %>%
    transmute(ttf = as.numeric(.failure - .install)) %>%
    pull(ttf)
  
  # if (length(ttf_days) == 0) {
  #   return(list(
  #     n_total = n_total,
  #     n_failed = 0,
  #     mttf_days = NA_real_,
  #     failure_rate_per_day = NA_real_,
  #     failure_rate_per_year = NA_real_,
  #     survival_fn = function(t_days) rep(NA_real_, length(t_days)),
  #     survival_at = data.frame(time_days = horizons, survival = NA_real_)
  #   ))
  # }
  
  mttf_days <- mean(ttf_days, na.rm = TRUE)
  lambda    <- 1 / mttf_days
  
  survival_fn <- function(t_days) {
    #if (is.na(lambda)) return(rep(NA_real_, length(t_days)))
    exp(-lambda * t_days)
  }
  
  survival_at <- data.frame(
    time_days = horizons,
    survival  = survival_fn(horizons)
  )
  
  list(
    n_total = n_total,
    n_failed = n_failed,
    mttf_days = mttf_days,
    failure_rate_per_day = lambda,
    failure_rate_per_year = if (is.na(lambda)) NA_real_ else lambda * 365,
    survival_fn = survival_fn,
    survival_at = survival_at
  )
}

# ---- Optional quick plot of exponential survival curve S(t) ----
# plot_exponential_survival <- function(stats, max_days = 3650) {
#   t <- seq(0, max_days, by = 30)
#   df <- data.frame(time_days = t, survival = stats$survival_fn(t))
#   ggplot(df, aes(time_days, survival)) +
#     geom_line(size = 1) +
#     labs(title = "Exponential Survival Curve (S(t) = e^{-λ t})",
#          subtitle = sprintf("λ = %.6f per day | MTTF = %.1f days",
#                             stats$failure_rate_per_day, stats$mttf_days),
#          x = "Time (days)", y = "Survival probability") +
#     theme_minimal(base_size = 12)
# }



# stats <- panel_stats("panel_life_NY001.csv",
#                      install_col = "install_date",
#                      failure_col = "failure_date",
#                      horizons = c(365, 730, 1825))  # 1, 2, and 5 years


# lambda <- stats$failure_rate_per_year  
# mttf   <- stats$mttf_days/365  #per year
# 
# 
# t_max <- qexp(0.90, rate = lambda)                # ~90th percentile lifetime
# curve_df <- tibble::tibble(
#   t_years = seq(0, t_max, length.out = 100)
# ) %>%
#   mutate(
#     pdf  = dexp(t_years, rate = lambda),            # f(t)
#     cdf  = pexp(t_years, rate = lambda),            # F(t)
#     surv = exp(-lambda * t_years),                  # S(t)
#     haz  = lambda                                  # h(t) (constant for exponential)
#   )

# # --- plots (all purely theoretical) ---
# p_pdf <- ggplot(curve_df, aes(t_years, pdf)) +
#   geom_line(linewidth = 1) +
#   geom_area(fill = "burlywood")+
#   labs(title = "Probability Density Function", subtitle = sprintf("λ = %.6f /year", lambda),
#        x = "Time (years)", y = "Density") +
#   theme_minimal(base_size = 12)
# 
# p_cdf <- ggplot(curve_df, aes(t_years, cdf)) +
#   geom_line(linewidth = 1) +
#   geom_area(fill = "brown")+
#   labs(title = "Cumulative Distribution Function", x = "Time (years)", y = "Cumulative Probability") +
#   theme_minimal(base_size = 12)
# 
# p_surv <- ggplot(curve_df, aes(t_years, surv)) +
#   geom_line(linewidth = 1) +
#   geom_area(fill = "chocolate")+
#   labs(title = "Survival Function", x = "Time (years)", y = "Survival Probability") +
#   theme_minimal(base_size = 12)
# 
# # arrange
# ggpubr::ggarrange(p_pdf, p_cdf, p_surv, ncol = 3, labels = c("A","B","C"))

