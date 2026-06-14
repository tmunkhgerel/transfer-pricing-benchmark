-- ============================================================
-- screening_queries.sql
-- OECD-aligned comparability screening for transfer pricing
-- benchmarking. Assumes tables: companies, financials_panel
-- (loaded into SQLite or similar from the mock CSV files)
-- ============================================================

-- Step 1: Asset size filter
-- Keep companies within a plausible size band of the tested party
-- (example threshold: USD 1M - 500M total assets)
CREATE VIEW filtered_by_size AS
SELECT *
FROM companies
WHERE total_assets_usd_m BETWEEN 1 AND 500;

-- Step 2: Functional profile filter
-- Restrict to comparable functional roles (e.g., distributors)
CREATE VIEW filtered_by_function AS
SELECT *
FROM filtered_by_size
WHERE functional_profile IN ('Distributor', 'Limited Risk Distributor');

-- Step 3: Geography filter
-- Example: restrict to a defined comparable region
CREATE VIEW filtered_by_geography AS
SELECT *
FROM filtered_by_function
WHERE country IN ('Germany', 'France', 'Netherlands', 'Poland', 'United Kingdom');

-- Step 4: Persistent operating loss screen
-- Exclude companies with negative operating margin in 2+ of the last 3 years
CREATE VIEW persistent_loss_companies AS
SELECT company_id
FROM financials_panel
WHERE operating_margin < 0
GROUP BY company_id
HAVING COUNT(*) >= 2;

-- Step 5: Final comparable set
CREATE VIEW final_comparable_set AS
SELECT g.*
FROM filtered_by_geography g
WHERE g.company_id NOT IN (SELECT company_id FROM persistent_loss_companies);

-- Step 6: Pull financials for the final comparable set (latest year)
SELECT c.company_id, c.company_name, c.country, c.industry,
       c.functional_profile, c.total_assets_usd_m,
       f.year, f.revenue_usd_m, f.ebit_usd_m, f.operating_margin
FROM final_comparable_set c
JOIN financials_panel f ON c.company_id = f.company_id
WHERE f.year = (SELECT MAX(year) FROM financials_panel)
ORDER BY f.operating_margin;
