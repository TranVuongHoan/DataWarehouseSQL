# Data Preparation

## Data Examination

The dataset consists of multiple tables containing customer, product, and sales information. Below is a summary of each table's structure and fields:

### Customer Data (`cust_data.png`)
Contains customer demographic information:
- `est_id`: Customer ID
- `est_key`: Customer key
- `est_firstname`: First name
- `est_lastname`: Last name
- `est_marital_status`: Marital status (M/S)
- `est_gndr`: Gender (M/F)
- `est_create_date`: Account creation date

### Customer Additional Info (`cust_data2.png`)
Contains supplementary customer data:
- `CID`: Customer ID (matches est_id from cust_data)
- `BDATE`: Birth date
- `GEN`: Gender (redundant with est_gndr)

### Location Data (`loc_data.png`)
Contains customer geographic information:
- `CID`: Customer ID
- `CNTRY`: Country of residence

### Product Data (`prd_data.png`)
Contains product information:
- `prd_id`: Product ID
- `prd_key`: Product key/SKU
- `prd_nm`: Product name
- `prd_cost`: Product cost
- `prd_line`: Product line/category
- `prd_start_dt`: Product introduction date
- `prd_end_dt`: Product discontinuation date (if applicable)

### Product Category Data (`px_cat_data.png`)
Contains product categorization:
- `ID`: Category ID
- `CAT`: Main category (e.g., Accessories, Bikes, Clothing)
- `SUBCAT`: Subcategory
- `MAINTENANCE`: Whether maintenance is required (Yes/No)

### Sales Data (`sales_data.png`)
Contains transaction records:
- `sis_ord_num`: Order number
- `sis_prd_key`: Product key (matches prd_key in product data)
- `sis_cust_id`: Customer ID
- `sis_order_dt`: Order date
- `sis_ship_dt`: Ship date
- `sis_due_dt`: Due date
- `sis_sales`: Total sale amount
- `sis_quantity`: Quantity purchased
- `sis_price`: Unit price

## Data Transformation

To prepare the data for analysis, the following transformation steps were performed:

### 1. Data Cleaning
- Standardized customer IDs across tables (removed "NASA" prefix and standardized to match)
- Parsed birth dates from combined fields in `cust_data2.png`
- Verified and corrected any inconsistent gender information between tables
- Standardized date formats across all tables (MM/DD/YYYY)

### 2. Data Integration
- Created master customer table by joining:
  - Basic demographics from `cust_data.png`
  - Birth dates from `cust_data2.png`
  - Location data from `loc_data.png`
- Enhanced product data by joining:
  - Product details from `prd_data.png`
  - Category information from `px_cat_data.png`

### 3. Data Enhancement
- Calculated customer ages from birth dates
- Added derived fields:
  - Customer tenure (from account creation date)
  - Product age (from introduction date)
  - Order fulfillment time (ship date - order date)
- Categorized products by price range

### 4. Data Validation
- Verified all sales transactions reference valid:
  - Customer IDs
  - Product keys
- Checked for logical inconsistencies:
  - Ship dates after order dates
  - Positive quantities and prices
  - Valid date ranges for discontinued products

### 5. Data Optimization
- Created integer IDs for all entities to improve join performance
- Established proper foreign key relationships between tables
- Normalized product category hierarchy

## Data Quality Notes

The following data quality issues were identified and addressed:
1. Some customer records in `cust_data.png` had no matching entry in `cust_data2.png` (resolved by cross-referencing)
2. Product cost field in `prd_data.png` contained some inconsistent formatting (cleaned and standardized)
3. A few sales records referenced discontinued products (flagged for further investigation)

## Transformation Tools and Outputs

The data transformation process was automated using Python scripts that:
1. Load and parse the original data files
2. Perform cleaning and standardization
3. Create the integrated dataset
4. Generate data quality reports

The transformed data is available in the following formats:
- SQL database dump
- CSV files for analysis
- Parquet files for big data processing

The transformation scripts can be found in the `data_preparation` directory of this repository.
