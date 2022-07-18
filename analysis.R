################################################################################################################################

# This script provides updated numbers for ABC's benefits cliff simulation game

# Old graphics/numbers stored here: https://drive.google.com/drive/folders/17yD2H_Z9JxoSjIB7bKf8YIaWEAolHPJm

library(tidyverse)

################################################################################################################################

# Expenses per household composition

# Expenses come from Table 3 in https://docs.google.com/document/d/1TyAYSnN3UtUNxXzA91JVEvreffdeBelx/edit#heading=h.etvewqv6kj6b

# livable wages' family type expenses dataset
# TODO Check with CB that this is the most up-to-date spreadsheet for livable wage
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
  arrange(`Family Number`)

# View(expenses)

################################################################################################################################

# Benefits per household composition

# read in master benefits spreadsheet from https://github.com/forsythfuture/benefits-cliff/tree/master/Forsyth_County_2022/plots/data
benefits <- readr::read_csv('~/benefits-cliff-simulation/csvs/benefits.csv') %>% 
  # QUESTION Has this spreadsheet been checked or did it come from somewhere? 
    # NOTE View comment above, checked by Shane
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
# NOTE the third element in the pre_tax_income is 7000 not 7014.6 because the benefits' dataset only goes up to 7000
pre_tax_income <- c(5802, 6149, 7000, 3551, 4417, 4936, 2858, 3724, 4070, 1256, 1819, 2425)
# NOTE pre_tax_income[[4]] is 7014, not 7000 in the text above 
  # NOTE Please view comment above
family <- rep(1:4, each = 3)
round <- rep(1:3, times = 4)

# ACA Subsidies
# the value of the health benefit is the price of a silver plan on the ACA market, the "Estimated financial help" 
# silver plan prices for Forsyth County in 2022 were retrieved from: https://www.kff.org/interactive/subsidy-calculator/

# since children and adults qualify for different programs, calculate the value of their silver plans separately
# FIXME EL tested and running adults and kids separately gets different subsidies than together
  # NOTE They will be different as mentioned in the comment above
# Addl notes: I'm pretty sure the costs are based on how much it costs to ensure the whole family
# It's a pain, but you may need to test to see if the kids qualify for medicaid and then figure out how many
# people would enroll in the plan
# 1. filter for North Carolina and input a Forsyth County zip code, e.g., 27104
# 2. enter different pre-tax incomes above in '2. Enter yearly household income as...'
# 3. put No for '3. Is coverage available from your or your spouse’s job?'
# 4. age of adult/s assumed to be 40; do not add children Medicaid will cover them if eligible
# QUESTION Are you also assuming they don't smoke?
  # NOTE Yes, assuming they do not smoke

# TODO EL hasn't checked these yet bc of the notes above
aca_subsidies <- c(395, 365, 292, 754, 618, 543, 311, 177, 119, 444, 430, 370)

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
  # add in aca subsidies for adults only
  add_column(`ACA Subsidies` = aca_subsidies) %>% 
  # add MIC/MAF/NC Health Choice (the past Health Insurance column) with the ACA subsidies
  # IDEA Can children receive Medicaid and ACA subsidies? EL - no, can't get subsidies if in Medicaid
    # IDEA Add children's ACA subsidies when they are not eligible for Medicaid?
  mutate(`Health Insurance` = `Health Insurance` + `ACA Subsidies`) %>% 
  # FIXME They can't qualify for both. 
  # addl note: they either have medicaid, which should bring their costs to 0?
  # or they have a subsidy which brings their costs down to the monthly rate in 
  # the calculator 
    # Medicaid Eligibility: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://files.nc.gov/ncdma/documents/files/Basic-Medicaid-Eligibility-Chart-2020.pdf
    # NOTE Based on the monthly incomes provided in pre_tax_income, the household compositions and the Medicaid outputs in the benefits 
    # data frame, the Health Insurance (Medicaid) number only applies to children. Why? Based on the household incomes and the ages of the children
    # (2 and 4), children would only be eligible for MIC or NC Health Choice, which only provides full coverage for children, parents and caretakers
    # do not receive anything. Therefore, we calculate the ACA subsidies for adults only (I am in favor of calculating ACA subsidies for
    # children when they lose Medicaid eligibility) in an attempt to get an estimate of the Health Insurance benefit the household could receive
      # TODO to update the fpl threshold from 210 to 211% for the benefits table - if it matters for this analysis
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
  # NOTE EITC is added to after-tax income calculation, but we can add other tax credits too
  # QUESTION are those credits already included in the fiitax, siitax, and tfica
  # NOTE EL *thinks* you would only want to add them at the end if they are refundable credits
    # TODO EITC is a refundable tax credit. DL to reach out to Shane for better answers
  return_all_information = TRUE) %>% 
  select(taxsimid, fiitax, siitax, tfica, EITC = v25_eitc)

# View(family_taxes)

after_tax_income <- family_taxes %>% 
  # add round and family number columns to make sure everything lines up
  mutate(`Family Number` = rep(1:4, each = 3), .before = taxsimid) %>%
  mutate(Round = rep(1:3, times = 4), .before = `Family Number`) %>% 
  rowwise() %>% 
  # sum all tax liabilities together
  # from Shane: Total income tax liabilities would be fiitax + siitax + tifica
  mutate(tax_liabilities = sum(fiitax, siitax, tfica), .after = `Family Number`) %>% 
  # QUESTION Do people with negative liabilities get refunds? 
  # addl' note: EL thinks only specific credits are refundable, but I don't know what those are
  # QUESTION Is EITC included already in either state or federal tax liabilities? 
  # addl' note: Wouldn't want to double count it by pulling it out separately
  # If it's double-counted EL *thinks* that's the maximum amount someone would get paid if they have
  # a negative federal liability and that they would get paid either the EITC or
  # the absolute value of the negative tax liability, whichever is smallest
  # it doesn't look like NC offers EITC at the state level 
    # TODO DL to reach out to Shane
  ungroup() %>% 
  # make tax liabilities and eitc monthly
  mutate(across(tax_liabilities:length(.), ~ . / 12)) %>% 
  # add the pre-tax income column in from above
  add_column(pwages = pre_tax_income) %>% 
  # find the after-tax income, i.e., pre-tax income minus tax liabilities plus EITC
  mutate(`After-Tax Income` = pwages - tax_liabilities + EITC) %>% 
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
  # TODO Confirm with CB, but EL thinks health insurance expenses is survey data which should be handled differently here 
  # attl' note: EL thinks health insurance in livable income is what people report paying
  # in a survey. To my understanding, this incorporates employer, medicaid, ACA, etc. type subsidies - it's just the out of pocket cost. 
  # If this is the case, it would be better to use the cost of medicaid premiums ($0?) for people
  # with medicare and the cost you get from the KFF instead to calculate their expenses after subsidy
  # (you would just need to disclose you're using their silver plan estimate from the calculator)
  # FIXME EL thinks people getting Medicaid, just get medicaid, it's not a subsidy (shouldn't be subtracted)
  select(Round, `Family Number`, `Family Type`, `Child Care`, Housing, Food, `Health Care`,
         `Health Insurance`, Savings, Transportation, `Other Expenses`) %>% 
  # health insurance cannot be negative so make zero
  mutate(`Health Insurance` = ifelse(`Health Insurance` < 0, 0, `Health Insurance`)) %>% 
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
