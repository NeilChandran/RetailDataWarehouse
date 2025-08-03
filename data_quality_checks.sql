-- data_quality_checks.sql

-- Check for NULL keys in fact table
SELECT COUNT(*) AS null_customer_keys FROM fact_sales WHERE customer_key IS NULL;

-- Detect duplicate SKUs in product dimension
SELECT sku, COUNT(*) AS count_duplicates
FROM dim_product
GROUP BY sku
HAVING COUNT(*) > 1;

-- Unusual negative amounts
SELECT * FROM staging_sales WHERE amount < 0;

-- Orphan records: sales with missing products
SELECT f.*
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- Invalid Date Ranges
SELECT sale_id, sale_date FROM fact_sales WHERE sale_date > GETDATE();

-- Add more checks and possibly create stored procedures:
-- usp_check_sales_consistency
-- usp_check_dim_customer_integrity
-- usp_data_quality_dashboard (summary of all checks)
...
