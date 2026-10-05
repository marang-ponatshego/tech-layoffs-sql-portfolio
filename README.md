# Global Tech Layoffs — SQL Portfolio

An end-to-end SQL analysis of global tech layoffs from March 2020 to
March 2023 — from raw data cleaning through exploratory analysis,
using PostgreSQL.

The dataset covers ~2,300 layoff events across the world's largest
tech companies, capturing company, industry, country, funding stage,
and layoff severity.

---

## Key findings at a glance

- **$256,559 layoffs** in the United States — over **60% of the entire dataset**, and ~7× the next country (India).
- **2021 was the anomaly**: only **15,823 layoffs** all year — a hiring boom that briefly made layoffs nearly vanish. **March 2021 recorded just 47 layoffs worldwide.**
- **2022 exploded 10×** to **160,661 layoffs** — the peak year for the dataset.
- **2023 was on pace to be worse** — 125,677 layoffs in only 3 months of data.
- **116 companies laid off 100% of staff.** Crypto dominates the shutdown list.
- **95 companies shut down *despite* raising capital** — including Britishvolt (~$2.4B), Quibi (~$1.75B), and Katerra (~$1.6B). Capital is not a survival signal.

Full analysis and findings: see the [exploratory analysis README](./exploratory-analysis/README.md).

---

## Projects in this repo

### 📁 [data-cleaning](./data-cleaning/)
Cleaning the raw layoffs dataset using a standard four-step process:
deduplication, standardisation, NULL handling, and removal of
unnecessary rows. Output table `layoffs_staging2` feeds the
exploratory analysis.

**Skills demonstrated:** staging tables, `ROW_NUMBER()` with `PARTITION BY`,
self-joins for NULL recovery, `TRIM` / `UPDATE` for standardisation.

### 📁 [exploratory-analysis](./exploratory-analysis/)
Exploratory analysis of the cleaned data — aggregate cuts by industry,
country, and stage, plus a rolling cumulative view of layoffs over time.

**Skills demonstrated:** `GROUP BY` aggregations, `EXTRACT` for dates,
window functions (`SUM() OVER`, `DENSE_RANK() OVER`), CTEs, time-series
rolling totals.

---

## Tools

- **PostgreSQL** — all cleaning and analysis
- **Dataset** — global tech layoffs dataset (public, ~2,300 rows, March 2020 – March 2023)

---

## About

This portfolio demonstrates an end-to-end SQL workflow: taking messy
real-world data, cleaning it defensibly, then extracting business
insights from it.

Two portfolio projects, one pipeline:
