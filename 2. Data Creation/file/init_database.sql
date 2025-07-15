/*
Initialization Script – Database and Schema Setup
Objective:
- This script initializes a database environment by performing the following operations:

- Checks for the existence of a database named DataWarehouse.

- If the database is found, it is dropped and re-created.

Upon creation, the script defines three schemas within the DataWarehouse:
- bronze

- silver

- gold

These schemas establish a foundational layer for organizing data based on its level of processing or refinement.
*/

-- Switch to the master database
USE master;
GO

-- Check if 'DataWarehouse' exists, set to SINGLE_USER and drop it if it does
IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create a new 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the newly created database
USE DataWarehouse;
GO

-- Create schemas for data processing stages
CREATE SCHEMA [bronze];
GO

CREATE SCHEMA [silver];
GO

CREATE SCHEMA [gold];
GO

