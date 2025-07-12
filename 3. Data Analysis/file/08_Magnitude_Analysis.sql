/*
===============================================================================
08. Magnitude Analysis
===============================================================================
Script Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.
    - To identify patterns in data magnitude and distribution.
===============================================================================
*/

USE DataWarehouse;
GO




-- Find total customers by gender
SELECT
    'Customer Distribution by Gender' AS analysis_type,
    gender,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER (), 2) AS percentage
FROM gold.dim_customers
WHERE gender IS NOT NULL AND gender != 'n/a'
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total customers by marital status
SELECT
    'Customer Distribution by Marital Status' AS analysis_type,
    marital_status,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER (), 2) AS percentage
FROM gold.dim_customers
WHERE marital_status IS NOT NULL
GROUP BY marital_status
ORDER BY total_customers DESC;

-- Customer age distribution
SELECT *
FROM (
    SELECT
        'Customer Age Distribution' AS analysis_type,
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 20 THEN 'Under 20'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 20 AND 29 THEN '20-29'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 30 AND 39 THEN '30-39'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 40 AND 49 THEN '40-49'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 50 AND 59 THEN '50-59'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70 and above'
        END AS age_group,
        COUNT(customer_key) AS total_customers,
        ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER (), 2) AS percentage
    FROM gold.dim_customers
    WHERE birthdate IS NOT NULL
    GROUP BY 
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 20 THEN 'Under 20'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 20 AND 29 THEN '20-29'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 30 AND 39 THEN '30-39'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 40 AND 49 THEN '40-49'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 50 AND 59 THEN '50-59'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70 and above'
        END
) t
ORDER BY 
    CASE t.age_group
        WHEN 'Under 20' THEN 1
        WHEN '20-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        ELSE 7
    END;

-- Product cost distribution
SELECT *
FROM (
    SELECT
        'Product Cost Distribution' AS analysis_type,
        CASE 
            WHEN cost < 50 THEN 'Under $50'
            WHEN cost BETWEEN 50 AND 199 THEN '$50-$199'
            WHEN cost BETWEEN 200 AND 499 THEN '$200-$499'
            WHEN cost BETWEEN 500 AND 999 THEN '$500-$999'
            WHEN cost BETWEEN 1000 AND 1999 THEN '$1,000-$1,999'
            WHEN cost BETWEEN 2000 AND 4999 THEN '$2,000-$4,999'
            ELSE '$5,000 and above'
        END AS cost_range,
        COUNT(product_key) AS total_products,
        ROUND(COUNT(product_key) * 100.0 / SUM(COUNT(product_key)) OVER (), 2) AS percentage
    FROM gold.dim_products
    WHERE cost IS NOT NULL
    GROUP BY 
        CASE 
            WHEN cost < 50 THEN 'Under $50'
            WHEN cost BETWEEN 50 AND 199 THEN '$50-$199'
            WHEN cost BETWEEN 200 AND 499 THEN '$200-$499'
            WHEN cost BETWEEN 500 AND 999 THEN '$500-$999'
            WHEN cost BETWEEN 1000 AND 1999 THEN '$1,000-$1,999'
            WHEN cost BETWEEN 2000 AND 4999 THEN '$2,000-$4,999'
            ELSE '$5,000 and above'
        END
) t
ORDER BY 
    CASE t.cost_range
        WHEN 'Under $50' THEN 1
        WHEN '$50-$199' THEN 2
        WHEN '$200-$499' THEN 3
        WHEN '$500-$999' THEN 4
        WHEN '$1,000-$1,999' THEN 5
        WHEN '$2,000-$4,999' THEN 6
        ELSE 7
    END;

-- Sales by gender
SELECT
    'Sales Distribution by Gender' AS analysis_type,
    c.gender,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity,
    COUNT(DISTINCT f.order_number) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    ROUND(SUM(f.sales_amount) * 100.0 / SUM(SUM(f.sales_amount)) OVER (), 2) AS revenue_percentage
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.gender IS NOT NULL AND c.gender != 'n/a'
GROUP BY c.gender
ORDER BY total_revenue DESC;

-- Sales by age group
SELECT
    'Sales Distribution by Age Group' AS analysis_type,
    CASE 
        WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) < 25 THEN 'Under 25'
        WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65 and above'
    END AS age_group,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity,
    COUNT(DISTINCT f.order_number) AS total_orders,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    ROUND(SUM(f.sales_amount) * 100.0 / SUM(SUM(f.sales_amount)) OVER (), 2) AS revenue_percentage
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
ORDER BY total_revenue DESC;

-- What is the total revenue generated by each customer?
SELECT TOP 20
    'Top 20 Customers by Revenue' AS analysis_type,
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    AVG(f.sales_amount) AS avg_order_value,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_revenue DESC;

-- Customer value segments
SELECT *
FROM (
    SELECT
        'Customer Value Segments' AS analysis_type,
        CASE 
            WHEN SUM(f.sales_amount) >= 10000 THEN 'High Value ($10K+)'
            WHEN SUM(f.sales_amount) >= 5000 THEN 'Medium Value ($5K-$10K)'
            WHEN SUM(f.sales_amount) >= 1000 THEN 'Low Value ($1K-$5K)'
            ELSE 'Minimal Value (<$1K)'
        END AS value_segment,
        COUNT(DISTINCT c.customer_key) AS customer_count,
        ROUND(COUNT(DISTINCT c.customer_key) * 100.0 / SUM(COUNT(DISTINCT c.customer_key)) OVER (), 2) AS customer_percentage,
        SUM(f.sales_amount) AS total_revenue,
        ROUND(SUM(f.sales_amount) * 100.0 / SUM(SUM(f.sales_amount)) OVER (), 2) AS revenue_percentage
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
) t
ORDER BY 
    CASE t.value_segment
        WHEN 'High Value ($10K+)' THEN 1
        WHEN 'Medium Value ($5K-$10K)' THEN 2
        WHEN 'Low Value ($1K-$5K)' THEN 3
        ELSE 4
    END;




