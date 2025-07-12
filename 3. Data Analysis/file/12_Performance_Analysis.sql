/*
===============================================================================
12. Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Script Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
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

-- Top performing customers by year
SELECT TOP 20
    'Top Customers by Year' AS analysis_type,
    c.first_name,
    c.last_name,
    c.country,
    YEAR(f.order_date) AS order_year,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders,
    RANK() OVER (PARTITION BY YEAR(f.order_date) ORDER BY SUM(f.sales_amount) DESC) AS yearly_rank
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
GROUP BY c.first_name, c.last_name, c.country, YEAR(f.order_date)
ORDER BY order_year, total_sales DESC;


