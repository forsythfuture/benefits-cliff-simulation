# Introduction

The Benefits Cliff Simulation game serves as a tool for the community to understand how household composition, expenses, benefit programs, taxes, and income all play a crucial part in impacting a household's monthly net income. From this game, one can see that purely increases in income may cause more harm than good for particular households but not so for others.

For more information on how benefit amounts are calculated, please visit https://github.com/forsythfuture/benefits-cliff. In addition, please view the text below to understand how expenses by household composition were determined. If you have any further questions, please reach out to info@forsythfutures.org for additional guidance.

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

Health insurance costs are calculated from the Consumer Expenditure Survey (US Bureau of Labor Statistics [BLS], 2021). The most recent data costs were regionally adjusted (South) and costs account for differences in spending by age in addition to household size.

## Transportation

Transportation expenses are calculated from the Consumer Expenditure Survey. It includes used car and truck purchases, maintenance, car insurance, gas/other fuels and oil, public transportation costs, and other miscellaneous vehicle expenses (e.g., car rentals, car registration fees). 

## Taxes

Federal and state taxes are calculated on various income data from the American Community Survey and include non-wage income (i.e., social security income) in the calculation. After the incomes and number of dependents are calculated for each tax unit, taxes are estimated using [NBER's TAXSIM](http://taxsim.nber.org/taxsim35/) from a statistical software R.

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
Health Insurance | Consumer Expenditure Survey (CES) | Bureau of Labor Statistics (BLS) | Region 
Transportation | Consumer Expenditure Survey (CES) | Bureau of Labor Statistics (BLS) | Region 
Taxes | Federal and State Tax Codes; TAXSIM 35 | US Congress; National Bureau of Economic Research | National and State 
Other Expenses | Consumer Expenditure Survey (CES); Zipcode Competition & Pricing Data | Bureau of Labor Statistics (BLS); BroadbandNow Research | Region and County 

## Savings Expenses 

The ABC Living Wage Committee requested that Forsyth Futures add a savings estimate to the income insufficiency equation. This was requested to address the ABC’s focus on alleviating Asset Poverty, which measures how many households are ‘asset poor’ — meaning they lack savings to afford basic needs for three months at the federal poverty level. The ABC Living Wage Committee decided the savings expense measure should reflect 10% of a household’s income and this reflects some financial planners suggestions for retirement saving (see [CNN Money](https://money.cnn.com/retirement/guide/basics_basics.moneymag/index7.htm), n.d.), however, some will suggest saving 20% of a household’s income as part of 50/20/30 rule (Smith, 2021). 

