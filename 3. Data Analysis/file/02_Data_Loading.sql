/*
===============================================================================
02. Data Loading
===============================================================================
Script Purpose:
    This script loads data from CSV files into the bronze layer tables.
    It performs initial data ingestion with minimal transformation.
    
Note:
    Update the file paths below to match your actual CSV file locations.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Load Customer Information
-- =============================================================================
PRINT 'Loading customer information...';

BULK INSERT bronze.crm_cust_info
FROM 'C:\DA Basic\Project\SQL Data Warehouse\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- =============================================================================
-- Load Product Information
-- =============================================================================
PRINT 'Loading product information...';

BULK INSERT bronze.crm_prd_info
FROM 'C:\DA Basic\Project\SQL Data Warehouse\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- =============================================================================
-- Load Sales Details
-- =============================================================================
PRINT 'Loading sales details...';

BULK INSERT bronze.crm_sales_details
FROM 'C:\DA Basic\Project\SQL Data Warehouse\sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- =============================================================================
-- Load Location Information
-- =============================================================================
PRINT 'Loading location information...';

BULK INSERT bronze.erp_loc_a101
FROM 'C:\DA Basic\Project\SQL Data Warehouse\LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- =============================================================================
-- Load Customer Demographics
-- =============================================================================
PRINT 'Loading customer demographics...';

BULK INSERT bronze.erp_cust_az12
FROM 'C:\DA Basic\Project\SQL Data Warehouse\CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- =============================================================================
-- Load Product Categories
-- =============================================================================
PRINT 'Loading product categories...';

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\DA Basic\Project\SQL Data Warehouse\PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

PRINT 'Data loading completed successfully!'; 