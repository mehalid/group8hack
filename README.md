<img src="pics/solar_panels.jpg" width="100%">

# 🎱 Team Ate - Six Sigma Hackathon
- 👥 **Group members:** Mehali Desai, Andrew Lin, Adhyan Prasad, Jennie Redrovan and Aleira Sanchez

# Our Tool 💡🔋
## Introduction
This repository provides a data analysis and visualization tool designed to address the following prompt:

<p style="margin-left: 20px;"><em>
Utility-scale solar power plants are found all throughout New York State, due to significant promotion policies over the last decade. Utility-scale solar can be made up of hundreds or even thousands of solar panels, each of which requires routine maintenance. Your team has been commissioned by the New York State Energy Research & Development Authority (NYSERDA), whose staff hope to better understand the lifespan remaining for existing utility-scale solar farms. Design a quality control system to track and mitigate solar panel failure.
</em></p>

This project builds a **quality control and reliability assessment framework for solar panels**, combining statistical process control, failure analysis, and lifespan modeling.

## Scope
As consulting analysts for the **New York State Energy Research & Development Authority (NYSERDA)**, our goal is to design and demonstrate a **data-driven quality control system** that can:
- Monitor the performance and degradation of solar panels over time.
- Identify common sources of failure.
- Estimate remaining useful life of panels.
- Support cost-based decision-making between repair and replacement.

## Core Objectives
The project focuses on the following key objectives:
1. **Generate Control Charts**: Track how solar panel efficiency changes over time using Statistical Process Control (SPC) methods.
2. **Identify Common Failure Modes**: Categorize and visualize the most frequent causes of solar panel failure.
3. **Analyze Lifespan Distributions**: Create and fit lifespan distribution charts (CDF, PDF, and Survival Probability) to assess panel survivability.
4. **Perform Cost Analysis**: Compare the cumulative costs of panel replacement versus repair to inform long-term maintenance strategy.
5. **Integrate All Outputs**: Compile all visualizations and analytical outputs into a final PDF report for NYSERDA stakeholders.

## Intended Users
- **NYSERDA staff members**: seeking insights into solar farm performance and lifespan prediction.
- **Consulting analyst teams**: responsible for developing and maintaining the quality control and reporting framework.

## Code Walkthrough
The following steps walk through the [`runMe.R`](./R/runMe.R) script, which is a tutorial that reproduces the analysis and generates the final report.
1.  **Generate the Dataset**: Upload your datasheet to the repository. Make sure to *use the same format as the codebook* to ensure proper usage of the tool. For the purposes of this hackathon, a sample dataset function has been provided to generate two test datasets. If this is the case, run the [`make_datasheet.R`](./R/make_datasheet.R) script to create and load the working datasets.
2.  **Generate Control Charts**: Run [`SPC.R`](./R/SPC.R) to create an average control chart that visualizes changes in panel efficiency over time. 
3.  **Visualize Failure Types**: Run [`BarGraph.R`](./R/BarGraph.R) to generate a bar graph showing the most common types and frequencies of panel failures.
4.  **Run Core Statistics Function**: Execute [`statistics.R`](./R/statistics.R) to compute summary statistics and generate key distribution plots (including the CDF, PDF, and survival probability curves).
5.  **Compile All Results into an HTML Report**: Use [`pdf_function.R`](./R/pdf_function.R) to aggregate all data and plots from the previous steps and arrange them into a structured HTML.
6.  **Export Final HTML Report**: Return to the [`runMe.R`](./R/runMe.R) script and run the last piece of code to generate and export the final HTML report containing all graphs, metrics, and analyses. Open up your report which can be found in the project folder.
