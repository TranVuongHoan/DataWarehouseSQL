# 📦 Data Warehouse Initialization & Modeling Project

## 📚 Project Description

This project sets up a robust, scalable SQL Server Data Warehouse environment designed for CRM and ERP analytics. It follows the modern **medallion architecture**—structuring data across **Bronze**, **Silver**, and **Gold** layers. The goal is to transform raw data into clean, business-ready dimensional models that can support BI tools (e.g., Power BI, Tableau) for interactive reporting and decision-making.

---

## 🎯 Objectives

- ✅ Initialize and manage a structured **DataWarehouse** database.
- ✅ Create and organize **Bronze**, **Silver**, and **Gold** schemas based on the data refinement lifecycle.
- ✅ Build clean, enriched **Silver layer tables** by transforming CRM and ERP sources.
- ✅ Design **Gold layer star schema views** (dimensions and fact) for reporting.
- ✅ Enable seamless integration with BI tools for business intelligence consumption.
- ✅ Promote modular, reusable, and clear SQL-based ETL practices.

---

## ⚙️ Tech Stack

| Technology       | Description                              |
|------------------|------------------------------------------|
| **SQL Server**   | Core database and DDL/DML development    |
| **T-SQL**        | Scripting for table/view creation, logic |
| **Star Schema**  | Modeling pattern for dimensional design  |
| **ETL Concepts** | Handling nulls, surrogate keys, filters  |
| **BI Tools**     | Power BI/Tableau compatible views        |

---

## 🏗️ Project Structure

### 🛠️ Initialization Script: `init_database.sql`

- Drops existing `DataWarehouse` (if exists) and recreates it.
- Creates three distinct schemas:
  - **`bronze`** – Raw ingestion (not included here)
  - **`silver`** – Cleaned and structured staging tables
  - **`gold`** – Business-ready dimension and fact views

---

## 🧱 Data Modeling Architecture

### 🔹 Bronze Layer *(Raw Layer – Future Extension)*

- Landing zone for raw source files (e.g., `.csv`, `.json`, flat tables).
- Not part of this project, but reserved for future ingestion.

### 🔸 Silver Layer *(Structured Staging Tables)*

Represents **cleansed**, **normalized**, and **standardized** intermediate data sourced from CRM and ERP systems.

#### Tables Created:

| Table Name                     | Description                                 |
|-------------------------------|---------------------------------------------|
| `silver.crm_cust_info`        | Customer info from CRM system               |
| `silver.crm_prd_info`         | Product metadata and costs                  |
| `silver.crm_sales_details`    | Sales transaction data                      |
| `silver.erp_loc_a101`         | Customer location (country) info            |
| `silver.erp_cust_az12`        | Demographics: birthdate, gender             |
| `silver.erp_px_cat_g1v2`      | Product category & subcategory details      |

#### Key Transformations:
- 🔤 Standardized column names to `snake_case`.
- 🧹 Removed irrelevant/null-heavy columns (`agent`, `company`).
- ➕ Added derived fields (e.g., `room_status`, guest types in other use cases).
- 📅 Converted date fields and ensured data types are consistent.
- 📦 Created surrogate keys and dimension-friendly identifiers.

---

## ⭐ Gold Layer *(Business-Ready Views)*

Gold layer views act as **final dimensional tables** following the **Star Schema**. These views are designed for **direct querying** in BI dashboards or analytics platforms.

---

### 🧍‍♂️ `gold.dim_customers`

| Field               | Description                                           |
|--------------------|-------------------------------------------------------|
| `customer_key`     | Surrogate key via `ROW_NUMBER()`                     |
| `customer_id`      | CRM customer ID                                       |
| `customer_number`  | External customer reference key                       |
| `first_name`       | First name                                            |
| `last_name`        | Last name                                             |
| `country`          | Country from ERP location table                       |
| `marital_status`   | Marital status (CRM)                                  |
| `gender`           | Uses CRM gender if present, else fallback to ERP      |
| `birthdate`        | Birth date from ERP                                   |
| `create_date`      | Customer creation date                                |

📌 *Primary join logic: `crm_cust_info` LEFT JOIN `erp_cust_az12` & `erp_loc_a101`*

---

### 🛍️ `gold.dim_products`

| Field            | Description                                        |
|------------------|----------------------------------------------------|
| `product_key`    | Surrogate key via `ROW_NUMBER()`                   |
| `product_id`     | Internal product ID                                |
| `product_number` | External SKU code                                  |
| `product_name`   | Product name                                       |
| `category_id`    | ID for product category                            |
| `category`       | Category name from ERP mapping                     |
| `subcategory`    | Subcategory classification                        |
| `maintenance`    | Maintenance flag                                   |
| `cost`           | Product cost                                       |
| `product_line`   | Line (e.g., brand/family)                          |
| `start_date`     | Validity start date                                |

📌 *Joined with `erp_px_cat_g1v2` and filters out historical (inactive) products using `prd_end_dt IS NULL`*

---

### 💰 `gold.fact_sales`

| Field           | Description                             |
|------------------|-----------------------------------------|
| `order_number`   | Sales order number                      |
| `product_key`    | FK to `dim_products`                    |
| `customer_key`   | FK to `dim_customers`                   |
| `order_date`     | Order placement date                    |
| `shipping_date`  | Date item was shipped                   |
| `due_date`       | Contractual due/shipping date           |
| `sales_amount`   | Total sales (gross)                     |
| `quantity`       | Number of units ordered                 |
| `price`          | Unit price                              |

📌 *Fact table linked to dimensions via product and customer keys*

---


---

## 🧪 Data Validation & Quality Checks

- ✅ Surrogate key integrity via `ROW_NUMBER()`
- ✅ Removed historical/inactive products
- ✅ Null handling with `COALESCE` for gender fallback
- ✅ Date fields cast and standardized
- ✅ Used default `GETDATE()` for warehouse creation timestamp
