/*
===============================================================================
Diagnostic Check: Data Pipeline Verification
===============================================================================
Script Purpose:
    This script checks the data flow from Bronze -> Silver -> Gold layers
    to identify where the data pipeline is breaking.
===============================================================================
*/

USE DataWarehouse;
GO

PRINT '=== DIAGNOSTIC CHECK: DATA PIPELINE VERIFICATION ===';

-- =============================================================================
-- Check Bronze Layer Data
-- =============================================================================
PRINT '=== BRONZE LAYER CHECK ===';

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

-- Check sample data from bronze
PRINT 'Sample data from bronze.crm_sales_details:';
SELECT TOP 5 * FROM bronze.crm_sales_details;

PRINT 'Sample data from bronze.crm_cust_info:';
SELECT TOP 5 * FROM bronze.crm_cust_info;

PRINT 'Sample data from bronze.crm_prd_info:';
SELECT TOP 5 * FROM bronze.crm_prd_info;

-- =============================================================================
-- Check Silver Layer Data
-- =============================================================================
PRINT '=== SILVER LAYER CHECK ===';

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

-- Check sample data from silver
PRINT 'Sample data from silver.crm_sales_details:';
SELECT TOP 5 * FROM silver.crm_sales_details;

PRINT 'Sample data from silver.crm_cust_info:';
SELECT TOP 5 * FROM silver.crm_cust_info;

PRINT 'Sample data from silver.crm_prd_info:';
SELECT TOP 5 * FROM silver.crm_prd_info;

-- =============================================================================
-- Check Gold Layer Data
-- =============================================================================
PRINT '=== GOLD LAYER CHECK ===';

-- Check dimension tables
SELECT 'gold.dim_customers' AS table_name, COUNT(*) AS record_count FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT(*) FROM gold.dim_products;

-- Check fact table
SELECT 'gold.fact_sales' AS table_name, COUNT(*) AS record_count FROM gold.fact_sales;

-- Check sample data from gold
PRINT 'Sample data from gold.dim_customers:';
SELECT TOP 5 * FROM gold.dim_customers;

PRINT 'Sample data from gold.dim_products:';
SELECT TOP 5 * FROM gold.dim_products;

PRINT 'Sample data from gold.fact_sales:';
SELECT TOP 5 * FROM gold.fact_sales;

-- =============================================================================
-- Check Join Relationships
-- =============================================================================
PRINT '=== JOIN RELATIONSHIP CHECK ===';

-- Check if sales details can join with products
PRINT 'Sales details that can join with products:';
SELECT COUNT(*) AS joinable_sales
FROM silver.crm_sales_details sd
LEFT JOIN silver.crm_prd_info pi ON sd.sls_prd_key = pi.prd_key
WHERE pi.prd_key IS NOT NULL;

-- Check if sales details can join with customers
PRINT 'Sales details that can join with customers:';
SELECT COUNT(*) AS joinable_sales
FROM silver.crm_sales_details sd
LEFT JOIN silver.crm_cust_info ci ON sd.sls_cust_id = ci.cst_id
WHERE ci.cst_id IS NOT NULL;

-- Check the actual join keys
PRINT 'Sample join keys from sales details:';
SELECT TOP 10 sls_prd_key, sls_cust_id FROM silver.crm_sales_details;

PRINT 'Sample product keys:';
SELECT TOP 10 prd_key FROM silver.crm_prd_info;

PRINT 'Sample customer IDs:';
SELECT TOP 10 cst_id FROM silver.crm_cust_info;

PRINT 'Diagnostic check completed!'; 