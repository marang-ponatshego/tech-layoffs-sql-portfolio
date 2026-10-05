-- ============================================================
-- DATA CLEANING PROJECT - LAYOFFS DATASET
-- ============================================================
-- Overview: Cleaning layoffs data using the 4-step data cleaning process
-- Step 1: Remove duplicates (if any)
-- Step 2: Standardise the data (make units, spelling, formats consistent)
-- Step 3: Handle NULL/blank values (populate them if possible)
-- Step 4: Remove unnecessary rows and columns (if needed)
-- ============================================================


-- ============================================================
-- 0. CREATE STAGING TABLE (Safety First!)
-- ============================================================
-- Always create a copy/replica of your raw data before making any changes.
-- This protects your original data in case you make a mistake.

CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs;

-- Verify the staging table was created correctly
SELECT *
FROM layoffs_staging;


-- ============================================================
-- STEP 1: REMOVE DUPLICATES
-- ============================================================

-- 1a. Identify duplicates using ROW_NUMBER()
-- PARTITION BY: Groups identical rows together
-- ROW_NUMBER(): Assigns 1 to the first occurrence, 2, 3, etc. to duplicates
WITH duplicate_cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY company,
                                          location,
                                          industry,
                                          total_laid_off,
                                          percentage_laid_off,
                                          date,
                                          stage,
                                          country,
                                          funds_raised_millions) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;  -- Returns only duplicate rows (2nd, 3rd, etc.)

-- 1b. Verify a specific company to check for duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- 1c. Create a clean table with only unique rows (row_num = 1)
-- This creates a new table without duplicates, preserving the original
CREATE TABLE layoffs_staging2 AS
WITH duplicate_cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY company,
                                          location,
                                          industry,
                                          total_laid_off,
                                          percentage_laid_off,
                                          date,
                                          stage,
                                          country,
                                          funds_raised_millions) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num = 1;  -- Keeps only first occurrence of each duplicate group

-- 1d. Verify the clean table
SELECT *
FROM layoffs_staging2;


-- ============================================================
-- STEP 2: STANDARDISE THE DATA
-- ============================================================
-- Goal: Find inconsistencies and fix them (spelling, formatting, trailing spaces)

-- 2a. Remove trailing spaces from company names
SELECT company, TRIM(company) AS trimmed
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2b. Standardise industry names
-- Check all unique industries to spot variations
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- Check for 'Crypto' variations (e.g., 'Crypto', 'Crypto Currency')
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardise all Crypto variations to just 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Verify the update worked
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- 2c. Remove trailing dots from country names
-- Example: 'United States.' → 'United States'
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country) AS cleaned_country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 2d. Date formatting (for viewing/display only)
-- Note: This does NOT change the data type; it just formats it for display
-- The date column remains a DATE type in the table
SELECT date, TO_CHAR(date, 'MM/DD/YYYY') AS formatted_date
FROM layoffs_staging2;


-- ============================================================
-- STEP 3: HANDLE NULL/BLANK VALUES
-- ============================================================

-- 3a. Identify rows where BOTH total_laid_off AND percentage_laid_off are NULL
-- These rows provide no layoff information and might be candidates for deletion
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
  AND percentage_laid_off IS NULL;

-- 3b. Find rows with missing industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- 3c. Check a specific company to see if industry can be populated from another row
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- 3d. Self-join to find fillable NULLs
-- Find rows where industry is blank, but the same company has a populated industry in another row
SELECT t1.company, t1.industry, t2.company, t2.industry                     
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') 
  AND t2.industry IS NOT NULL;

-- 3e. Update blank industries with populated values from the same company
UPDATE layoffs_staging2 AS t1
SET industry = t2.industry
FROM layoffs_staging2 AS t2
WHERE t1.company = t2.company
  AND (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- 3f. Verify the updates worked for a specific company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


-- ============================================================
-- STEP 4: REMOVE UNNECESSARY ROWS AND COLUMNS
-- ============================================================

-- 4a. Identify rows with no layoff data (both total_laid_off AND percentage_laid_off are NULL)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 4b. Delete rows that have no useful layoff information
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 4c. Drop the temporary row_num column (no longer needed)
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ============================================================
-- FINAL VERIFICATION
-- ============================================================
-- Check the final clean dataset
SELECT COUNT(*) AS total_rows FROM layoffs_staging2;

-- Preview the cleaned data
SELECT *
FROM layoffs_staging2
LIMIT 10;

-- Check for any remaining duplicates
SELECT company, date, COUNT(*)
FROM layoffs_staging2
GROUP BY company, date
HAVING COUNT(*) > 1;

-- Check for any remaining NULL industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- ============================================================
-- SUMMARY OF CHANGES MADE
-- ============================================================
-- 1. Created staging table (layoffs_staging) as a backup
-- 2. Removed duplicates → Created layoffs_staging2 with only unique rows
-- 3. Standardised data:
--    - Trimmed spaces from company names
--    - Standardised 'Crypto' variations to a single value
--    - Removed trailing dots from 'United States'
-- 4. Handled NULLs:
--    - Populated blank industries from other rows of the same company
-- 5. Removed unnecessary rows:
--    - Deleted rows where both total_laid_off AND percentage_laid_off were NULL
--    - Dropped the temporary row_num column
