/*
===============================================================================
09. Ranking Analysis
===============================================================================
Script Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.
    - To establish performance tiers and benchmarks.
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

-- Check if joins work
SELECT 'fact_sales + dim_products join' AS join_test, COUNT(*) AS row_count 
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key;

SELECT 'fact_sales + dim_customers join' AS join_test, COUNT(*) AS row_count 
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key;

-- =============================================================================
-- Product Ranking Analysis
-- =============================================================================
PRINT '=== PRODUCT RANKING ANALYSIS ===';



-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
    'Top 10 Customers by Revenue' AS analysis_type,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    AVG(f.sales_amount) AS avg_order_value,
    RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_revenue DESC;

-- Top customers by order frequency
SELECT TOP 10
    'Top 10 Customers by Order Frequency' AS analysis_type,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_order_value,
    RANK() OVER (ORDER BY COUNT(DISTINCT f.order_number) DESC) AS order_rank
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_orders DESC;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    'Bottom 3 Customers by Order Frequency' AS analysis_type,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    AVG(f.sales_amount) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_orders;

-- =============================================================================
-- Category Ranking Analysis
-- =============================================================================
PRINT '=== CATEGORY RANKING ANALYSIS ===';



-- Top performing months by revenue
SELECT
    'Months by Revenue Performance' AS analysis_type,
    MONTH(f.order_date) AS month_number,
    DATENAME(month, f.order_date) AS month_name,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY MONTH(f.order_date), DATENAME(month, f.order_date)
ORDER BY total_revenue DESC;

-- Top performing years by revenue
SELECT
    'Years by Revenue Performance' AS analysis_type,
    YEAR(f.order_date) AS order_year,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date)
ORDER BY total_revenue DESC;

-- Customer value tiers
SELECT *
FROM (
    SELECT
        'Customer Value Tiers' AS analysis_type,
        CASE 
            WHEN SUM(f.sales_amount) >= 15000 THEN 'VIP (>$15K)'
            WHEN SUM(f.sales_amount) >= 10000 THEN 'Premium ($10K-$15K)'
            WHEN SUM(f.sales_amount) >= 5000 THEN 'Regular ($5K-$10K)'
            WHEN SUM(f.sales_amount) >= 1000 THEN 'Standard ($1K-$5K)'
            ELSE 'Basic (<$1K)'
        END AS value_tier,
        COUNT(DISTINCT c.customer_key) AS customer_count,
        SUM(f.sales_amount) AS total_revenue,
        ROUND(COUNT(DISTINCT c.customer_key) * 100.0 / SUM(COUNT(DISTINCT c.customer_key)) OVER (), 2) AS customer_percentage,
        ROUND(SUM(f.sales_amount) * 100.0 / SUM(SUM(f.sales_amount)) OVER (), 2) AS revenue_percentage
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
) t
ORDER BY 
    CASE t.value_tier
        WHEN 'VIP (>$15K)' THEN 1
        WHEN 'Premium ($10K-$15K)' THEN 2
        WHEN 'Regular ($5K-$10K)' THEN 3
        WHEN 'Standard ($1K-$5K)' THEN 4
        ELSE 5
    END;

