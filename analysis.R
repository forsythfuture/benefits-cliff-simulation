################################################################################################################################

# This script provides updated numbers for ABC's benefits cliff simulation game

# Old graphics/numbers stored here: https://drive.google.com/drive/folders/17yD2H_Z9JxoSjIB7bKf8YIaWEAolHPJm

library(tidyverse)

################################################################################################################################

# Expenses per household composition

# Expenses come from Table 3 in https://docs.google.com/document/d/1TyAYSnN3UtUNxXzA91JVEvreffdeBelx/edit#heading=h.etvewqv6kj6b

# livable wages' family type expenses dataset that uses 2019 expenses adjusted to 2021 dollars
expenses <- readr::read_csv('~/benefits-cliff-simulation/csvs/itemized_expenses_family_type.csv') %>% 
  # remove taxes and the total expenses columns - we will calculate taxes and sum all expenses together later
  select(-`Total Expenses`, -`Taxes`) %>% 
  # filter for needed family types
  filter(`Family Type` %in% c('Two working adults with a 2- and 4-year-old', 'One adult with a 2-and 4-year-old', 'One adult')) %>% 
  slice(1, rep(2, 2), 3) %>% 
  # add in family number identification
  # can be found in Tent Cards.pdf or Income Expenses.pdf at https://drive.google.com/drive/folders/17yD2H_Z9JxoSjIB7bKf8YIaWEAolHPJm
  mutate(`Family Number` = c(4, 1, 2, 3), .before = `Family Type`) %>% 
  # make yearly estimates monthly
  mutate(across(3:length(.), ~ ./ 12)) %>% 
  # repeat the four family types 3 times since they go through three rounds
  slice(rep(1:4, times = 3)) %>%
  # add in a round column identification
  mutate(Round = rep(1:3, each = 4), .before = `Family Number`) %>% 
  arrange(`Family Number`) %>% 
  # REVIEW Updated the Health Insurance column so I can subtract Medicaid and ACA subsidy amounts from the raw health insurance costs later
  # the current Health insurance column includes traditional fee-for-service health plans, preferred-provider health plans, health maintenance 
  # organizations (HMO's), commercial Medicare supplements, and other health insurance
    # We don't want this, we need to know how much a health insurance costs before any supplements, subsidies, etc.
  # to find the monthly cost of a silver plan in Forsyth County in 2022 without financial help go to: https://www.kff.org/interactive/subsidy-calculator/
    # 1. Select a State: Select "North Carolina" and input a Forsyth County zip code, e.g., 27104
    # 2. Enter yearly household income as: Doesn't matter enter any amount, e.g, 50000
    # 3. Is coverage available from your or your spouse’s job?: No
    # 4. Number of people in family? Sum number of adults plus children
    # 5. Number of adults (21 to 64) enrolling in Marketplace coverage: All adults assumed to be 40 y/o, non-smokers
    # 6. Number of children (20 and younger) enrolling in Marketplace coverage: One child is 2, one child is 4 both non-smokers
    # Scroll down to the Results section, find the number to the right of "Without financial help, your silver plan would cost:"
  mutate(`Health Insurance` = c(rep(1420, 6), rep(976, 3), rep(444, 3)))

# View(expenses)

################################################################################################################################

# Benefits per household composition

# read in master benefits spreadsheet from https://github.com/forsythfuture/benefits-cliff/tree/master/Forsyth_County_2022/plots/data
benefits <- readr::read_csv('~/benefits-cliff-simulation/csvs/benefits.csv') %>% 
  # align the types of benefits with the expenses dataset's categories above
  mutate(category = case_when(
    benefit == "FNS (Food Stamps)" | benefit == "WIC" ~ "Food",
    benefit == "Housing Choice Voucher" ~ "Housing",
    benefit == "NC Child Care Subsidy / Smart Start" ~ "Child Care",
    benefit == "NC Medicaid / Health Choice" ~ "Health Insurance",
    benefit == "Work First (TANF)" ~ "Other Expenses"),
  # align family compositions with the expenses dataset above
  `Family Type` = case_when(
    composition == "1 adult" ~ "One adult",
    composition == "1 adult, 2 children" ~ "One adult with a 2-and 4-year-old",
    composition == "2 adults, 2 children" ~ "Two working adults with a 2- and 4-year-old"
    )
  )

# function that will find what benefits are available at a particular household monthly
# income and composition
benefit_simuluation <- function(household_composition, household_monthly_income, family_number, round_number){
  
  benefits %>% 
    filter(composition == household_composition,
           monthly_income == household_monthly_income) %>% 
    mutate(`Family Number` = family_number,
           Round = round_number)
  
}

# ---------------------------------

# Household monthly incomes and corresponding wages for the different household compositions
# Amounts were chosen by Daniel to demonstrate the benefits cliff effect
# https://benefits-cliff-forsyth.s3.amazonaws.com/benefits_cliff_hc.html

# Single
# 7.25, 10.50, 14.00 - Wage
# 1255.7, 1818.6, 2424.8 - Monthly

# Single, two children
# 16.50, 21.50, 23.50 - Wage
# 2857.8, 3723.8, 4070.2 - Monthly

# Two parents, two children
# 20.50, 25.50, 28.50 - Wage
# 3550.6, 4416.6, 4936.2 - Monthly

# Two parents, two children
# 33.50, 35.50, 40.50 - Wage
# 5802.2, 6148.6, 7014.6 - Monthly

# ---------------------------------

# household compositions, household pre-tax income, family number, and round number vectors

households <- c(rep('2 adults, 2 children', 6), rep('1 adult, 2 children', 3), rep('1 adult', 3))
# the third element in the pre_tax_income is 7000 not 7014.6 because the benefits' dataset only goes up to 7000
  # Do we know how that impacts the numbers? 
    # No impact, they are not eligible for any programs at any household size
pre_tax_income <- c(5802, 6149, 7000, 3551, 4417, 4936, 2858, 3724, 4070, 1256, 1819, 2425)
family <- rep(1:4, each = 3)
round <- rep(1:3, times = 4)

# REVIEW EL to review write-up
# ACA Subsidies
# to find the "Estimated financial help" or ACA subsidy value a household could receive towards a silver plan in Forsyth County 
# in 2022 go to: https://www.kff.org/interactive/subsidy-calculator/
  # 1. Select a State: Select "North Carolina" and input a Forsyth County zip code, e.g., 27104
yearly_incomes <- c(5802.2, 6148.6, 7014.6, 3550.6, 4416.6, 4936.2, 2857.8, 3723.8, 4070.2, 1255.7, 1818.6, 2424.8) * 12
  # 2. Enter yearly household income as: Entire a household's pre-tax yearly income, e.g, 7014.6 * 12 for the last 
  # two parents, two children scenario  
  # 3. Is coverage available from your or your spouse’s job?: No
  # 4. Number of people in family? Sum number of adults plus children
    # Make sure the number of people in family includes children even when not including children in the calculation
  # 5. Number of adults (21 to 64) enrolling in Marketplace coverage: All adults assumed to be 40 y/o, non-smokers
  # 6. Number of children (20 and younger) enrolling in Marketplace coverage: One child is 2, one child is 4 both non-smokers
  # Scroll down to the Results section, find the number to the right of "Estimate financial help:"

# REVIEW EL to review the values below
# rows 4, 5, 7, and 8 of the outcomes data frame below display child Medicaid (MIC) eligibility. In those cases, ACA
# subsidies were calculated only for the adult/s in the household as a child or adult cannot both be
# enrolled in Medicaid and receive ACA subsidies. If there was not child Medicaid eligibility, the whole family was
# included when calculating ACA subsidies
aca_subsidies <- c(1158, 1104, 968, 873, 800, 1275, 437, 364, 858, 444, 430, 370)

# calculate benefit amounts received by category for each round and family type
outcomes <- pmap(list(households, pre_tax_income, family, round), 
                 ~ benefit_simuluation(..1, ..2, ..3, ..4) %>% 
                   select(-adults, -children, -monthly_income, -composition) %>% 
                   # make the category column wide to match the expenses dataset format
                   pivot_wider(names_from = "category", values_from = "payment") %>% 
                   group_by(Round, `Family Number`, `Family Type`) %>%
                   # sum the benefit amounts by category into one number per category
                   summarise(across(Food:`Other Expenses`, ~ sum(.x, na.rm = T))) %>%
                   ungroup()
                 ) %>% 
  # reduce lists into one data frame
  reduce(bind_rows) %>% 
  # add in blank zero columns for row bind later
  mutate(`Health Care` = 0,
         Savings = 0,
         Transportation = 0) %>% 
  # add in aca subsidies from the vector above
  add_column(`ACA Subsidies` = aca_subsidies) %>% 
  # REVIEW EL to review write-up
  # Medicaid Eligibility thresholds can be found: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://files.nc.gov/ncdma/documents/files/Basic-Medicaid-Eligibility-Chart-2020.pdf
  # add Medicaid/MIC (only children receive Medicaid benefits through MIC) to the ACA subsidies (adults only or the entire family depending
  # on MIC eligibility as stated above)
    # Based on the household's pre-tax monthly income, the household composition and the Medicaid output in the benefits master dataset,
    # the Health Insurance (Medicaid/MIC) value only applies to children. Why? Based on the household incomes and the ages of the children
    # (2 and 4), children would only be eligible for MIC, which only provides full coverage for children, parents and caretakers
    # do not receive anything. Therefore, we calculate the ACA subsidies for adults only when children are eligible for MIC or
    # ACA subsidies for the entire family when children are not eligible for MIC in an attempt to get a total estimate of the Health Insurance 
    # benefit a household could receive
  mutate(`Health Insurance` = `Health Insurance` + `ACA Subsidies`) %>% 
  select(-`ACA Subsidies`)

# View(outcomes)

################################################################################################################################

# Taxes per household composition

# Shane's tax package (usincometaxes): https://www.shaneorr.io/r/usincometaxes/

# create a data frame of needed inputs to run through TAXSIM 35
# order matches that of the outcomes dataset above
family_income <- data.frame(
  taxsimid = seq(1, 12), # identifier
  state = rep('North Carolina', 12),
  # using 2019 since 2020/2021 taxes have out of the ordinary caveats
  year = rep(2019, 12),
  mstat = c(rep('married, jointly', 6), rep('single', 6)), # filing status of tax unit
  pwages = pre_tax_income * 12, # primary wages
  # livable wage iterates over 40 year olds and 2 and 4 year olds
  page = rep(40, 12), # primary taxpayer age
  sage = c(rep(40, 6), rep(0, 6)), # spouse age
  depx = c(rep(2, 9), rep(0, 3)), # number of dependents
  age1 = c(rep(2, 9), rep(0, 3)), # age child 1
  age2 = c(rep(4, 9), rep(0, 3)), # age child 2
  # values taken from expenses dataset
  rentpaid = c(rep(772.5833, 9), rep(617.8333, 3)), # rent cost
  childcare = c(rep(1646.5, 9), rep(0, 3)) # child care cost
)

# calculate taxes
family_taxes <- usincometaxes::taxsim_calculate_taxes(
  .data = family_income,
  marginal_tax_rates = 'Wages',
  # Are refundable tax credits, like EITC, already included in the fiitax, siitax, or tfica?
    # Yes, Federal income tax liability (fiitax) includes capital gains rates, surtaxes, NIIT, 
    # AMT and refundable and non-refundable credits etc, but not including self-employment, 
    # additional Medicare Tax or FICA taxes. The adjustment for SE FICA is made.
  return_all_information = TRUE) %>% 
  select(taxsimid, fiitax, siitax, tfica)

# View(family_taxes)

after_tax_income <- family_taxes %>% 
  # add round and family number columns to make sure everything lines up
  mutate(`Family Number` = rep(1:4, each = 3), .before = taxsimid) %>%
  mutate(Round = rep(1:3, times = 4), .before = `Family Number`) %>% 
  rowwise() %>% 
  # sum all tax liabilities together
    # from Shane: Total income tax liabilities would be fiitax + siitax + tifica
  mutate(tax_liabilities = sum(fiitax, siitax, tfica), .after = `Family Number`) %>% 
  # If a tax filing unit has a negative tax liability (federal income tax liability + state 
  # income tax liability + taxpayer liability for FICA), does the tax filing unit receive a refund?
    # Yes, there are several refundable credits, including Earned Income Credit and Additional Child Tax Credit.
  ungroup() %>% 
  # make tax liabilities and eitc monthly
  mutate(across(tax_liabilities:length(.), ~ . / 12)) %>% 
  # add the pre-tax income column in from above
  add_column(pwages = pre_tax_income) %>% 
  # find the after-tax income, i.e., pre-tax income minus tax liabilities
  mutate(`After-Tax Income` = pwages - tax_liabilities) %>% 
  # arrange by Round so we can add the after-tax income column in below
  arrange(Round) %>% 
  pull(`After-Tax Income`)
  
################################################################################################################################

# Expenses - Benefits = Total Expenses; After-Tax Income - Total Expenses = Balance

# row bind the expenses and outcomes datasets
dat <- bind_rows(outcomes, expenses) %>% 
  # group by the round, family number and family type to make sure rows add up properly
  group_by(Round, `Family Number`, `Family Type`) %>% 
  # take the difference between expenses and benefit outcomes by category
  summarise(across(Food:Transportation, ~ diff(.x))) %>% 
  select(Round, `Family Number`, `Family Type`, `Child Care`, Housing, Food, `Health Care`,
         `Health Insurance`, Savings, Transportation, `Other Expenses`) %>% 
  rowwise() %>% 
  # calculate total expenses across all categories
  mutate(`Total Expenses` = sum(c_across(`Child Care`:`Other Expenses`))) %>% 
  ungroup() %>% 
  # add the after-tax income column in from above
  add_column(`After-Tax Income` = after_tax_income) %>% 
  # find the monthly balance, i.e, income minus expenses
  mutate(Balance = `After-Tax Income` - `Total Expenses`) %>% 
  arrange(`Family Number`)

View(dat)

# readr::write_csv(dat, '~/benefits-cliff-simulation/csvs/benefit-simulation.csv')
