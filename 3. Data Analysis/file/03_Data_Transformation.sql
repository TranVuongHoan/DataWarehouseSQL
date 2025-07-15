/*
===============================================================================
03. Data Transformation
===============================================================================
Script Purpose:
    This script transforms data from the bronze layer to the silver layer.
    It performs data cleaning, standardization, and basic transformations.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Transform Customer Information (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming customer information...';

-- Clear existing data
TRUNCATE TABLE silver.crm_cust_info;

-- Transform and load customer data
INSERT INTO silver.crm_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname, 
    cst_marital_status, cst_gndr, cst_create_date
)
SELECT 
    cst_id,
    TRIM(cst_key) AS cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    TRIM(cst_marital_status) AS cst_marital_status,
    TRIM(cst_gndr) AS cst_gndr,
    cst_create_date
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL;
GO

-- =============================================================================
-- Transform Product Information (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming product information...';

-- Clear existing data
TRUNCATE TABLE silver.crm_prd_info;

-- Transform and load product data
INSERT INTO silver.crm_prd_info (
    prd_id, cat_id, prd_key, prd_nm, prd_cost, 
    prd_line, prd_start_dt, prd_end_dt
)
SELECT 
    prd_id,
    -- Extract category ID from product key (first 2 characters before underscore)
    CASE 
        WHEN CHARINDEX('_', prd_key) > 0 
        THEN LEFT(prd_key, CHARINDEX('_', prd_key) - 1)
        ELSE LEFT(prd_key, 2)
    END AS cat_id,
    TRIM(prd_key) AS prd_key,
    TRIM(prd_nm) AS prd_nm,
    prd_cost,
    TRIM(prd_line) AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CASE 
        WHEN prd_end_dt IS NULL OR prd_end_dt = '' 
        THEN NULL 
        ELSE CAST(prd_end_dt AS DATE) 
    END AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_id IS NOT NULL;
GO

-- =============================================================================
-- Transform Sales Details (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming sales details...';



-- Clear existing data
TRUNCATE TABLE silver.crm_sales_details;

-- Transform and load sales data
INSERT INTO silver.crm_sales_details (
    sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, 
    sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
)
SELECT 
    TRIM(sls_ord_num) AS sls_ord_num,
    TRIM(sls_prd_key) AS sls_prd_key,
    sls_cust_id,
    -- Convert integer date to actual date with better error handling
    CASE 
        WHEN sls_order_dt IS NOT NULL AND sls_order_dt > 0 AND sls_order_dt < 100000
        THEN DATEADD(day, sls_order_dt - 2, '1900-01-01')
        ELSE NULL 
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt IS NOT NULL AND sls_ship_dt > 0 AND sls_ship_dt < 100000
        THEN DATEADD(day, sls_ship_dt - 2, '1900-01-01')
        ELSE NULL 
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt IS NOT NULL AND sls_due_dt > 0 AND sls_due_dt < 100000
        THEN DATEADD(day, sls_due_dt - 2, '1900-01-01')
        ELSE NULL 
    END AS sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NOT NULL;
GO

-- =============================================================================
-- Transform Location Information (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming location information...';

-- Clear existing data
TRUNCATE TABLE silver.erp_loc_a101;

-- Transform and load location data
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT 
    TRIM(cid) AS cid,
    TRIM(cntry) AS cntry
FROM bronze.erp_loc_a101
WHERE cid IS NOT NULL;
GO

-- =============================================================================
-- Transform Customer Demographics (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming customer demographics...';

-- Clear existing data
TRUNCATE TABLE silver.erp_cust_az12;

-- Transform and load customer demographics
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT 
    TRIM(cid) AS cid,
    bdate,
    TRIM(gen) AS gen
FROM bronze.erp_cust_az12
WHERE cid IS NOT NULL;
GO

-- =============================================================================
-- Transform Product Categories (Bronze to Silver)
-- =============================================================================
PRINT 'Transforming product categories...';

-- Clear existing data
TRUNCATE TABLE silver.erp_px_cat_g1v2;

-- Transform and load product categories
INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT 
    TRIM(id) AS id,
    TRIM(cat) AS cat,
    TRIM(subcat) AS subcat,
    TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id IS NOT NULL;
GO

PRINT 'Data transformation completed successfully!'; 