

source("R/cost_function2.R")

#USER INPUTS
#Data
data_set="panel_life_NY001.csv"

#Cost to fix a wiring issue
wiring_cost=180+600
#Cost to fix a crack issue
crack_cost=350+600
#Cost to fix a wear issue
wear_cost=120+600
#Cost to fix a Delamination issue
Delamination_cost=420+600

#cost for a routine maintence
routine_maintence_cost=300

#years for maintence check 
schedule=2


issue_costs <- tibble::tibble(
  issue = c("Wiring", "Crack", "Wear", "Delamination"),
  unit_cost = c(wiring_cost, crack_cost, wear_cost, Delamination_cost)
)

# Example: annual maintenance ($800 per year)
# out <- compute_panel_costs(
#   data = data_set,
#   issue_costs = issue_costs,
#   issue_col = "failure_type",
#   id_col = "panel_id",
#   install_col = "install_date",
#   routine_cost_per_visit = routine_maintence_cost,
#   schedule_years = schedule,   # change to 2 for bad farm
#   as_of = Sys.Date()
# )

# Compute costs
out <- compute_panel_costs2(
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
# View the panel-level breakdown
head(out$per_panel)

# View totals
out$totals





