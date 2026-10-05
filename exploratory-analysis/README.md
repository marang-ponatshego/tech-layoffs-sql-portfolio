# Exploratory Data Analysis — Global Tech Layoffs

## Overview

Exploratory analysis of the cleaned layoffs dataset (`layoffs_staging2`),
covering March 2020 – March 2023. The goal is to understand the shape
of the data: which industries, countries, and company stages saw the
deepest cuts, and how layoffs trended over time.

**Input:** cleaned table from [data-cleaning](../data-cleaning/)
**Tool:** PostgreSQL

## What the analysis covers

The script is organised into six sections:

1. **Initial data exploration** — scale and outer bounds of the dataset
2. **Aggregate analysis** — totals by company, industry, country
3. **Time-based analysis** — by year and by company funding stage
4. **Rolling total** — cumulative layoffs over time (window function)
5. **Top 5 companies per year** — ranked within each year
6. **Supplementary cuts** — averages, monthly views, percentage rankings

---

## Key findings

### 1. The dataset is dominated by one country

The United States accounts for **256,559 layoffs** — over 60% of all
layoffs recorded and roughly **7× the next country (India, 35,993)**.
Netherlands (17,220), Sweden (11,264), Brazil (10,391), and Germany
(8,701) trail far behind. In practice, this dataset is a story about
**US tech**, with India as a distant second.

### 2. Layoffs are boom-and-bust, not steady

Annual totals show an extreme cycle:

| Year | Total layoffs |
|---|---|
| 2020 | 80,998 |
| 2021 | **15,823** |
| 2022 | **160,661** |
| 2023* | **125,677** |

*2023 covers only ~3 months (Jan–Mar). Annualised, it would be the
worst year on record.

The most striking single number in the dataset: **March 2021 recorded
just 47 layoffs worldwide** — a month that sits between April 2020's
26,710 (COVID shock) and the explosive 2022 correction. That ~568×
swing in 11 months is the clearest evidence that tech layoffs are
cyclical, not constant.

### 3. 2022 was the turning point

Layoffs collapsed in 2021 (the hiring boom), then **exploded 10× in
2022** to 160,661. This is the year Meta, Amazon, Twitter, Salesforce,
and Stripe all ran mass cuts.

### 4. 116 companies shut down completely

**116 companies in the dataset laid off 100% of their workforce.**
Crypto dominates the shutdown list — Digital Surge, Nuri, WeTrade,
Bitfront, BlockFi, Wyre — reflecting the 2022 crypto winter. But the
shutdowns span every stage: from Seed rounds to Series E companies.

### 5. Capital raised does not guarantee survival

**95 companies shut down despite having raised funding.** High-profile
failures include:

- **Britishvolt** (UK, battery) — raised ~$2.4B
- **Quibi** (US, media) — raised ~$1.75B
- **Katerra** (US, construction) — SoftBank-backed, ~$1.6B
- **BlockFi** (US, crypto) — Series E, bankrupt post-FTX
- **Fast** (US, fintech) — Series B, shut down 2022
- **The Wing** (US, real estate) — Series C

Going public wasn't a shield either: **Deliveroo Australia** and
**Openpay** shut down despite being Post-IPO.

### 6. Crypto is a shutdown story, not a headcount story

Crypto ranks **13th by total layoffs (10,693)** — but dominates the
list of complete shutdowns. This contrast is important: crypto
companies are smaller in headcount, so their failure shows up as
*shutdown volume* rather than *layoff volume*.

### 7. Highest-volume industries: Consumer and Retail

| Rank | Industry | Total layoffs |
|---|---|---|
| 1 | Consumer | 45,182 |
| 2 | Retail | 43,613 |
| 3 | Transportation | 33,748 |
| 4 | Finance | 28,344 |
| 5 | Healthcare | 25,953 |

Combined, Consumer and Retail account for **~89,000 layoffs**.

---

## Notes & caveats

- **"Other" industry category** contains 36,289 layoffs — an
  unhelpful bucket that limits interpretation for that segment.
- **NULL values** in `industry`, `country`, and `date` appear in the
  data and are visible in the raw outputs. Filtering to
  `total_laid_off IS NOT NULL` is required for meaningful rankings,
  because PostgreSQL treats NULLs as largest in `ORDER BY DESC`.
- **2023 data is truncated** (ends March), so year-over-year comparisons
  involving 2023 must account for the partial window.

---

## What's next

This is an exploratory pass. A follow-up business analysis could test
specific hypotheses — e.g., which industries/stages are highest-risk
going forward — using this cleaned dataset as input.
