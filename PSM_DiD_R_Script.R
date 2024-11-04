
# Install and load necessary packages (run these if not already installed)
install.packages(c("MatchIt", "dplyr", "lfe", "stargazer"))
library(MatchIt)
library(dplyr)
library(lfe)     # For fixed effects models
library(stargazer) # For formatted output

# Step 1: Load and Prepare the Data
# Load the dataset (ensure the file path points to your data file)
data <- read.csv("your_data_file.csv")

# Inspect the data to ensure it loaded correctly
str(data)
summary(data)

# Step 2: Define the Pre- and Post-Intervention Period
data <- data %>%
  mutate(Post = ifelse(Year >= 2016, 1, 0))  # Define post-treatment period

# Step 3: Propensity Score Matching (PSM)
# Set the treatment variable as Green_Finance_Recipient, with covariates based on study design
psm_model <- matchit(Green_Finance_Recipient ~ GDP_Growth_Rate + Energy_Consumption + Sectoral_Output,
                     data = data, method = "nearest", caliper = 0.1)

# Check matching results
summary(psm_model)

# Extract matched dataset
matched_data <- match.data(psm_model)

# Step 4: Balance Check
# Perform balance check after matching to confirm covariate similarity
balance_summary <- summary(psm_model)$sum.matched
print(balance_summary)

# Step 5: Difference-in-Differences (DiD) Estimation
# Run DiD regression on matched data, with fixed effects for Firm_ID and Year
did_model <- felm(Emissions ~ Green_Finance_Recipient * Post + GDP_Growth_Rate + Energy_Consumption + Sectoral_Output |
                  Firm_ID + Year, data = matched_data)

# Output the results of the DiD model
summary(did_model)

# Optional: Save results in a formatted table
stargazer(did_model, type = "text", title = "Difference-in-Differences Estimation Results")

# Step 6: Interpretation of Results
# Obtain the estimated ATT for Green Finance on Emissions Reduction
ATT <- coef(did_model)["Green_Finance_Recipient:Post"]
cat("Estimated ATT for Green Finance on Emissions Reduction:", ATT, "\n")

# Step 7: Save the matched data and results if needed
write.csv(matched_data, "matched_data_output.csv")
