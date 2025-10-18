# Step 0:
# Run codebook creation function to view codebook for subsequency data creation
source("R/create_codebook.R")
codebook_list = create_codebook()

#Step 1: Load Datasheet - for our case we run a function to create the dataset
#Run make_datsheet.R to load the dataset

#Step 2: Upload functions: SPC.R, Bargraph.R, pdf_function.R

source("R/make_datasheet.R")

# ---- Generate the two farms ----
farm_normal <- generate_farm_data(
  farm_id = "NY001",
  mean_life = 28, sd_life = 3,
  fail_type_probs = c(0.3, 0.2, 0.3, 0.2),  # balanced causes
  maint_delay_mean = 365                     # ~1 year maintenance
)

farm_bad <- generate_farm_data(
  farm_id = "NY002",
  mean_life = 20, sd_life = 4,
  fail_type_probs = c(0.1, 0.7, 0.1, 0.1),  # mostly Wiring
  maint_delay_mean = 800                     # infrequent maintenance
)

# ---- Telemetry for each farm ----
telemetry_normal <- generate_farm_telemetry(
  farm_df = farm_normal,
  farm_id = "NY001",
  deg_rate = 0.005,                 # 0.5%/yr degradation
  irr_factor_range = c(200, 1000),
  noise_range = c(0.9, 1.0)
)

telemetry_bad <- generate_farm_telemetry(
  farm_df = farm_bad,
  farm_id = "NY002",
  deg_rate = 0.015,                 # 1.5%/yr degradation
  irr_factor_range = c(200, 1000),
  noise_range = c(0.85, 1.0)
)

# ---- Save datasets ----
write.csv(farm_normal, "panel_life_NY001.csv", row.names = FALSE)
write.csv(farm_bad, "panel_life_NY002.csv", row.names = FALSE)
write.csv(telemetry_normal, "panel_telemetry_NY001.csv", row.names = FALSE)
write.csv(telemetry_bad, "panel_telemetry_NY002.csv", row.names = FALSE)

cat("Saved panel_life_NY001.csv, panel_life_NY002.csv, panel_telemetry_NY001.csv, and panel_telemetry_NY002.csv\n")

source("R/SPC.R")
var = StatisticalProcessTest(telemetry_normal$actual_output_kW[1:1000],telemetry_normal$expected_output_kW[1:1000],telemetry_normal$timestep[1:1000])
var$plot
#var$slope

source("R/Bargraph.R")
bar = Bargraph(farm_bad)

source("R/statistics.R")
stats <- panel_stats("panel_life_NY001.csv",
                     install_col = "install_date",
                     failure_col = "failure_date",
                     horizons = c(365, 730, 1825))  # 1, 2, and 5 years


source("R/pdf_function.R")
source("R/generate_report.R")
generate_solar_report(stats, bar$plot, var$plot)
# source("R/pdf_function.R")
# 
# 
# write_single_page_report(stats, var$plot, bar,
#                          out_pdf = "SolarPanel_ReliabilityReport.pdf",
#                          warranty_years = 25)















#Step 3: Control Plot Function: Call StatisticalProcessTest Function w/ efficiency values from dataset-----
#Open SPC.R for more info

#Step 4: Bar Graph: will give you a bar plot with the occurrences of each failure mode----
#Open Bargraph.R for more info

#Step 5: Open and Run statistics.R

#Step 6: Pdf function:-------
#  stats: list outputted from statistics.R
# var$plot: the control plot outputted from SPC.R
# bar$plot: the bar plot outputted from Bargraph.R
# out_pdf: is the name of the pdf you want to save

