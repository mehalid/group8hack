library(dplyr)
library(ggplot2)
library(ggpubr)

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
build_narrative_plot <- function(stats) {
  mttf_years <- stats$mttf_days / 365
  lambda_yr  <- stats$failure_rate_per_year
  n_total    <- if (!is.null(stats$n_total))  stats$n_total  else NA_integer_
  n_failed   <- if (!is.null(stats$n_failed)) stats$n_failed else NA_integer_
  surv10 <- 100 * exp(-lambda_yr * 10)
  surv25 <- 100 * exp(-lambda_yr * 25)
  
  text <- paste0(
    "We modeled reliability with an exponential lifetime.\n",
    "Estimated MTTF ≈ ", sprintf("%.1f", mttf_years), " years (λ ≈ ",
    sprintf("%.4f", lambda_yr), " per year).\n",
    "With ", n_total, " panels and ", n_failed, " observed failures, expected survival is ~",
    sprintf("%.1f", surv10), "% at 10 years and ~", sprintf("%.1f", surv25),
    "% at 25 years. Use this to align warranty and maintenance plans."
  )
  
  ggpubr::ggparagraph(text = text, face = "plain", size = 11)
}

# --- single-page report like your sketch ---
write_single_page_report <- function(stats, u_plot,
                                     out_pdf = "Solar_Panel_Reliability_Report.pdf",
                                     warranty_years = 25) {
  life_plots <- build_life_plots(stats, warranty_years)
  tbl_plot   <- build_summary_table_plot(stats)
  para_plot  <- build_narrative_plot(stats)
  
  # Top-left: PDF/CDF/R(t) in one row
  top_left <- ggpubr::ggarrange(life_plots$pdf, life_plots$cdf, life_plots$surv,
                                ncol = 3)
  
  # Left column: top row (three plots) over big control chart
  left_col <- ggpubr::ggarrange(top_left, u_plot,
                                ncol = 1, heights = c(.8, 0.8))
  
  # Right column: table over paragraph
  right_col <- ggpubr::ggarrange(tbl_plot, para_plot,
                                 ncol = 1, heights = c(1, 1))
  
  # --- combine left & right columns ---
  body <- ggpubr::ggarrange(
    left_col, right_col,
    ncol = 2, widths = c(1.9, 1.1)
  )
  
  # --- add subtitles above each column ---
  subtitles <- ggpubr::ggarrange(
    ggpubr::text_grob("Plots", face = "bold", size = 15, family = "serif"),
    ggpubr::text_grob("Summary", face = "bold", size = 15, family = "serif"),
    ncol = 2, widths = c(1.9, 1.1)
  )
  
  # --- stack subtitles on top of the body ---
  page_content <- ggpubr::ggarrange(
    subtitles,
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
