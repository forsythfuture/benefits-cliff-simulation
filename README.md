# Introduction

The Benefits Cliff Simulation game serves as a tool for the community to understand how household compositions, expenses, benefit programs, taxes, and income all play a crucial part in impacting a household's monthly net income. From this game, one can see that purely increases in income may cause more harm than good for particular households but not so for others.

For more information on how benefit amounts are calculated, please visit https://github.com/forsythfuture/benefits-cliff. In addition, please view the text below to understand how expenses by household composition were determined. If you have any further questions, please reach out to info@forsythfutures.org for additional guidance.

# Household Simulations Table

Round | Family | Household Type | Pre-Tax Yearly Income | Pre-Tax Hourly Wage | After-Tax Monthly Income | Monthly Expenses | Net Monthly Income
--- | --- | --- | --- | --- | --- | --- | --- 
1 | 1 | Two working adults with a 2- and 4-year-old | $69,626.40 | $33.50 | $5,069.86 | $5,959.75 | -$889.89
2 | 1 | Two working adults with a 2- and 4-year-old | $73,783.20 | $35.50 | $5,329.55 | $6,013.75 | -$684.20 
3 | 1 | Two working adults with a 2- and 4-year-old | $84,175.20 | $40.50 | $5,966.42 | $6,149.75 | -$183.33
1 | 2 | Two working adults with a 2- and 4-year-old | $42,607.20 | $20.50 | $3,556.71 | $3,910.18 | -$353.47
2 | 2 | Two working adults with a 2- and 4-year-old | $52,999.20 | $25.50 | $4,033.36 | $4,373.23 | -$339.87
3 | 2 | Two working adults with a 2- and 4-year-old | $59,234.40 | $28.50 | $4,421.77 | $5,842.75 | -$1,420.98
1 | 3 | One adult with a 2-and 4-year-old | $34,293.60 | $16.50 | $3,025.06 | $3,027.73 | -$2.67
2 | 3 | One adult with a 2-and 4-year-old | $44,685.60 | $21.50 | $3,482.88 | $3,677.38 | -$194.50
3 | 3 | One adult with a 2-and 4-year-old | $48,842.40 | $23.50 | $3,705.93 | $5,184.42 | -$1,478.48
1 | 4 | One adult | $15,068.40 | $7.25 | $1,116.94 | $1,367.79 | -$250.85
2 | 4 | One adult | $21,823.20 | $10.50 | $1,547.87 | $1,685.81 | -$137.94
3 | 4 | One adult | $29,097.60 | $14.00 | $2,003.09 | $1,950.75 | $52.34

# Household Expenses 

Household expenses include child care, rent, food, healthcare, health insurance, transportation, taxes, savings, and other expenses. Some expenses are based on individual characteristics (e.g., age) while others are based on household characteristics (e.g., the size of the household). These expenses represent the lowest cost of living that can be generally assumed for various situations. A short description of each measure and the geographic area captured is presented below.

Please note, any expenses that rely on inflation adjustments to a given year are adjusted using the Consumer Price Index (CPI) from the Bureau of Labor Statistics (BLS). The specific CPI used for all adjusted expenses — with the exception of internet expenses — is the CPI-U-RS. This represents the CPI for all urban consumers. Internet expenses used a specific telecommunications CPI to adjust for inflation (BLS, 2022). For more information, see the BLS’s description of the [Consumer Price Index](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm). Forsyth Futures does not anticipate the BLS releasing the full 2022 CPI-U-RS file before mid-March, 2023. 

## Child Care 

Child care expenses reflect both child care center costs, before/after school care, and summer care costs. Child care center costs reflect county-level costs for a 4-star center and are limited to children between the ages of 0 and 4. These costs are pulled from North Carolina Department of Health and Human Services’ (NC DHHS) Subsidized Child Care Market Rate Study (NC DHHS, n.d.). The latest report is from 2018 and costs were adjusted for inflation. 

Before/after school and summer care costs reflect a state average from ChildCare Aware of America estimates for children between the ages of 5 and 12 (ChildCare Aware of America, n.d.). Years with missing data were adjusted for inflation. 

Forsyth Futures assume that any adult 21 years old or older in the household who is not working (e.g., unemployed or not in the labor force) are able to provide child care. That is, households with at least one adult not working do not have any child care costs. 

## Housing 

The housing expense captures the likely cost of rental housing in Winston-Salem’s Metropolitan Statistical Area (MSA) using HUD Fair Market Rent (FMR) estimates (U.S. Department of Housing and Urban Development [HUD], n.d.). The FMR reflects gross rent and includes all utilities except cable and phone. The income insufficiency equation uses FMRs for one to four bedrooms depending on the household size. FMRs are set at the 40th percentile which means that 40% of rental housing in the Winston-Salem MSA is less expensive than the FMR, while 60% is more expensive. The Winston-Salem MSA includes Forsyth, Davidson, Stokes, Davie, and Yadkin counties. Both the Massachusetts Institute of Technology’s (MIT) Living Wage Calculator and the United Way’s Self Sufficiency Standard use the FMR for their housing expense estimates. 

Forsyth Futures assumes households with children under 18 share a bedroom (2 per room). 

## Food 

Food costs are calculated from the United States Dept. of Agriculture’s (USDA) low-cost food plan (USDA, 2021). Forsyth Futures used food costs by age from January, 2019. Since the food plan reflects a national estimate, a regional adjustment is made to reflect estimated food expenses in the South. 

## Health Care

Health care expenditures beyond health insurance were calculated from the Medical Expenditure Panel Survey (MEPS) at the regional level (South) and by different age groups (Agency for Healthcare Research Quality, 2019). The query tool, MEPSNet, was used to pull data that captures the total amount paid by an individual/family on health care. That query tool is no longer supported by MEPS and the most recent year of data is from 2015. Expenses were adjusted for inflation. The United Way’ Self-Sufficiency Standard also uses the 2015 MEPS to calculate out-of-pocket expenses while MIT uses the Consumer Expenditure Survey (CES) to estimate health care costs. 

## Health Insurance

Health insurance costs are calculated from the Kaiser Family Foundation's Health Insurance Marketplace Calculator. By entering the prompts based on the household's profile, the monthly cost of a silver plan, without any financial help, in Forsyth County for 2022 is outputted.

Note: The benefits cliff simulation analysis subtracts Affordable Care Act (ACA) subsidies that the family is eligible for from the monthly cost of a silver plan to calculate the difference in health insurance costs. However, children who are eligible for Medicaid for Infants and Children are not acknowledged in the generation of the monthly cost of a silver plan since the children's health insurance costs are assumed to be zero; therefore, the monthly cost of a silver plan and the amount of eligible ACA subsidies are calculated for the adult/s in the household only in these situations.

## Transportation

Transportation expenses are calculated from the Consumer Expenditure Survey. It includes used car and truck purchases, maintenance, car insurance, gas/other fuels and oil, public transportation costs, and other miscellaneous vehicle expenses (e.g., car rentals, car registration fees). 

## Taxes

Federal, state, and payroll taxes for tax filing units are estimated using [NBER's TAXSIM](http://taxsim.nber.org/taxsim35/) with the [usincometaxes](https://www.shaneorr.io/r/usincometaxes/) R package.

## Other Expenses

A majority of the expenses categorized as ‘Other Expenses’ are sourced from the Consumer Expenditure Survey. They include apparel and services, housekeeping supplies, personal care products and services, reading materials (includes subscriptions to newspapers and magazines), and miscellaneous expenses (e.g., checking and/or bank services fees, funeral expenses, legal fees). 

Additionally, cell phone and internet expenses fall under ‘Other Expenses.’ The Consumer Expenditure Survey is used as the data source for cell phone expenditures which only reflects the costs of cellular service and not the costs of a phone, accessories, or broken screen repairs. An internet expense was added using BroadbandNow Research’s open data source (n.d.). Their pricing data reflects publicly-available residential internet plans from more than 2,000 different internet providers in 2020. 

All Consumer Expenditure Survey data is adjusted so costs reflect costs in the South and accounts for the size of the household, while internet expenses are at the county and state level and each household gets one internet expense. 

## Summary Expense Table 

Expense Category | Source Name(s) | Source Institution(s) | Geographic Level(s) of Data
--- | --- | --- | --- 
Child Care | North Carolina Child Care Market Rate Study; The US and the High Price of Child Child Care | NC Department of Health and Human Services (NC DHHS); ChildCare Aware of America  | State and County
Housing | Fair Market Rents (FMR) | US Department of Housing and Urban Development (HUD) | County
Food | Low-Cost Food Plan | US Department of Agriculture (USDA) | Region 
Health Care | Medical Expenditure Panel Survey (MEPS) | US Department of Health and Human Services (US DHHS) | Region 
Health Insurance | Health Insurance Marketplace Calculator | Kaiser Family Foundation | County 
Transportation | Consumer Expenditure Survey (CES) | Bureau of Labor Statistics (BLS) | Region 
Taxes | Federal and State Tax Codes; TAXSIM 35 | US Congress; National Bureau of Economic Research | National and State
Other Expenses | Consumer Expenditure Survey (CES); Zipcode Competition & Pricing Data | Bureau of Labor Statistics (BLS); BroadbandNow Research | Region and County 

## Savings Expenses 

The ABC Living Wage Committee requested that Forsyth Futures add a savings estimate to the income insufficiency equation. This was requested to address the ABC’s focus on alleviating Asset Poverty, which measures how many households are ‘asset poor’ — meaning they lack savings to afford basic needs for three months at the federal poverty level. The ABC Living Wage Committee decided the savings expense measure should reflect 10% of a household’s income and this reflects some financial planners suggestions for retirement saving (see [CNN Money](https://money.cnn.com/retirement/guide/basics_basics.moneymag/index7.htm), n.d.), however, some will suggest saving 20% of a household’s income as part of 50/20/30 rule (Smith, 2021). 

