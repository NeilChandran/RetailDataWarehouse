-- etl_pipeline.sql

-- STEP 1: Load Raw Data to Staging Tables
-- ... Insert statements for staging_sales, staging_customers, staging_products
-- Sample:
INSERT INTO staging_sales (...) SELECT ... FROM source_sales;

-- STEP 2: Data Cleansing
UPDATE staging_sales SET amount = 0 WHERE amount < 0;

-- STEP 3: Transform and Load Dimension Tables
INSERT INTO dim_customer (...)
SELECT DISTINCT ... FROM staging_customers;

INSERT INTO dim_product (...)
SELECT DISTINCT ... FROM staging_products;

-- STEP 4: Transform and Load Fact Table
INSERT INTO fact_sales (...)
SELECT ... FROM staging_sales JOIN dim_customer ...;

-- STEP 5: Generate Aggregated Data (Daily/Monthly Sales)
INSERT INTO agg_daily_sales (...)
SELECT ... FROM fact_sales;

-- Re-run for other fact and dimension tables as needed
-- Repeat and expand these steps for inventory, supplier, promotions, etc.
...
