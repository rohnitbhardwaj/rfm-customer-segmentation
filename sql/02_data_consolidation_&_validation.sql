
-- DATA CONSOLIDATION & VALIDATION: Combining historical retail datasets,
-- standardizing data types and identifying missing, invalid and duplicate records.

-- Combine both years of retail data and convert columns to appropriate data types
SELECT 
    invoice,
    stock_code,
    description,

    -- Handle multiple date formats during conversion
    COALESCE(
        TRY_CONVERT(DATETIME2, invoice_date, 105),
        TRY_CONVERT(DATETIME2, invoice_date, 120)
    ) AS invoice_date,

    -- Convert quantity and price into numeric data types
    TRY_CONVERT(INT, quantity) AS quantity,
    TRY_CONVERT(DECIMAL(10,2), price) AS price,

    customer_id,
    country,
    '2009-2010' AS source_sheet

-- Load converted records into the consolidated table
INTO retail.sales_combined
FROM retail.year2009_10

UNION ALL

SELECT 
    invoice,
    stock_code,
    description,

    -- Handle multiple date formats during conversion
    COALESCE(
        TRY_CONVERT(DATETIME2, invoice_date, 105),
        TRY_CONVERT(DATETIME2, invoice_date, 120)
    ) AS invoice_date,

    -- Convert quantity and price into numeric data types
    TRY_CONVERT(INT, quantity) AS quantity,
    TRY_CONVERT(DECIMAL(10,2), price) AS price,

    customer_id,
    country,
    '2010-2011' AS source_sheet

FROM retail.year2010_11;

-- =========================================================

-- CONVERSION VALIDATION & DATA QUALITY VALIDATION: Checking total records and 
-- identifying failed date, price & quantity conversions.
-- missing customer details, incomplete product descriptions, invalid quantities and duplicate transaction records.

-- Verify total number of consolidated records
SELECT COUNT(*) AS total_rows
FROM retail.sales_combined;

-- Identify records with unsuccessful date conversions
SELECT COUNT(*) AS failed_dates
FROM retail.sales_combined
WHERE invoice_date IS NULL;

-- Identify records with unsuccessful price conversions
SELECT COUNT(*) AS failed_price
FROM retail.sales_combined
WHERE price IS NULL;

-- Identify records with unsuccessful quantity conversions
SELECT COUNT(*) AS failed_quantity
FROM retail.sales_combined
WHERE quantity IS NULL;

-- Identify records with missing customer IDs
SELECT
    COUNT(*) AS missing_customer_id
FROM retail.sales_combined
WHERE customer_id IS NULL;


-- Identify records with missing product descriptions
SELECT
    COUNT(*) AS missing_description
FROM retail.sales_combined
WHERE description IS NULL;


-- Identify records with negative quantities
SELECT
    COUNT(*) AS incorrect_quantity
FROM retail.sales_combined
WHERE quantity < 0;


-- Identify exact duplicate transaction records
SELECT
    invoice,
    stock_code,
    description,
    invoice_date,
    quantity,
    price,
    customer_id,
    country,
    COUNT(*) AS exact_dupl_count
FROM retail.sales_combined
GROUP BY
    invoice,
    stock_code,
    description,
    invoice_date,
    quantity,
    price,
    customer_id,
    country
HAVING COUNT(*) > 1;


-- =========================================================


-- DATA DEDUPLICATION: Removing exact duplicate records and creating
-- a cleaned dataset for downstream analysis.

-- Identify and remove exact duplicate records using ROW_NUMBER()
SELECT
    invoice,
    stock_code,
    description,
    invoice_date,
    quantity,
    price,
    customer_id,
    country,
    source_sheet
INTO retail.sales_cleaned
FROM
(
    SELECT
        *,
        -- Assign row numbers to duplicate transaction records
        ROW_NUMBER() OVER(
            PARTITION BY invoice, stock_code, description, invoice_date,
                         quantity, price, customer_id, country
            ORDER BY (SELECT NULL)
        ) AS nr
    FROM retail.sales_combined
)t

-- Retain only one record from each duplicate group
WHERE nr = 1;

