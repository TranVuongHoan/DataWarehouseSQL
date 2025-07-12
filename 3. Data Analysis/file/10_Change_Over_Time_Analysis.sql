/*
===============================================================================
10. Change Over Time Analysis
===============================================================================
Script Purpose:
    - To analyze sales performance over time.
    - To identify trends, seasonality, and growth patterns.
    - To measure performance changes across different time periods.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Sales Performance Over Time
-- =============================================================================
PRINT '=== SALES PERFORMANCE OVER TIME ===';

-- Analyse sales performance over time by month
SELECT *
FROM (
    SELECT
        'Sales Performance by Month' AS analysis_type,
        FORMAT(order_date, 'yyyy-MMM') AS order_period,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT order_number) AS total_orders,
        AVG(sales_amount) AS avg_order_value,
        ROUND(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER (), 2) AS sales_percentage
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MMM')
) t
ORDER BY t.order_period;

-- Sales performance by year
SELECT
    'Sales Performance by Year' AS analysis_type,
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_number) AS total_orders,
    AVG(sales_amount) AS avg_order_value,
    ROUND(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER (), 2) AS sales_percentage
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Sales performance by quarter
SELECT
    'Sales Performance by Quarter' AS analysis_type,
    YEAR(order_date) AS order_year,
    DATEPART(quarter, order_date) AS quarter,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_number) AS total_orders,
    AVG(sales_amount) AS avg_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), DATEPART(quarter, order_date)
ORDER BY order_year, quarter;

-- =============================================================================
-- Year-over-Year Growth Analysis
-- =============================================================================
PRINT '=== YEAR-OVER-YEAR GROWTH ANALYSIS ===';

-- Year-over-year growth in sales
WITH yearly_sales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        AVG(sales_amount) AS avg_order_value
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    'Year-over-Year Growth' AS analysis_type,
    order_year,
    total_sales,
    total_orders,
    unique_customers,
    avg_order_value,
    LAG(total_sales) OVER (ORDER BY order_year) AS prev_year_sales,
    LAG(total_orders) OVER (ORDER BY order_year) AS prev_year_orders,
    LAG(unique_customers) OVER (ORDER BY order_year) AS prev_year_customers,
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY order_year) > 0 
        THEN ROUND((total_sales - LAG(total_sales) OVER (ORDER BY order_year)) * 100.0 / LAG(total_sales) OVER (ORDER BY order_year), 2)
        ELSE NULL 
    END AS sales_growth_percentage,
    CASE 
        WHEN LAG(total_orders) OVER (ORDER BY order_year) > 0 
        THEN ROUND((total_orders - LAG(total_orders) OVER (ORDER BY order_year)) * 100.0 / LAG(total_orders) OVER (ORDER BY order_year), 2)
        ELSE NULL 
    END AS orders_growth_percentage,
    CASE 
        WHEN LAG(unique_customers) OVER (ORDER BY order_year) > 0 
        THEN ROUND((unique_customers - LAG(unique_customers) OVER (ORDER BY order_year)) * 100.0 / LAG(unique_customers) OVER (ORDER BY order_year), 2)
        ELSE NULL 
    END AS customers_growth_percentage
FROM yearly_sales
ORDER BY order_year;

-- =============================================================================
-- Monthly Trends Analysis
-- =============================================================================
PRINT '=== MONTHLY TRENDS ANALYSIS ===';

-- Monthly trends across all years
SELECT *
FROM (
    SELECT
        'Monthly Trends' AS analysis_type,
        MONTH(order_date) AS month_number,
        DATENAME(month, order_date) AS month_name,
        COUNT(*) AS total_orders,
        SUM(sales_amount) AS total_sales,
        AVG(sales_amount) AS avg_order_value,
        COUNT(DISTINCT customer_key) AS unique_customers,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_percentage,
        ROUND(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER (), 2) AS sales_percentage
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date), DATENAME(month, order_date)
) t
ORDER BY t.month_number;

-- Monthly performance by year
SELECT
    'Monthly Performance by Year' AS analysis_type,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS month_number,
    DATENAME(month, order_date) AS month_name,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS unique_customers,
    AVG(sales_amount) AS avg_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date), DATENAME(month, order_date)
ORDER BY order_year, month_number;

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
        COUNT(DISTINCT customer_key) AS unique_customers,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_percentage,
        ROUND(SUM(sales_amount) * 100.0 / SUM(SUM(sales_amount)) OVER (), 2) AS sales_percentage
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

-- Seasonal trends by year
SELECT *
FROM (
    SELECT
        'Seasonal Trends by Year' AS analysis_type,
        YEAR(order_date) AS order_year,
        CASE 
            WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
        END AS season,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY 
        YEAR(order_date),
        CASE 
            WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(order_date) IN (9, 10, 11) THEN 'Fall'
        END
) t
ORDER BY t.order_year, t.season;

-- Customer acquisition over time
SELECT
    'Customer Acquisition Over Time' AS analysis_type,
    YEAR(c.create_date) AS creation_year,
    MONTH(c.create_date) AS creation_month,
    DATENAME(month, c.create_date) AS month_name,
    COUNT(c.customer_key) AS new_customers,
    SUM(COUNT(c.customer_key)) OVER (ORDER BY YEAR(c.create_date), MONTH(c.create_date)) AS cumulative_customers
FROM gold.dim_customers c
WHERE c.create_date IS NOT NULL
GROUP BY YEAR(c.create_date), MONTH(c.create_date), DATENAME(month, c.create_date)
ORDER BY creation_year, creation_month;

-- Customer purchasing behavior over time
SELECT
    'Customer Purchasing Behavior Over Time' AS analysis_type,
    YEAR(f.order_date) AS order_year,
    COUNT(DISTINCT f.customer_key) AS active_customers,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_sales,
    AVG(f.sales_amount) AS avg_order_value,
    ROUND(COUNT(DISTINCT f.order_number) * 1.0 / COUNT(DISTINCT f.customer_key), 2) AS orders_per_customer
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date)
ORDER BY order_year;

-- =============================================================================
-- Moving Averages and Trends
-- =============================================================================
PRINT '=== MOVING AVERAGES AND TRENDS ===';

-- 3-month moving average of sales
WITH monthly_sales AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)
SELECT
    '3-Month Moving Average' AS analysis_type,
    order_month,
    total_sales,
    total_orders,
    AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS sales_3month_avg,
    AVG(total_orders) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS orders_3month_avg
FROM monthly_sales
ORDER BY order_month;

-- =============================================================================
-- Performance Comparison Analysis
-- =============================================================================
PRINT '=== PERFORMANCE COMPARISON ANALYSIS ===';

-- Compare performance between different time periods
SELECT
    'Performance Comparison' AS analysis_type,
    'First Half' AS period,
    SUM(CASE WHEN MONTH(order_date) BETWEEN 1 AND 6 THEN sales_amount ELSE 0 END) AS total_sales,
    COUNT(CASE WHEN MONTH(order_date) BETWEEN 1 AND 6 THEN order_number END) AS total_orders,
    AVG(CASE WHEN MONTH(order_date) BETWEEN 1 AND 6 THEN sales_amount END) AS avg_order_value
FROM gold.fact_sales
WHERE order_date IS NOT NULL
UNION ALL
SELECT
    'Performance Comparison',
    'Second Half',
    SUM(CASE WHEN MONTH(order_date) BETWEEN 7 AND 12 THEN sales_amount ELSE 0 END),
    COUNT(CASE WHEN MONTH(order_date) BETWEEN 7 AND 12 THEN order_number END),
    AVG(CASE WHEN MONTH(order_date) BETWEEN 7 AND 12 THEN sales_amount END)
FROM gold.fact_sales
WHERE order_date IS NOT NULL;

-- Weekday vs Weekend performance
SELECT
    'Weekday vs Weekend Performance' AS analysis_type,
    CASE 
        WHEN DATEPART(weekday, order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders,
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_order_value,
    COUNT(DISTINCT customer_key) AS unique_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEPART(weekday, order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END;

PRINT 'Change over time analysis completed successfully!'; 