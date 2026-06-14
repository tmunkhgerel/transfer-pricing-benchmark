# Automated Transfer Pricing Economic Benchmarking & Valuation Engine

An end-to-end data pipeline that automates the screening and benchmarking
process used in **transfer pricing economic analysis**, following
**OECD Transfer Pricing Guidelines** for selecting comparable companies
and determining an arm's length range.

> **Note:** This project uses a fully synthetic mock dataset of 25,000+
> corporate records. No real or confidential client data is used.

## Overview

Multinational enterprises must demonstrate that intercompany transactions
(e.g., a subsidiary distributing goods for its parent company) are priced
in line with what unrelated parties would agree to — the **arm's length
principle**. This typically requires building a "comparable set" of
independent companies and analyzing their financial margins.

This project automates that process:

1. **Generate a mock database** of 25,000+ multinational corporate records
   with financial data spanning 3 years (`r/00_generate_mock_data.R`)
2. **Screen for comparability** using OECD criteria — asset size, geography,
   functional profile, and persistent operating losses (`sql/screening_queries.sql`)
3. **Calculate the arm's length range** — the interquartile range (IQR) of
   operating margins (EBIT/Revenue) across the final comparable set
   (`r/03_iqr_operating_margins.R`)
4. **Visualize results** in Power BI / Tableau dashboards, including a
   client risk matrix showing where a tested party falls relative to the
   arm's length range

## Methodology

| Step | Criterion | Description |
|------|-----------|-------------|
| 1 | Asset size | Filters comparables to a plausible size band relative to the tested party |
| 2 | Functional profile | Restricts the set to companies with comparable functions (e.g., distributors) |
| 3 | Geography | Limits comparables to a defined comparable market/region |
| 4 | Persistent losses | Excludes companies with operating losses in 2+ of the last 3 years (per OECD guidance) |
| 5 | IQR calculation | Computes Q1/median/Q3 of operating margins as the arm's length range |

## Tech Stack

- **R** — data pipeline, statistical calculations (dplyr)
- **SQL** — multi-step comparability screening (SQLite-compatible)
- **Power BI / Tableau** — dashboard visualization of arm's length ranges and risk matrices

## Repository Structure

```
transfer-pricing-benchmark/
├── README.md
├── data/
│   ├── mock_corporate_records.csv     # 25,000+ synthetic company records
│   └── mock_financials_panel.csv      # 3-year panel of financials
├── sql/
│   └── screening_queries.sql          # OECD comparability screening
├── r/
│   ├── 00_generate_mock_data.R        # Synthetic dataset generator
│   ├── 03_iqr_operating_margins.R     # Arm's length range calculation
├── dashboard/
│   └── (Power BI / Tableau file)
└── outputs/
    ├── iqr_results.csv
    └── company_margins.csv
```

## How to Run

```r
# 1. Generate the mock dataset
source("r/00_generate_mock_data.R")

# 2. Load CSVs into SQLite and run sql/screening_queries.sql
#    to produce data/final_comparable_set.csv

# 3. Calculate the arm's length range
source("r/03_iqr_operating_margins.R")
```

## Results

The pipeline outputs an arm's length range (IQR of operating margins) for
the final comparable set, and flags whether a tested party's margin falls
within, above, or below that range — directly supporting transfer pricing
risk assessment and documentation.

## Disclaimer

This project is for educational and portfolio purposes only. All data is
synthetically generated and does not represent any real company, client,
or transaction.
