#' @name generate_solar_report
#' @title generate_solar_report
#' @description Function to generate a website with our graphs and data analysis
#' @author group8
#' @params stats, bar_plot, var_plot, output_file
#' @note Adding `@export` below means this function will become accessible by package users, rather than being an internal-only function.
#' @export


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
