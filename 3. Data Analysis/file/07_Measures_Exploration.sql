/*
===============================================================================
07. Measures Exploration (Key Metrics)
===============================================================================
Script Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.
    - To establish baseline performance indicators.
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

-- Check key metrics
SELECT 'fact_sales metrics' AS info,
       SUM(sales_amount) AS total_sales,
       SUM(quantity) AS total_quantity,
       AVG(price) AS avg_price,
       COUNT(DISTINCT order_number) AS unique_orders
FROM gold.fact_sales;

-- =============================================================================
-- Sales Performance Metrics
-- =============================================================================
PRINT '=== SALES PERFORMANCE METRICS ===';



-- Find the Total Sales
SELECT 
    'Total Sales Revenue' AS metric_name,
    SUM(sales_amount) AS metric_value,
    'Currency' AS unit
FROM gold.fact_sales;

-- Find how many items are sold
SELECT 
    'Total Quantity Sold' AS metric_name,
    SUM(quantity) AS metric_value,
    'Units' AS unit
FROM gold.fact_sales;

-- Find the average selling price
SELECT 
    'Average Selling Price' AS metric_name,
    AVG(price) AS metric_value,
    'Currency' AS unit
FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT 
    'Total Orders' AS metric_name,
    COUNT(order_number) AS metric_value,
    'Count' AS unit
FROM gold.fact_sales;

-- Find the Total number of Unique Orders
SELECT 
    'Total Unique Orders' AS metric_name,
    COUNT(DISTINCT order_number) AS metric_value,
    'Count' AS unit
FROM gold.fact_sales;

-- =============================================================================
-- Product Performance Metrics
-- =============================================================================
PRINT '=== PRODUCT PERFORMANCE METRICS ===';



-- Find the total number of products
SELECT 
    'Total Products' AS metric_name,
    COUNT(product_name) AS metric_value,
    'Count' AS unit
FROM gold.dim_products;

-- Find the total number of unique products
SELECT 
    'Total Unique Products' AS metric_name,
    COUNT(DISTINCT product_name) AS metric_value,
    'Count' AS unit
FROM gold.dim_products;

-- Average product cost
SELECT 
    'Average Product Cost' AS metric_name,
    AVG(cost) AS metric_value,
    'Currency' AS unit
FROM gold.dim_products
WHERE cost IS NOT NULL;

-- =============================================================================
-- Customer Performance Metrics
-- =============================================================================
PRINT '=== CUSTOMER PERFORMANCE METRICS ===';



-- Find the total number of customers
SELECT 
    'Total Customers' AS metric_name,
    COUNT(customer_key) AS metric_value,
    'Count' AS unit
FROM gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT 
    'Customers with Orders' AS metric_name,
    COUNT(DISTINCT customer_key) AS metric_value,
    'Count' AS unit
FROM gold.fact_sales;

-- Customer penetration rate
SELECT 
    'Customer Penetration Rate' AS metric_name,
    ROUND(
        (SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales) * 100.0 / 
        (SELECT COUNT(customer_key) FROM gold.dim_customers), 2
    ) AS metric_value,
    'Percentage' AS unit;

-- Average customer age
SELECT 
    'Average Customer Age' AS metric_name,
    AVG(DATEDIFF(YEAR, birthdate, GETDATE())) AS metric_value,
    'Years' AS unit
FROM gold.dim_customers
WHERE birthdate IS NOT NULL;

-- =============================================================================
-- Business Efficiency Metrics
-- =============================================================================
PRINT '=== BUSINESS EFFICIENCY METRICS ===';



-- Revenue per order
SELECT 
    'Revenue per Order' AS metric_name,
    ROUND(
        (SELECT SUM(sales_amount) FROM gold.fact_sales) * 1.0 / 
        (SELECT COUNT(DISTINCT order_number) FROM gold.fact_sales), 2
    ) AS metric_value,
    'Currency' AS unit;

-- Units per order
SELECT 
    'Units per Order' AS metric_name,
    ROUND(
        (SELECT SUM(quantity) FROM gold.fact_sales) * 1.0 / 
        (SELECT COUNT(DISTINCT order_number) FROM gold.fact_sales), 2
    ) AS metric_value,
    'Units' AS unit;

-- Sales per product
SELECT 
    'Sales per Product' AS metric_name,
    ROUND(
        (SELECT SUM(sales_amount) FROM gold.fact_sales) * 1.0 / 
        (SELECT COUNT(DISTINCT product_name) FROM gold.dim_products), 2
    ) AS metric_value,
    'Currency' AS unit;

-- Inventory turnover (approximation)
SELECT 
    'Inventory Turnover (Approx)' AS metric_name,
    ROUND(
        (SELECT SUM(quantity) FROM gold.fact_sales) * 1.0 / 
        (SELECT COUNT(DISTINCT product_name) FROM gold.dim_products), 2
    ) AS metric_value,
    'Times' AS unit;

-- =============================================================================
-- Comprehensive Business Report
-- =============================================================================
PRINT '=== COMPREHENSIVE BUSINESS REPORT ===';

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Customers with Orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales
UNION ALL
SELECT 'Revenue per Order', ROUND(SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number), 2) FROM gold.fact_sales
UNION ALL
SELECT 'Units per Order', ROUND(SUM(quantity) * 1.0 / COUNT(DISTINCT order_number), 2) FROM gold.fact_sales
UNION ALL
SELECT 'Sales per Product', ROUND(SUM(sales_amount) * 1.0 / (SELECT COUNT(DISTINCT product_name) FROM gold.dim_products), 2) FROM gold.fact_sales;

-- =============================================================================
-- Performance Analysis by Category
-- =============================================================================
PRINT '=== PERFORMANCE ANALYSIS BY CATEGORY ===';



-- =============================================================================
-- Geographic Performance Metrics
-- =============================================================================
PRINT '=== GEOGRAPHIC PERFORMANCE METRICS ===';



-- =============================================================================
-- Demographic Performance Metrics
-- =============================================================================
PRINT '=== DEMOGRAPHIC PERFORMANCE METRICS ===';



-- Sales performance by age group
SELECT *
FROM (
    SELECT 
        'Sales by Age Group' AS analysis_type,
        CASE 
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END AS age_group,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.sales_amount) AS total_sales,
        AVG(f.sales_amount) AS avg_order_value,
        COUNT(DISTINCT f.customer_key) AS unique_customers
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE c.birthdate IS NOT NULL
    GROUP BY 
        CASE 
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END
) t
ORDER BY t.total_sales DESC;

-- =============================================================================
-- Data Quality Metrics
-- =============================================================================
PRINT '=== DATA QUALITY METRICS ===';



-- Check for data completeness
SELECT 
    'Data Completeness Check' AS metric_name,
    'Sales with null values' AS check_type,
    COUNT(*) AS metric_value
FROM gold.fact_sales 
WHERE sales_amount IS NULL OR quantity IS NULL OR price IS NULL
UNION ALL
SELECT 
    'Data Completeness Check',
    'Customers with missing demographics',
    COUNT(*)
FROM gold.dim_customers 
WHERE gender IS NULL OR gender = 'n/a' OR birthdate IS NULL
UNION ALL
SELECT 
    'Data Completeness Check',
    'Products with missing information',
    COUNT(*)
FROM gold.dim_products 
WHERE category IS NULL OR cost IS NULL;

-- Check for data consistency
SELECT 
    'Data Consistency Check' AS metric_name,
    'Orders with zero or negative sales' AS check_type,
    COUNT(*) AS metric_value
FROM gold.fact_sales 
WHERE sales_amount <= 0
UNION ALL
SELECT 
    'Data Consistency Check',
    'Orders with zero or negative quantity',
    COUNT(*)
FROM gold.fact_sales 
WHERE quantity <= 0
UNION ALL
SELECT 
    'Data Consistency Check',
    'Products with zero or negative cost',
    COUNT(*)
FROM gold.dim_products 
WHERE cost <= 0;

PRINT 'Measures exploration completed successfully!'; 