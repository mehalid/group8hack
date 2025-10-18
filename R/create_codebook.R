create_codebook <- function() {
  codebook_telemetry <- data.frame(
    Variable = c("panel_id", "timestep", "expected_output_kW", "actual_output_kW"),
    Type = c("String", "YYYY-MM-DD", "Float", "Float"),
    Description = c("Unique panel identifier", "Date of reading", "Expected power output (kW)", 
                    "Actual/Measured power output (kW)")
  )
  
  codebook_farm <- data.frame(
    Variable = c("panel_id", "system_id", "install_date", "component_type", "failure_type", 
                 "last_maintenance_date", "failure_date", "event", "n_maintenances"),
    Type = c("String", "String", "YYYY-MM-DD", "String", "String", "YYYY-MM-DD",
             "YYYY-MM-DD", "Boolean", "Integer"),
    Description = c("Unique panel identifier", "Unique farm identifier",
                    "Installation date",
                    "Component tracked", "Mode of failure", 
                    "Date last maintenance was conducted", 
                    "Date of failure (Null if not applicable)", 
                    "T/F if failed/not failed",
                    "Number of times maintenance occurred")
  )
  
  return(list(codebook_farm, codebook_telemetry))
}
