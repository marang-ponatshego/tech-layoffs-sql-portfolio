# Data Cleaning — Global Tech Layoffs

## Overview

This project cleans a raw dataset of global tech layoffs (2020–2023)
using a standard four-step data cleaning process. The cleaned table is
the input for the [exploratory analysis](../exploratory-analysis/) in this repo.

## Dataset

- **Source:** Global tech layoffs dataset (public, popularized by Alex The Analyst)
- **Rows:** ~2,300 layoff events
- **Columns:** `company`, `location`, `industry`, `total_laid_off`,
  `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`
- **Time period:** March 2020 – March 2023
- **Tool:** PostgreSQL

## Cleaning process

### Step 1 — Remove duplicates
Used `ROW_NUMBER()` with `PARTITION BY` across every identifying column
to detect and remove exact duplicate rows. Kept the first occurrence of
each group. The clean table was written to a new staging table
(`layoffs_staging2`) to preserve the original.

### Step 2 — Standardise the data
- Trimmed trailing spaces from company names
- Consolidated `Crypto` industry variations (e.g., "Crypto Currency") into one label
- Removed trailing periods from country names (e.g., "United States." → "United States")

### Step 3 — Handle NULL / blank values
- Identified rows with blank `industry`
- Used a **self-join** to populate blanks from other rows of the same company
- Left rows untouched where the industry could not be recovered

### Step 4 — Remove unnecessary rows and columns
- Deleted rows where **both** `total_laid_off` and `percentage_laid_off`
  were NULL (they carry no layoff information for this analysis)
- Dropped the temporary `row_num` helper column added in Step 1

## Output

Cleaned table: **`layoffs_staging2`**

This is the input to the exploratory analysis in this repo.

## Notes & trade-offs

- Rows with no layoff numbers were deleted. In a broader analysis
  (e.g., tracking *announcements* rather than *layoff volume*), those
  rows would be worth keeping. They were removed here because this
  project focuses on layoff magnitude.
