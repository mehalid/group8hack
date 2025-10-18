generate_solar_report <- function(stats, bar_plot, var_plot, 
                                  output_file = "Solar_Report.html") {
  rmd_path <- normalizePath("R/report.Rmd", mustWork = TRUE)
  
  rmarkdown::render(
    input = rmd_path,
    params = list(
      stats = stats,
      bar_plot = bar_plot,
      var_plot = var_plot
    ),
    output_file = output_file,
    envir = new.env(parent = globalenv())
  )
  
  message("✅ HTML report saved at: ", normalizePath(output_file))
}
