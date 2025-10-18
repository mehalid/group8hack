#' @name Bargraph
#' @title Bargraph
#' @description Generate a bar graph of the different failure types
#' @author Group 8
#' @params input (numeric) vector of 1 or more numeric values.
#' @note Adding `@export` below means this function will become accessible by package users, rather than being an internal-only function.
#' @export


#Functions that outputs a bar plot showing the tendencies of each failure type
#Outputs: the plot and the top failure type (string)

Bargraph <- function(input) { 
  # Load required packages
  library(dplyr)
  library(ggplot2)
  
  # --- Warm earthy palette (burlywood, orange, chocolate) ---
  warm_palette <- c(
    "#DEB887",  # burlywood
    "#D2691E",  # chocolate
    "#FF8C00",  # dark orange
    "#E9967A",  # salmon-ish accent
    "#8B4513"   # saddle brown
  )
  
  # --- Summarize number of failures by type ---
  failure_summary <- input %>%
    filter(!is.na(failure_type)) %>%
    group_by(failure_type) %>%
    summarize(Number_of_Failures = n()) %>%
    arrange(desc(Number_of_Failures))
  
  print(failure_summary)  # optional view
  
  top_failure_type <- failure_summary$failure_type[1]
  
  # --- Create bar chart ---
  gbar <- ggplot(failure_summary,
                 aes(x = reorder(failure_type, -Number_of_Failures),
                     y = Number_of_Failures,
                     fill = failure_type)) +
    geom_bar(stat = "identity", width = 0.7, color = "white", linewidth = 0.4) +
    geom_text(aes(label = Number_of_Failures), vjust = -0.4, size = 4) +
    scale_fill_manual(values = warm_palette) +
    labs(
      title = "Number of Solar Panels Failed by Failure Type",
      x = "Failure Type",
      y = "Number of Failures"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 12, face = "italic", hjust = 0.5, color = "#5C4033"),
      axis.text.x = element_text(angle = 20, hjust = 1, color = "#5C4033"),
      axis.title = element_text(color = "#5C4033"),
      panel.grid.major.y = element_line(color = "burlywood3"),
      panel.grid.minor.y = element_blank()
    )
  
  return(list(plot = gbar, top_failure_type = top_failure_type))
}

# bar = Bargraph(farm_bad)
# bar$plot
# bar$top_failure_type
