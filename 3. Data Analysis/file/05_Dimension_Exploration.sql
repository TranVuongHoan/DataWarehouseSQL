/*
===============================================================================
05. Dimension Exploration
===============================================================================
Script Purpose:
    - To explore the structure of dimension tables.
    - To understand customer demographics and product characteristics.
    - To identify patterns and distributions in dimensional data.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================

-- Customer gender distribution
SELECT 
    'Customer Gender Distribution' AS analysis_type,
    gender,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM gold.dim_customers
WHERE gender IS NOT NULL AND gender != 'n/a'
GROUP BY gender
ORDER BY customer_count DESC;

-- Customer marital status distribution
SELECT 
    'Customer Marital Status Distribution' AS analysis_type,
    marital_status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM gold.dim_customers
WHERE marital_status IS NOT NULL
GROUP BY marital_status
ORDER BY customer_count DESC;

-- Customer age analysis
SELECT 
    'Customer Age Analysis' AS analysis_type,
    MIN(DATEDIFF(YEAR, birthdate, GETDATE())) AS min_age,
    MAX(DATEDIFF(YEAR, birthdate, GETDATE())) AS max_age,
    AVG(DATEDIFF(YEAR, birthdate, GETDATE())) AS avg_age,
    COUNT(*) AS total_customers
FROM gold.dim_customers
WHERE birthdate IS NOT NULL;

-- Customer age groups
SELECT *
FROM (
    SELECT 
        'Customer Age Groups' AS analysis_type,
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END AS age_group,
        COUNT(*) AS customer_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
    FROM gold.dim_customers
    WHERE birthdate IS NOT NULL
    GROUP BY 
        CASE 
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 25 THEN 'Under 25'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
            WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65 and above'
        END
) t
ORDER BY 
    CASE t.age_group
        WHEN 'Under 25' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        WHEN '55-64' THEN 5
        ELSE 6
    END;

-- Customer creation date analysis
SELECT 
    'Customer Creation Analysis' AS analysis_type,
    YEAR(create_date) AS creation_year,
    COUNT(*) AS new_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM gold.dim_customers
WHERE create_date IS NOT NULL
GROUP BY YEAR(create_date)
ORDER BY creation_year;

-- =============================================================================

-- Product line distribution
SELECT 
    'Product Line Distribution' AS analysis_type,
    product_line,
    COUNT(*) AS product_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM gold.dim_products
WHERE product_line IS NOT NULL
GROUP BY product_line
ORDER BY product_count DESC;

-- Product cost analysis
SELECT 
    'Product Cost Analysis' AS analysis_type,
    MIN(cost) AS min_cost,
    MAX(cost) AS max_cost,
    AVG(cost) AS avg_cost,
    COUNT(*) AS total_products
FROM gold.dim_products
WHERE cost IS NOT NULL;

-- Product cost ranges
SELECT *
FROM (
    SELECT 
        'Product Cost Ranges' AS analysis_type,
        CASE 
            WHEN cost < 50 THEN 'Under $50'
            WHEN cost BETWEEN 50 AND 199 THEN '$50-$199'
            WHEN cost BETWEEN 200 AND 499 THEN '$200-$499'
            WHEN cost BETWEEN 500 AND 999 THEN '$500-$999'
            WHEN cost BETWEEN 1000 AND 1999 THEN '$1,000-$1,999'
            ELSE '$2,000 and above'
        END AS cost_range,
        COUNT(*) AS product_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
    FROM gold.dim_products
    WHERE cost IS NOT NULL
    GROUP BY 
        CASE 
            WHEN cost < 50 THEN 'Under $50'
            WHEN cost BETWEEN 50 AND 199 THEN '$50-$199'
            WHEN cost BETWEEN 200 AND 499 THEN '$200-$499'
            WHEN cost BETWEEN 500 AND 999 THEN '$500-$999'
            WHEN cost BETWEEN 1000 AND 1999 THEN '$1,000-$1,999'
            ELSE '$2,000 and above'
        END
) t
ORDER BY 
    CASE t.cost_range
        WHEN 'Under $50' THEN 1
        WHEN '$50-$199' THEN 2
        WHEN '$200-$499' THEN 3
        WHEN '$500-$999' THEN 4
        WHEN '$1,000-$1,999' THEN 5
        ELSE 6
    END;

-- Product start date analysis
SELECT 
    'Product Start Date Analysis' AS analysis_type,
    YEAR(start_date) AS start_year,
    COUNT(*) AS new_products,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM gold.dim_products
WHERE start_date IS NOT NULL
GROUP BY YEAR(start_date)
ORDER BY start_year;
-- =============================================================================

-- Check for missing values in customer dimension
SELECT 
    'Customer Dimension - Missing Values' AS check_type,
    'country' AS field_name,
    COUNT(*) AS missing_count
FROM gold.dim_customers 
WHERE country IS NULL OR country = ''
UNION ALL
SELECT 
    'Customer Dimension - Missing Values',
    'gender',
    COUNT(*)
FROM gold.dim_customers 
WHERE gender IS NULL OR gender = '' OR gender = 'n/a'
UNION ALL
SELECT 
    'Customer Dimension - Missing Values',
    'birthdate',
    COUNT(*)
FROM gold.dim_customers 
WHERE birthdate IS NULL;

-- Check for missing values in product dimension
SELECT 
    'Product Dimension - Missing Values' AS check_type,
    'category' AS field_name,
    COUNT(*) AS missing_count
FROM gold.dim_products 
WHERE category IS NULL OR category = ''
UNION ALL
SELECT 
    'Product Dimension - Missing Values',
    'cost',
    COUNT(*)
FROM gold.dim_products 
WHERE cost IS NULL
UNION ALL
SELECT 
    'Product Dimension - Missing Values',
    'maintenance',
    COUNT(*)
FROM gold.dim_products 
WHERE maintenance IS NULL OR maintenance = '';

-- Check for data consistency
SELECT 
    'Data Consistency Check' AS check_type,
    'Unique customer keys' AS metric,
    COUNT(DISTINCT customer_key) AS count
FROM gold.dim_customers
UNION ALL
SELECT 
    'Data Consistency Check',
    'Total customer records',
    COUNT(*)
FROM gold.dim_customers
UNION ALL
SELECT 
    'Data Consistency Check',
    'Unique product keys',
    COUNT(DISTINCT product_key)
FROM gold.dim_products
UNION ALL
SELECT 
    'Data Consistency Check',
    'Total product records',
    COUNT(*)
FROM gold.dim_products;

PRINT 'Dimension exploration completed successfully!'; 