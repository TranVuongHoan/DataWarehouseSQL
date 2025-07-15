# 🧱 DataWarehouse Architecture & Pipeline Verification

## 📌 Overview

This project implements a layered **Data Warehouse architecture** based on the Medallion approach. It is designed to manage CRM and ERP data using structured schemas that represent increasing levels of data refinement: **Bronze**, **Silver**, and **Gold**.

The setup process includes initializing the database environment, organizing schemas for pipeline staging, and validating data movement between each layer through diagnostic checks.

---

## 🗂️ Schema Structure

### 🔶 Bronze Layer
- **Purpose:** Raw ingestion layer
- **Content:** Unprocessed data directly ingested from source systems (CRM, ERP, or flat files)
- **Characteristics:** No transformations; fields may contain nulls, duplications, or inconsistent formats
- **Usage:** Used as the staging ground for initial data loads before cleaning

### 🟨 Silver Layer
- **Purpose:** Cleansed and standardized data
- **Content:** Selected, typed, and structured fields from the Bronze layer
- **Processes Applied:**
  - Column filtering
  - Handling missing values
  - Type conversions and formatting
  - Creation of surrogate keys and standardized identifiers
- **Usage:** Forms the normalized basis for building analytics-ready outputs

### ⭐ Gold Layer
- **Purpose:** Business-ready views
- **Content:** Star schema design with dimension and fact views based on Silver tables
- **Features:**
  - Enriched datasets for reporting and dashboards
  - Joinable views with consistent surrogate keys
  - Filtered for active records only (e.g., removing historical product versions)
- **Usage:** Directly used by BI tools (Power BI, Tableau) for decision-making dashboards

---

## 🔍 Data Pipeline Diagnostic Verification

To ensure data integrity across all stages, a diagnostic script was developed. It verifies record flow and schema consistency from Bronze → Silver → Gold, highlighting potential breakpoints in the ETL process.

### ✅ Key Checks Performed

#### 1. **Record Volume Checks**
- Confirms that each table/view across all layers contains data
- Helps identify where data may have failed to load or transform

#### 2. **Sample Data Preview**
- Outputs sample rows from each major table in Bronze, Silver, and Gold
- Useful for confirming field mapping, data cleanliness, and format consistency

#### 3. **Joinability Tests**
- Verifies whether fact tables in Silver can successfully join with dimension tables using shared keys (e.g., product keys, customer IDs)
- Helps confirm foreign key relationships are preserved during transformation

#### 4. **Star Schema Validation**
- Checks that the final views in the Gold layer correctly reflect joined, enriched data
- Ensures fact table references align with dimension surrogate keys

---

## 🧠 Insights from Diagnostic Results

- **End-to-End Data Flow Visibility:** Record counts at each level offer visibility into whether data is moving through the pipeline as expected.
- **Join Relationship Health:** High joinability between sales, products, and customers validates key design consistency across Silver and Gold layers.
- **Quality Assurance for Reporting:** Clean data and structurally sound joins at the Gold level ensure accurate KPIs and metrics in dashboards.

---

## 📊 Outcome

The successful execution of the schema setup and diagnostic script provides:
- A fully operational three-tier data architecture
- Reliable and tested data models for analytics consumption
- A reusable and scalable ETL structure for future pipeline enhancements

This foundation supports robust reporting, flexible querying, and efficient data governance within the DataWarehouse environment.


