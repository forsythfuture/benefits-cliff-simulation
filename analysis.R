
library(tidyverse)

# --------------------------------------------------------------

# Expenses

# livable wages' family type expenses dataset
expenses <- readr::read_csv('~/benefits-cliff-simulation/csvs/itemized_expenses_family_type.csv') %>% 
  # remove taxes and the total expenses columns
  select(-`Total Expenses`, -`Taxes`) %>% 
  # filter for needed family types
  filter(`Family Type` %in% c('Two working adults with a 2- and 4-year-old', 'One adult with a 2-and 4-year-old', 'One adult')) %>% 
  slice(1, rep(2, 2), 3) %>% 
  # add in family number identification
  mutate(`Family Number` = c(4, 1, 2, 3), .before = `Family Type`) %>% 
  # make yearly estimates monthly
  mutate(across(3:length(.), ~ ./ 12)) %>% 
  # repeat the four family types 3 times since they go through three rounds
  slice(rep(1:4, times = 3)) %>%
  # add in a round column identification
  mutate(Round = rep(1:3, each = 4), .before = `Family Number`)

# View(expenses)

# --------------------------------------------------------------

# Benefits

# read in master benefits spreadsheet
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

# Household monthly incomes and corresponding wages for the different household compositions

# Single
# 7.25, 10.50, 14.00 - Wage
# 1255.7, 1818.6, 2424.8 - Monthly

# Single two children
# 16.50, 21.50, 23.50 - Wage
# 2857.8, 3723.8, 4070.2 - Monthly

# Two parents, two children
# 20.50, 25.50, 28.50 - Wage
# 3550.6, 4416.6, 4936.2 - Monthly

# Two parents, two children
# 33.50, 35.50, 40.50 - Wage
# 5802.2, 6148.6, 7014.6 - Monthly

# household compositions, household pre-tax income, family number, and round number vectors
households <- c(rep('2 adults, 2 children', 6), rep('1 adult, 2 children', 3), rep('1 adult', 3))
# NOTE the third element in the pre_tax_income is 7000 not 7014.6 because the benefits' dataset only goes up to 7000
pre_tax_income <- c(5802, 6149, 7000, 3551, 4417, 4936, 2858, 3724, 4070, 1256, 1819, 2425)
family <- rep(1:4, each = 3)
round <- rep(1:3, times = 4)

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
         Transportation = 0)

# View(outcomes)

# --------------------------------------------------------------

# Taxes

# https://www.shaneorr.io/r/usincometaxes/

# create a data frame of needed inputs to run through TAXSIM 35
# order matches that of the outcomes dataset above
family_income <- data.frame(
  taxsimid = seq(1, 12), # identifier
  state = rep('North Carolina', 12),
  year = rep(2019, 12),
  mstat = c(rep('married, jointly', 6), rep('single', 6)), # filing status of tax unit
  pwages = pre_tax_income, # primary wages
  # TODO add ages if livable wage uses ages
  # page = c(), # primary taxpayer age
  # sage = c(), # spouse age
  depx = c(rep(2, 9), rep(0, 3)), # number of dependents
  age1 = c(rep(2, 9), rep(0, 3)), # age child 1
  age2 = c(rep(4, 9), rep(0, 3)), # age child 2
  rentpaid = c(rep(772.5833, 9), rep(617.8333, 3)), # rent cost
  childcare = c(rep(1646.5, 9), rep(0, 3)) # child care cost
)

# calculate taxes
family_taxes <- usincometaxes::taxsim_calculate_taxes(
  .data = family_income,
  marginal_tax_rates = 'Wages',
  # TODO if we want to add in eitc or other columns into our tax liability sum below, we can
  return_all_information = FALSE
)

# View(family_taxes)

after_tax_income <- family_taxes %>% 
  # add round and family number columns to make sure everything lines up
  mutate(`Family Number` = rep(1:4, each = 3), .before = taxsimid) %>%
  mutate(Round = rep(1:3, times = 4), .before = `Family Number`) %>% 
  rowwise() %>% 
  # FIXME redo sum after Shane's response
  mutate(tax_liabilities = sum(fiitax, siitax, fica, tfica), .after = `Family Number`) %>% 
  ungroup() %>% 
  # add the pre-tax income column in from above
  add_column(pwages = pre_tax_income) %>% 
  # find the after-tax income, i.e., pre-tax income minus tax liabilities
  mutate(`After-Tax Income` = pwages - tax_liabilities) %>% 
  arrange(Round) %>% 
  pull(`After-Tax Income`)
  
# --------------------------------------------------------------

# Expenses - Benefits = Total Expenses; Total Expenses - After-Tax Income = Balance

# row bind the expenses and outcomes datasets
# TODO make health insurance zero if negative, check out ACA subsidy
# TODO medicaid are zero until threshold broken, use this link - https://www.kff.org/interactive/subsidy-calculator/, 
# pick one plan for everyone - pre tax income
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
  # add the after-tax income column in from above
  add_column(`After-Tax Income` = after_tax_income) %>% 
  # find the monthly balance, i.e, income minus expenses
  mutate(Balance = `After-Tax Income` - `Total Expenses`) %>% 
  ungroup()

View(dat)

# readr::write_csv(dat, '~/benefits-cliff-simulation/csvs/benefit-simulation.csv')
