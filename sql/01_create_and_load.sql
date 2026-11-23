
-- DATABASE SETUP & DATA INGESTION: Creating the eCommerce database, defining
-- retail tables and importing historical sales data from CSV files.

-- Create and switch to the eCommerce database
USE master;
GO

IF DB_ID('eCommerceData') IS NULL 
    CREATE DATABASE eCommerceData;
GO

USE eCommerceData;
GO

-- Create retail schema to organize sales data
IF SCHEMA_ID('retail') IS NULL
    EXEC('CREATE SCHEMA retail');
GO

-- Drop existing table before recreating its structure
IF OBJECT_ID('retail.year2009_10', 'U') IS NOT NULL
    DROP TABLE retail.year2009_10;
GO

-- Create table to store 2009-10 retail transaction data
CREATE TABLE retail.year2009_10(
    invoice NVARCHAR(50),
    stock_code NVARCHAR(50),
    description NVARCHAR(50),
    quantity NVARCHAR(30),
    invoice_date NVARCHAR(50),
    price NVARCHAR(20),
    customer_id NVARCHAR(30),
    country NVARCHAR(60)
);

GO

-- Drop existing table before recreating its structure
IF OBJECT_ID('retail.year2010_11', 'U') IS NOT NULL
    DROP TABLE retail.year2010_11;
GO

-- Create table to store 2010-11 retail transaction data
CREATE TABLE retail.year2010_11(
    invoice NVARCHAR(50),
    stock_code NVARCHAR(50),
    description NVARCHAR(50),
    quantity NVARCHAR(30),
    invoice_date NVARCHAR(50),
    price NVARCHAR(20),
    customer_id NVARCHAR(30),
    country NVARCHAR(60)
);

-- Import CSV data into retail tables, replacing existing records


-- Import 2009-10 transaction data
TRUNCATE TABLE retail.year2009_10;

BULK INSERT retail.year2009_10
FROM 'C:\data\online_retail_II page 2.csv' -- Update this path to the folder where you saved the CSV files
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Import 2010-11 transaction data
TRUNCATE TABLE retail.year2010_11;

BULK INSERT retail.year2010_11
FROM 'C:\data\online_retail_II page 1.csv' -- Update this path to the folder where you saved the CSV files
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);


