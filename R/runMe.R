#Step 1: Load Datasheet - for our case we run a function to create the dataset
#Run make_datsheet.R to load the dataset

#Step 2: Upload functions: SPC.R, Bargraph.R, pdf_function.R

#Step 3: Control Plot Function: Call StatisticalProcessTest Function w/ efficiency values from dataset-----
#Open SPC.R for more info
var = StatisticalProcessTest(telemetry_normal$actual_output_kW[1:1000],telemetry_normal$expected_output_kW[1:1000],telemetry_normal$timestep[1:1000])

#Step 4: Bar Graph: will give you a bar plot with the occurrences of each failure mode----
#Open Bargraph.R for more info
bar = Bargraph(farm_bad)

#Step 5: Open and Run statistics.R

#Step 6: Pdf function:-------
#  stats: list outputted from statistics.R
# var$plot: the control plot outputted from SPC.R
# bar$plot: the bar plot outputted from Bargraph.R
# out_pdf: is the name of the pdf you want to save
write_single_page_report(stats, var$plot, bar,
                         out_pdf = "SolarPanel_ReliabilityReport.pdf",
                         warranty_years = 25)
