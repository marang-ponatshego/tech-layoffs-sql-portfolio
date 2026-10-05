-- ============================================================
-- EXPLORATORY DATA ANALYSIS (EDA) PROJECT
-- ============================================================
-- Purpose: Explore the layoffs dataset with no specific agenda
-- Goal: Understand the data, find patterns, and discover insights
-- Approach: Start with broad questions, then drill down into specifics
-- ============================================================


-- ============================================================
-- 1. INITIAL DATA EXPLORATION
-- ============================================================

-- View the entire dataset
SELECT *
FROM layoffs_staging2;

-- Find the maximum values: largest single layoff event and highest percentage
SELECT MAX(total_laid_off) AS max_layoffs, 
       MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging2;

-- Find companies that laid off 100% of their workforce (complete shutdown)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Find companies that laid off 100% AND raised significant funding
-- These are companies that shutdown despite having raised millions
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
  AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;


-- ============================================================
-- 2. AGGREGATE ANALYSIS BY CATEGORY
-- ============================================================

-- Total layoffs by company (highest to lowest)
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Total layoffs by country
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- Date range of the dataset (when did layoffs start and end?)
SELECT MIN(date) AS earliest_date, 
       MAX(date) AS latest_date
FROM layoffs_staging2;


-- ============================================================
-- 3. TIME-BASED ANALYSIS
-- ============================================================

-- Total layoffs by year (2020, 2021, 2022, 2023, etc.)
SELECT EXTRACT(YEAR FROM date) AS year, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year DESC;

-- Total layoffs by company funding stage (Post-IPO, Series A, etc.)
-- Helps understand which stages are most vulnerable to layoffs
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- ============================================================
-- 4. ROLLING TOTAL (CUMULATIVE SUM) ANALYSIS
-- ============================================================

-- Monthly layoff totals (chronological order)
SELECT TO_CHAR(date, 'YYYY-MM') AS month, 
       SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month ASC;

-- Rolling total: Cumulative layoffs over time
-- Shows how the total grows month by month
WITH Rolling_Total AS
(
SELECT TO_CHAR(date, 'YYYY-MM') AS month, 
       SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month ASC
)
SELECT month, 
       monthly_layoffs, 
       SUM(monthly_layoffs) OVER(ORDER BY month) AS cumulative_layoffs
FROM Rolling_Total;


-- ============================================================
-- 5. TOP 5 COMPANIES PER YEAR ANALYSIS
-- ============================================================

-- Total layoffs per company per year (raw data)
SELECT company, 
       TO_CHAR(date, 'YYYY') AS year, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, TO_CHAR(date, 'YYYY')
ORDER BY total_layoffs DESC;

-- Ranking companies within each year by total layoffs
-- Shows which companies laid off the most each year
WITH Company_Year AS
(
SELECT company, 
       TO_CHAR(date, 'YYYY') AS years, 
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
),
Company_Year_Rank AS
(
SELECT *, 
       DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;  -- Show only the top 5 companies per year


-- ============================================================
-- 6. ADDITIONAL EXPLORATORY QUERIES (NON-EXHAUSTIVE)
-- ============================================================

-- Average layoffs per company per year
SELECT company, 
       TO_CHAR(date, 'YYYY') AS year, 
       AVG(total_laid_off) AS avg_layoffs_per_event
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
ORDER BY avg_layoffs_per_event DESC;

-- Total layoffs by month name (e.g., January, February)
SELECT TO_CHAR(date, 'Month') AS month_name, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY TO_CHAR(date, 'Month')
ORDER BY total_layoffs DESC;

-- Companies with the highest percentage laid off (top 10)
SELECT company, 
       percentage_laid_off, 
       total_laid_off, 
       funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC
LIMIT 10;

-- Layoffs trend by quarter (Q1, Q2, Q3, Q4)
SELECT EXTRACT(YEAR FROM date) AS year,
       EXTRACT(QUARTER FROM date) AS quarter,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(QUARTER FROM date)
ORDER BY year DESC, quarter DESC;

-- ============================================================
-- KEY INSIGHTS TO LOOK FOR
-- ============================================================
-- 1. Which industries were hit hardest?
-- 2. Which countries had the most layoffs?
-- 3. What was the worst month/year for layoffs?
-- 4. Which companies had the biggest single layoff event?
-- 5. Are there patterns by company stage (Series A vs Post-IPO)?
-- 6. How did layoffs trend over time (rolling total)?
-- 7. Which companies laid off 100% of their workforce?
-- 8. What were the top 5 companies per year?
