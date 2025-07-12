/*
===============================================================================
06. Date Range Exploration
===============================================================================
Script Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.
    - To analyze seasonal patterns and trends over time.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Basic Data Check
-- =============================================================================
PRINT '=== BASIC DATA CHECK ===';

-- Check if tables exist and have data
SELECT 'fact_sales' AS table_name, COUNT(*) AS row_count FROM gold.fact_sales
UNION ALL
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count FROM gold.dim_customers
UNION ALL
SELECT 'dim_products' AS table_name, COUNT(*) AS row_count FROM gold.dim_products;

-- Check sample data
SELECT TOP 5 * FROM gold.fact_sales;
SELECT TOP 5 * FROM gold.dim_customers;
SELECT TOP 5 * FROM gold.dim_products;

-- Check date ranges
SELECT 'fact_sales dates' AS info, 
       MIN(order_date) AS min_date, 
       MAX(order_date) AS max_date,
       COUNT(DISTINCT YEAR(order_date)) AS distinct_years
FROM gold.fact_sales
WHERE order_date IS NOT NULL;

-- =============================================================================
-- Sales Timeline Analysis
-- =============================================================================
PRINT '=== SALES TIMELINE ANALYSIS ===';



-- Determine the first and last order date and the total duration
SELECT 
    'Sales Timeline Overview' AS analysis_type,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) AS total_orders,
    DATEDIFF(day, MIN(order_date), MAX(order_date)) AS order_range_days,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months,
    DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales
WHERE order_date IS NOT NULL;

-- Sales by year
SELECT 
    'Sales by Year' AS analysis_type,
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders,
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_order_value,
    COUNT(DISTINCT customer_key) AS unique_customers,
    COUNT(DISTINCT product_key) AS unique_products
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Sales by month (across all years)
SELECT *
FROM (
    SELECT 
        'Sales by Month' AS analysis_type,
        MONTH(order_date) AS order_month,
        DATENAME(month, order_date) AS month_name,
        COUNT(*) AS total_orders,
        SUM(sales_amount) AS total_sales,
        AVG(sales_amount) AS avg_order_value
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date), DATENAME(month, order_date)
) t
ORDER BY t.order_month;

-- Sales by quarter
SELECT 
    'Sales by Quarter' AS analysis_type,
    YEAR(order_date) AS order_year,
    DATEPART(quarter, order_date) AS quarter,
    COUNT(*) AS total_orders,
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), DATEPART(quarter, order_date)
ORDER BY order_year, quarter;

-- =============================================================================
-- Customer Demographics Timeline
-- =============================================================================
PRINT '=== CUSTOMER DEMOGRAPHICS TIMELINE ===';



-- Find the youngest and oldest customer based on birthdate
SELECT
    'Customer Age Analysis' AS analysis_type,
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age,
    AVG(DATEDIFF(YEAR, birthdate, GETDATE())) AS average_age,
    COUNT(*) AS total_customers
FROM gold.dim_customers
WHERE birthdate IS NOT NULL;

-- Customer creation timeline
SELECT *
FROM (
    SELECT 
        'Customer Creation Timeline' AS analysis_type,
        YEAR(create_date) AS creation_year,
        MONTH(create_date) AS creation_month,
        DATENAME(month, create_date) AS month_name,
        COUNT(*) AS new_customers,
        SUM(COUNT(*)) OVER (ORDER BY YEAR(create_date), MONTH(create_date)) AS cumulative_customers
    FROM gold.dim_customers
    WHERE create_date IS NOT NULL
    GROUP BY YEAR(create_date), MONTH(create_date), DATENAME(month, create_date)
) t
ORDER BY t.creation_year, t.creation_month;

-- Customer age distribution by creation year
SELECT *
FROM (
    SELECT 
        'Customer Age by Creation Year' AS analysis_type,
        YEAR(create_date) AS creation_year,
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, create_date) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END AS age_at_creation,
        COUNT(*) AS customer_count
    FROM gold.dim_customers
    WHERE create_date IS NOT NULL AND birthdate IS NOT NULL
    GROUP BY 
        YEAR(create_date),
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, create_date) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, birthdate, create_date) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END
) t
ORDER BY t.creation_year, t.age_at_creation;

-- =============================================================================
-- Product Timeline Analysis
-- =============================================================================
PRINT '=== PRODUCT TIMELINE ANALYSIS ===';



-- Product introduction timeline
SELECT *
FROM (
    SELECT 
        'Product Introduction Timeline' AS analysis_type,
        YEAR(start_date) AS introduction_year,
        MONTH(start_date) AS introduction_month,
        DATENAME(month, start_date) AS month_name,
        COUNT(*) AS new_products,
        SUM(COUNT(*)) OVER (ORDER BY YEAR(start_date), MONTH(start_date)) AS cumulative_products
    FROM gold.dim_products
    WHERE start_date IS NOT NULL
    GROUP BY YEAR(start_date), MONTH(start_date), DATENAME(month, start_date)
) t
ORDER BY t.introduction_year, t.introduction_month;

-- =============================================================================
-- Seasonal Analysis
-- =============================================================================
PRINT '=== SEASONAL ANALYSIS ===';



-- Sales by season
SELECT *
FROM (
    SELECT 
        'Sales by Season' AS analysis_type,
        CASE 
            WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
        END AS season,
        COUNT(*) AS total_orders,
        SUM(sales_amount) AS total_sales,
        AVG(sales_amount) AS avg_order_value,
        COUNT(DISTINCT customer_key) AS unique_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY 
        CASE 
            WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
        END
) t
ORDER BY 
    CASE t.season
        WHEN 'Winter' THEN 1
        WHEN 'Spring' THEN 2
        WHEN 'Summer' THEN 3
        WHEN 'Fall' THEN 4
    END;

-- Monthly sales patterns
SELECT *
FROM (
    SELECT 
        'Monthly Sales Patterns' AS analysis_type,
        MONTH(order_date) AS month_number,
        DATENAME(month, order_date) AS month_name,
        COUNT(*) AS total_orders,
        SUM(sales_amount) AS total_sales,
        AVG(sales_amount) AS avg_order_value,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_percentage,
        ROUND(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER (), 2) AS sales_percentage
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date), DATENAME(month, order_date)
) t
ORDER BY t.month_number;

-- =============================================================================
-- Time-based Performance Metrics
-- =============================================================================
PRINT '=== TIME-BASED PERFORMANCE METRICS ===';



-- Year-over-year growth
WITH yearly_sales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        COUNT(*) AS total_orders,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS unique_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT 
    'Year-over-Year Growth' AS analysis_type,
    order_year,
    total_orders,
    total_sales,
    unique_customers,
    LAG(total_orders) OVER (ORDER BY order_year) AS prev_year_orders,
    LAG(total_sales) OVER (ORDER BY order_year) AS prev_year_sales,
    LAG(unique_customers) OVER (ORDER BY order_year) AS prev_year_customers,
    CASE 
        WHEN LAG(total_orders) OVER (ORDER BY order_year) > 0 
        THEN ROUND((total_orders - LAG(total_orders) OVER (ORDER BY order_year)) * 100.0 / LAG(total_orders) OVER (ORDER BY order_year), 2)
        ELSE NULL 
    END AS order_growth_percentage,
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY order_year) > 0 
        THEN ROUND((total_sales - LAG(total_sales) OVER (ORDER BY order_year)) * 100.0 / LAG(total_sales) OVER (ORDER BY order_year), 2)
        ELSE NULL 
    END AS sales_growth_percentage
FROM yearly_sales
ORDER BY order_year;

-- Monthly trends (across all years)
SELECT 
    'Monthly Trends' AS analysis_type,
    MONTH(order_date) AS month_number,
    DATENAME(month, order_date) AS month_name,
    COUNT(*) AS total_orders,
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_order_value,
    COUNT(DISTINCT customer_key) AS unique_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_percentage
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date), DATENAME(month, order_date)
ORDER BY month_number;

-- =============================================================================
-- Data Completeness Analysis
-- =============================================================================
PRINT '=== DATA COMPLETENESS ANALYSIS ===';



-- Check for missing dates
SELECT 
    'Data Completeness Check' AS analysis_type,
    'Sales with null order_date' AS check_type,
    COUNT(*) AS missing_count
FROM gold.fact_sales 
WHERE order_date IS NULL
UNION ALL
SELECT 
    'Data Completeness Check',
    'Customers with null birthdate',
    COUNT(*)
FROM gold.dim_customers 
WHERE birthdate IS NULL
UNION ALL
SELECT 
    'Data Completeness Check',
    'Customers with null create_date',
    COUNT(*)
FROM gold.dim_customers 
WHERE create_date IS NULL
UNION ALL
SELECT 
    'Data Completeness Check',
    'Products with null start_date',
    COUNT(*)
FROM gold.dim_products 
WHERE start_date IS NULL;

-- Date range summary
SELECT 
    'Date Range Summary' AS analysis_type,
    'Sales' AS data_type,
    MIN(order_date) AS earliest_date,
    MAX(order_date) AS latest_date,
    COUNT(*) AS total_records
FROM gold.fact_sales
WHERE order_date IS NOT NULL
UNION ALL
SELECT 
    'Date Range Summary',
    'Customer Birthdates',
    MIN(birthdate),
    MAX(birthdate),
    COUNT(*)
FROM gold.dim_customers
WHERE birthdate IS NOT NULL
UNION ALL
SELECT 
    'Date Range Summary',
    'Customer Creation',
    MIN(create_date),
    MAX(create_date),
    COUNT(*)
FROM gold.dim_customers
WHERE create_date IS NOT NULL
UNION ALL
SELECT 
    'Date Range Summary',
    'Product Introduction',
    MIN(start_date),
    MAX(start_date),
    COUNT(*)
FROM gold.dim_products
WHERE start_date IS NOT NULL;

PRINT 'Date range exploration completed successfully!'; 