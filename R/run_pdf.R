# Assuming you already have:
#   stats  <- panel_stats("R/panel_life_NY001.csv", ...)
#   uout   <- make_failure_uchart(panel_life_NY001, ...)
#   u_plot <- uout$plot

# you already have: stats <- panel_stats(...), and u_plot from your u-chart function
write_single_page_report(stats, var$plot,
                         out_pdf = "SolarPanel_ReliabilityReport.pdf",
                         warranty_years = 25)
