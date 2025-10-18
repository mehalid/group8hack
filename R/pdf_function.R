library(dplyr)
library(ggplot2)
library(ggpubr)

stats <- panel_stats("panel_life_NY001.csv",
                     install_col = "install_date",
                     failure_col = "failure_date",
                     horizons = c(365, 730, 1825))  # 1, 2, and 5 years

# --- life plots from your stats (YEARS) ---
build_life_plots <- function(stats, warranty_years = 25) {
  mttf_years <- stats$mttf_days / 365
  lambda_yr  <- stats$failure_rate_per_year
  
  t_max <- qexp(0.90, rate = lambda)                # ~90th percentile lifetime
  curve_df <- tibble::tibble(
    t_years = seq(0, t_max, length.out = 100)
  ) %>%
    mutate(
      pdf  = dexp(t_years, rate = lambda),            # f(t)
      cdf  = pexp(t_years, rate = lambda),            # F(t)
      surv = exp(-lambda * t_years),                  # S(t)
      haz  = lambda                                  # h(t) (constant for exponential)
    )
  
  # --- plots (all purely theoretical) ---
  p_pdf <- ggplot(curve_df, aes(t_years, pdf)) +
    geom_line(linewidth = 1) +
    geom_area(fill = "burlywood")+
    labs(title = "PDF",
         x = "Time (years)", y = "Density") +
    theme_minimal(base_size = 12,) +
    theme(
      plot.title = element_text(size=12, face = "italic", hjust=0.5 ), plot.subtitle = element_text(size=10))
  
  p_cdf <- ggplot(curve_df, aes(t_years, cdf)) +
    geom_line(linewidth = 1) +
    geom_area(fill = "brown")+
    labs(title = "CDF", x = "Time (years)", y = "Cumulative Probability") +
    theme_minimal(base_size = 12)+
    theme(
      plot.title = element_text(size=12, face = "italic", hjust=0.5 ))
  
  p_surv <- ggplot(curve_df, aes(t_years, surv)) +
    geom_line(linewidth = 1) +
    geom_area(fill = "chocolate")+
    labs(title = "Survival Function", x = "Time (years)", y = "Survival Probability") +
    theme_minimal(base_size = 12)+
    theme(
      plot.title = element_text(size=12, face = "italic", hjust=0.5 ))
  
  list(pdf = p_pdf, cdf = p_cdf, surv = p_surv)
  
}

# --- summary table block as a ggplot object ---
build_summary_table_plot <- function(stats) {
  mttf_years <- stats$mttf_days / 365
  lambda_yr  <- stats$failure_rate_per_year
  n_total    <- if (!is.null(stats$n_total))  stats$n_total  else NA_integer_
  n_failed   <- if (!is.null(stats$n_failed)) stats$n_failed else NA_integer_
  
  surv10 <- exp(-lambda_yr * 10)
  surv20 <- exp(-lambda_yr * 20)
  surv25 <- exp(-lambda_yr * 25)
  
  tbl <- data.frame(
    Metric = c("Total panels", "Failed panels",
               "MTTF (years)", "Failure rate (/yr)",
               "Survival @10y", "Survival @20y", "Survival @25y"),
    Value  = c(n_total, n_failed,
               sprintf("%.1f", mttf_years),
               sprintf("%.4f", lambda_yr),
               sprintf("%.1f%%", 100 * surv10),
               sprintf("%.1f%%", 100 * surv20),
               sprintf("%.1f%%", 100 * surv25)),
    stringsAsFactors = FALSE
  )
  
  ggpubr::ggtexttable(tbl, rows = NULL, theme = ttheme("mRed"))
}

# --- narrative paragraph block as a ggplot object ---
build_narrative_plot <- function(stats, var, bar) {
  mttf_years <- stats$mttf_days / 365
  lambda_yr  <- stats$failure_rate_per_year
  n_total    <- if (!is.null(stats$n_total))  stats$n_total  else NA_integer_
  n_failed   <- if (!is.null(stats$n_failed)) stats$n_failed else NA_integer_
  surv10 <- 100 * exp(-lambda_yr * 10)
  surv25 <- 100 * exp(-lambda_yr * 25)

  
  # --- Add slope message if slope data provided ---
  slope_msg <- ""
  if (!is.null(var) && "slope" %in% names(var)) {
    if (sign(var$slope) == -1) {
      slope_msg <- "The slope of the control chart indicates a decreasing trend, suggesting decreasing efficiency over time.\n"
    } else if (sign(var$slope) == 1) {
      slope_msg <- "The slope of the control chart indicates an increasing trend, suggesting improving efficiency over time.\n"
    } else {
      slope_msg <- "The slope of the control chart indicates a neutral trend with no significant change in efficiency.\n"
    }
  }
  
  bar_msg <- ""
  if (!is.null(bar) && "top_failure_type" %in% names(bar)) {
    if (bar$top_failure_type == "Wiring") {
      bar_msg <- "Most of your failures are due to wiring issues. Contact electricians.\n"
    } else if (bar$top_failure_type== "Crack") {
      bar_msg <- "Most of your failures are due to cracking issues. Replace part and contact panel supplier.\n"
    } else if (bar$top_failure_type == "Wear") {
      bar_msg <- "Most of your failures are due to wear issues. Contact a maintenance crew .\n"
    } else if (bar$top_failure_type == "Delamination") {
      bar_msg <- "Most of your failures are due to Delamination issues. Replace part and contact panel supplier.\n"
    }
  }
  

  
  
  text <- paste0(
    "\n\n We modeled reliability with an exponential lifetime.\n",
    "Estimated MTTF =", sprintf("%.1f", mttf_years), ".",
    "With ", n_total, " panels and ", n_failed, " observed failures, expected survival is ",
    sprintf("%.1f", surv10), "% at 10 years and ", sprintf("%.1f", surv25),
    "% at 25 years.",
    slope_msg,
    bar_msg
  )
  
  
  ggpubr::ggparagraph(text = text, face = "plain", size = 11)
}


# --- single-page report like your sketch ---
write_single_page_report <- function(stats, u_plot, bar,
                                     out_pdf = "Solar_Panel_Reliability_Report.pdf",
                                     warranty_years = 25) {
  life_plots <- build_life_plots(stats, warranty_years)
  tbl_plot   <- build_summary_table_plot(stats)
  para_plot  <- build_narrative_plot(stats, var, bar)
  
  # Top-left: PDF/CDF/R(t) in one row
  top_left <- ggpubr::ggarrange(life_plots$pdf, life_plots$cdf, life_plots$surv,
                                ncol = 3)
  
  # Left column: top row (three plots) over big control chart
  left_col <- ggpubr::ggarrange(top_left, u_plot,
                                ncol = 1, heights = c(.8, 0.8))
  
  # Right column: table over paragraph
  right_col <- ggpubr::ggarrange(
    para_plot,   # <-- your bar plot here
    tbl_plot,   # summary table below
    bar$plot,  # narrative paragraph below all
    ncol = 1,
    heights = c(0.8, 1, 1)  # adjust relative heights if needed
  )
  
  # --- combine left & right columns ---
  body <- ggpubr::ggarrange(
    left_col, right_col,
    ncol = 2, widths = c(1.9, 1.1)
  )
  
  # # --- add subtitles above each column ---
  # subtitles <- ggpubr::ggarrange(
  #   ggpubr::text_grob(" ", face = "bold", size = 15, family = "serif"),
  #   ggpubr::text_grob(" ", face = "bold", size = 15, family = "serif"),
  #   ncol = 2, widths = c(1.9, 1.1)
  # )
  
  # --- stack subtitles on top of the body ---
  page_content <- ggpubr::ggarrange(
    # subtitles,
    body,
    ncol = 1,
    heights = c(0.1, 1)
  )
  
  # --- add big main title at very top ---
  page <- ggpubr::annotate_figure(
    page_content,
    top = ggpubr::text_grob("Solar Panel Reliability Report", face = "bold", size = 20, family = "serif")
  )
  
  # --- write single-page PDF ---
  grDevices::pdf(out_pdf, width = 11, height = 8.5)
  print(page)
  grDevices::dev.off()
  message(sprintf("Saved: %s", normalizePath(out_pdf)))
  
}
