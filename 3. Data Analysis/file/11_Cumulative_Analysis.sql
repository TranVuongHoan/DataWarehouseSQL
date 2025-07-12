/*
===============================================================================
11. Cumulative Analysis
===============================================================================
Script Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.
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

-- =============================================================================
-- Cumulative Sales Analysis
-- =============================================================================
PRINT '=== CUMULATIVE SALES ANALYSIS ===';

-- Debug: Check if there's data in fact_sales
PRINT 'Checking data in fact_sales table...';
SELECT COUNT(*) AS total_rows, 
       COUNT(order_date) AS rows_with_order_date,
       MIN(order_date) AS min_order_date,
       MAX(order_date) AS max_order_date
FROM gold.fact_sales;

-- Calculate the total sales per month and the running total of sales over time
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        AVG(sales_amount) AS avg_order_value
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    'Cumulative Sales Analysis' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    unique_customers,
    avg_order_value,
    SUM(total_sales) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS running_total_sales,
    SUM(total_orders) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS running_total_orders,
    SUM(unique_customers) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS running_total_customers,
    AVG(avg_order_value) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS moving_average_order_value
FROM monthly_sales
ORDER BY order_month_num;

-- Cumulative sales by year
PRINT 'Debug: Testing yearly sales query...';
SELECT COUNT(*) AS yearly_sales_count
FROM (
    SELECT YEAR(order_date) AS order_year
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
) test;

WITH yearly_sales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT *
FROM (
    SELECT
        'Cumulative Sales by Year' AS analysis_type,
        order_year,
        total_sales,
        total_orders,
        unique_customers,
        SUM(total_sales) OVER (ORDER BY order_year) AS cumulative_sales,
        SUM(total_orders) OVER (ORDER BY order_year) AS cumulative_orders,
        SUM(unique_customers) OVER (ORDER BY order_year) AS cumulative_customers,
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS yearly_contribution_percentage
    FROM yearly_sales
) t
ORDER BY t.order_year;

-- =============================================================================
-- Moving Averages Analysis
-- =============================================================================
PRINT '=== MOVING AVERAGES ANALYSIS ===';

-- 3-month moving average of sales
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        AVG(sales_amount) AS avg_order_value
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    '3-Month Moving Averages' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    avg_order_value,
    AVG(total_sales) OVER (ORDER BY order_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS sales_3month_avg,
    AVG(total_orders) OVER (ORDER BY order_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS orders_3month_avg,
    AVG(avg_order_value) OVER (ORDER BY order_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_order_value_3month_avg
FROM monthly_sales
ORDER BY order_month_num;

-- 6-month moving average of sales
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    '6-Month Moving Averages' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    AVG(total_sales) OVER (ORDER BY order_month_num ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS sales_6month_avg,
    AVG(total_orders) OVER (ORDER BY order_month_num ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS orders_6month_avg
FROM monthly_sales
ORDER BY order_month_num;

-- =============================================================================
-- Cumulative Customer Analysis
-- =============================================================================
PRINT '=== CUMULATIVE CUSTOMER ANALYSIS ===';

-- Debug: Check if there's data in dim_customers
PRINT 'Checking data in dim_customers table...';
SELECT COUNT(*) AS total_customers, 
       COUNT(create_date) AS customers_with_create_date,
       MIN(create_date) AS min_create_date,
       MAX(create_date) AS max_create_date
FROM gold.dim_customers;

-- Cumulative customer acquisition
PRINT 'Debug: Testing customer acquisition query...';
SELECT COUNT(*) AS customer_acquisition_count
FROM (
    SELECT FORMAT(create_date, 'yyyy-MM') AS creation_month
    FROM gold.dim_customers
    WHERE create_date IS NOT NULL
    GROUP BY FORMAT(create_date, 'yyyy-MM')
) test;

WITH customer_acquisition AS (
    SELECT 
        FORMAT(create_date, 'yyyy-MM') AS creation_month,
        YEAR(create_date) * 100 + MONTH(create_date) AS creation_month_num,
        COUNT(customer_key) AS new_customers
    FROM gold.dim_customers
    WHERE create_date IS NOT NULL
    GROUP BY FORMAT(create_date, 'yyyy-MM'), YEAR(create_date) * 100 + MONTH(create_date)
)
SELECT
    'Cumulative Customer Acquisition' AS analysis_type,
    creation_month,
    new_customers,
    SUM(new_customers) OVER (ORDER BY creation_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_customers,
    AVG(new_customers) OVER (ORDER BY creation_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_new_customers_3month
FROM customer_acquisition
ORDER BY creation_month_num;

-- Cumulative active customers over time
PRINT 'Debug: Testing monthly active customers query...';
SELECT COUNT(*) AS monthly_active_customers_count
FROM (
    SELECT FORMAT(order_date, 'yyyy-MM') AS order_month
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
) test;

WITH monthly_active_customers AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        COUNT(DISTINCT customer_key) AS active_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    'Cumulative Active Customers' AS analysis_type,
    order_month,
    active_customers,
    SUM(active_customers) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_active_customers,
    AVG(active_customers) OVER (ORDER BY order_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_active_customers_3month
FROM monthly_active_customers
ORDER BY order_month_num;

-- =============================================================================
-- Cumulative Product Performance
-- =============================================================================
PRINT '=== CUMULATIVE PRODUCT PERFORMANCE ===';

-- Debug: Check if there's data in dim_products and join works
PRINT 'Checking data in dim_products table...';
SELECT COUNT(*) AS total_products, 
       COUNT(category) AS products_with_category
FROM gold.dim_products;

PRINT 'Checking join between fact_sales and dim_products...';
SELECT COUNT(*) AS joined_rows
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL AND p.category IS NOT NULL;

-- Debug: Test monthly sales for growth analysis
PRINT 'Debug: Testing monthly sales for growth analysis...';
SELECT COUNT(*) AS monthly_sales_for_growth_count
FROM (
    SELECT FORMAT(order_date, 'yyyy-MM') AS order_month
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
) test;

-- Month-over-month growth rates
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    'Month-over-Month Growth' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    LAG(total_sales) OVER (ORDER BY order_month_num) AS prev_month_sales,
    LAG(total_orders) OVER (ORDER BY order_month_num) AS prev_month_orders,
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY order_month_num) > 0 
        THEN ROUND((total_sales - LAG(total_sales) OVER (ORDER BY order_month_num)) * 100.0 / LAG(total_sales) OVER (ORDER BY order_month_num), 2)
        ELSE NULL 
    END AS sales_growth_percentage,
    CASE 
        WHEN LAG(total_orders) OVER (ORDER BY order_month_num) > 0 
        THEN ROUND((total_orders - LAG(total_orders) OVER (ORDER BY order_month_num)) * 100.0 / LAG(total_orders) OVER (ORDER BY order_month_num), 2)
        ELSE NULL 
    END AS orders_growth_percentage
FROM monthly_sales
ORDER BY order_month_num;

-- =============================================================================
-- Cumulative Revenue Analysis
-- =============================================================================
PRINT '=== CUMULATIVE REVENUE ANALYSIS ===';

-- Debug: Test customer revenue join
PRINT 'Debug: Testing customer revenue join...';
SELECT COUNT(*) AS customer_revenue_count
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key;

-- Cumulative revenue by customer
WITH customer_revenue AS (
    SELECT 
        c.customer_key,
        c.first_name,
        c.last_name,
        c.country,
        SUM(f.sales_amount) AS total_revenue,
        COUNT(DISTINCT f.order_number) AS total_orders,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name, c.country
)
SELECT TOP 20
    'Top 20 Customers by Cumulative Revenue' AS analysis_type,
    customer_key,
    first_name,
    last_name,
    country,
    total_revenue,
    total_orders,
    first_order_date,
    last_order_date,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_percentage
FROM customer_revenue
ORDER BY total_revenue DESC;

-- =============================================================================
-- Cumulative Performance Metrics
-- =============================================================================
PRINT '=== CUMULATIVE PERFORMANCE METRICS ===';

-- Debug: Test performance summary query
PRINT 'Debug: Testing performance summary query...';
SELECT COUNT(*) AS performance_summary_count
FROM (
    SELECT FORMAT(order_date, 'yyyy-MM') AS order_month
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
) test;

-- Cumulative performance summary
WITH performance_summary AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        SUM(quantity) AS total_quantity,
        AVG(sales_amount) AS avg_order_value
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    'Cumulative Performance Summary' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    unique_customers,
    total_quantity,
    avg_order_value,
    SUM(total_sales) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_sales,
    SUM(total_orders) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_orders,
    SUM(total_quantity) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_quantity,
    AVG(avg_order_value) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS moving_avg_order_value,
    ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS monthly_contribution_percentage
FROM performance_summary
ORDER BY order_month_num;

-- =============================================================================
-- Trend Analysis with Cumulative Metrics
-- =============================================================================
PRINT '=== TREND ANALYSIS WITH CUMULATIVE METRICS ===';

-- Debug: Test sales trend query
PRINT 'Debug: Testing sales trend query...';
SELECT COUNT(*) AS sales_trend_count
FROM (
    SELECT FORMAT(order_date, 'yyyy-MM') AS order_month
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
) test;

-- Sales trend with cumulative totals
WITH sales_trend AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        YEAR(order_date) * 100 + MONTH(order_date) AS order_month_num,
        SUM(sales_amount) AS monthly_sales,
        COUNT(DISTINCT order_number) AS monthly_orders,
        COUNT(DISTINCT customer_key) AS monthly_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date) * 100 + MONTH(order_date)
)
SELECT
    'Sales Trend with Cumulative Metrics' AS analysis_type,
    order_month,
    monthly_sales,
    monthly_orders,
    monthly_customers,
    SUM(monthly_sales) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_sales,
    SUM(monthly_orders) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_orders,
    SUM(monthly_customers) OVER (ORDER BY order_month_num ROWS UNBOUNDED PRECEDING) AS cumulative_customers,
    AVG(monthly_sales) OVER (ORDER BY order_month_num ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS sales_3month_avg,
    CASE 
        WHEN LAG(monthly_sales) OVER (ORDER BY order_month_num) > 0 
        THEN ROUND((monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_month_num)) * 100.0 / LAG(monthly_sales) OVER (ORDER BY order_month_num), 2)
        ELSE NULL 
    END AS month_over_month_growth
FROM sales_trend
ORDER BY order_month_num;

PRINT 'Cumulative analysis completed successfully!'; 