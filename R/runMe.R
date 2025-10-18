# Step 0: 
# Run codebook creation function to view codebook for subsequency data creation
source("R/create_codebook.R")
codebook_list = create_codebook()


#Step 1: Load or simulate datasheet and provide numbers for maintanance costs
# If simulating, run make_datasheet.R to create the dataset and change the value
# of the commented field below
# If loading own dataset, edit the line below
data_set="panel_life_NY002.csv"

# Adjust the following to accurately reflect your cost per panel for routine
# maintanance as well as failure modes/cost per failure mode
#Cost to fix a wiring issue
wiring_cost=180+600
#Cost to fix a crack issue
crack_cost=350+600
#Cost to fix a wear issue
wear_cost=120+600
#Cost to fix a Delamination issue
Delamination_cost=420+600
#Cost for a routine maintence
routine_maintence_cost=300

issue_costs <- tibble::tibble(
  issue = c("Wiring", "Crack", "Wear", "Delamination"),
  unit_cost = c(wiring_cost, crack_cost, wear_cost, Delamination_cost)
)


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
var = StatisticalProcessTest(telemetry_bad$actual_output_kW[1:1000],telemetry_bad$expected_output_kW[1:1000],telemetry_bad$timestep[1:1000])
var$plot
#var$slope

source("R/Bargraph.R")
bar = Bargraph(farm_bad)

source("R/statistics.R")
stats <- panel_stats("panel_life_NY001.csv",
                     install_col = "install_date",
                     failure_col = "failure_date",
                     horizons = c(365, 730, 1825))  # 1, 2, and 5 years

# Step ___: Maintenance efforts v.s. total cost per panel
source("R/cost_function2.R")
# Compute costs
cost_output <- compute_panel_costs2(
  data = data_set,
  issue_costs = issue_costs,
  issue_col = "failure_type",
  id_col = "panel_id",
  install_col = "install_date",
  visits_col = "n_maintenances",        # or "num_of_visits" depending on dataset
  # routine_cost_per_visit = routine_maintenance_cost,
  routine_cost_per_visit = 300,
  as_of = Sys.Date()
)


source("R/pdf_function.R")
source("R/generate_report.R")
generate_solar_report(stats, bar$plot, var$plot)
















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

