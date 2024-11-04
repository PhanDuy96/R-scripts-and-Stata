
* Load the dataset
import delimited "your_data_file.csv", clear

* Step 1: Create Treatment and Post Variables
gen Post = Year >= 2016  // Define post-treatment period

* Step 2: Propensity Score Matching (PSM)
* Estimate propensity scores using logistic regression
logit Green_Finance_Recipient GDP_Growth_Rate Energy_Consumption Sectoral_Output

* Perform nearest-neighbor matching
psmatch2 Green_Finance_Recipient (Emissions) GDP_Growth_Rate Energy_Consumption Sectoral_Output, neighbor(1)

* Step 3: Difference-in-Differences (DiD) Estimation
* Run DiD regression on matched data
xtreg Emissions i.Green_Finance_Recipient##i.Post GDP_Growth_Rate Energy_Consumption Sectoral_Output, fe robust

* Get the ATT from the interaction term
lincom _b[1.Green_Finance_Recipient#1.Post]

* Save matched data if needed
save "matched_data_output.dta", replace
