/*
===============================================================================
04. Database Exploration
===============================================================================
Script Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.
    - To understand data distribution and quality.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Database Structure Overview
-- =============================================================================
PRINT '=== DATABASE STRUCTURE OVERVIEW ===';

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- =============================================================================
-- Schema Information
-- =============================================================================
PRINT '=== SCHEMA INFORMATION ===';

-- Count tables by schema
SELECT 
    TABLE_SCHEMA,
    COUNT(*) AS table_count,
    STRING_AGG(TABLE_NAME, ', ') AS table_names
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
GROUP BY TABLE_SCHEMA
ORDER BY TABLE_SCHEMA;

-- =============================================================================
-- Table Structure Analysis
-- =============================================================================
PRINT '=== TABLE STRUCTURE ANALYSIS ===';

-- Detailed column information for all tables
SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    c.COLUMN_NAME, 
    c.DATA_TYPE, 
    c.IS_NULLABLE, 
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE
FROM INFORMATION_SCHEMA.TABLES t
JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_NAME = c.TABLE_NAME 
    AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME, c.ORDINAL_POSITION;

-- =============================================================================
-- Bronze Layer Analysis
-- =============================================================================
PRINT '=== BRONZE LAYER ANALYSIS ===';

-- Bronze layer record counts
SELECT 'bronze.crm_cust_info' AS table_name, COUNT(*) AS record_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'bronze.crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'bronze.crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'bronze.erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'bronze.erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'bronze.erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;

-- =============================================================================
-- Silver Layer Analysis
-- =============================================================================
PRINT '=== SILVER LAYER ANALYSIS ===';

-- Silver layer record counts
SELECT 'silver.crm_cust_info' AS table_name, COUNT(*) AS record_count FROM silver.crm_cust_info
UNION ALL
SELECT 'silver.crm_prd_info', COUNT(*) FROM silver.crm_prd_info
UNION ALL
SELECT 'silver.crm_sales_details', COUNT(*) FROM silver.crm_sales_details
UNION ALL
SELECT 'silver.erp_loc_a101', COUNT(*) FROM silver.erp_loc_a101
UNION ALL
SELECT 'silver.erp_cust_az12', COUNT(*) FROM silver.erp_cust_az12
UNION ALL
SELECT 'silver.erp_px_cat_g1v2', COUNT(*) FROM silver.erp_px_cat_g1v2;

-- =============================================================================
-- Gold Layer Analysis
-- =============================================================================
PRINT '=== GOLD LAYER ANALYSIS ===';

-- Gold layer record counts
SELECT 'gold.dim_customers' AS view_name, COUNT(*) AS record_count FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT(*) FROM gold.fact_sales;

-- =============================================================================
-- Data Quality Analysis
-- =============================================================================
PRINT '=== DATA QUALITY ANALYSIS ===';

-- Check for null values in key fields
SELECT 'silver.crm_cust_info - null cst_id' AS issue, COUNT(*) AS count 
FROM silver.crm_cust_info WHERE cst_id IS NULL
UNION ALL
SELECT 'silver.crm_prd_info - null prd_id', COUNT(*) 
FROM silver.crm_prd_info WHERE prd_id IS NULL
UNION ALL
SELECT 'silver.crm_sales_details - null sls_ord_num', COUNT(*) 
FROM silver.crm_sales_details WHERE sls_ord_num IS NULL
UNION ALL
SELECT 'silver.erp_loc_a101 - null cid', COUNT(*) 
FROM silver.erp_loc_a101 WHERE cid IS NULL
UNION ALL
SELECT 'silver.erp_cust_az12 - null cid', COUNT(*) 
FROM silver.erp_cust_az12 WHERE cid IS NULL;

-- =============================================================================
-- Data Distribution Analysis
-- =============================================================================
PRINT '=== DATA DISTRIBUTION ANALYSIS ===';

-- Customer data distribution
SELECT 
    'Customer Gender Distribution' AS analysis_type,
    cst_gndr AS category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM silver.crm_cust_info
GROUP BY cst_gndr
ORDER BY count DESC;

-- Product category distribution
SELECT 
    'Product Category Distribution' AS analysis_type,
    cat AS category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM silver.erp_px_cat_g1v2
GROUP BY cat
ORDER BY count DESC;

-- Country distribution
SELECT 
    'Customer Country Distribution' AS analysis_type,
    cntry AS category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM silver.erp_loc_a101
GROUP BY cntry
ORDER BY count DESC;

-- Customer creation date range
SELECT 
    'Customer Creation Date Range' AS analysis_type,
    MIN(cst_create_date) AS min_date,
    MAX(cst_create_date) AS max_date,
    COUNT(*) AS total_records
FROM silver.crm_cust_info
WHERE cst_create_date IS NOT NULL;

-- Product start date range
SELECT 
    'Product Start Date Range' AS analysis_type,
    MIN(prd_start_dt) AS min_date,
    MAX(prd_start_dt) AS max_date,
    COUNT(*) AS total_records
FROM silver.crm_prd_info
WHERE prd_start_dt IS NOT NULL;

