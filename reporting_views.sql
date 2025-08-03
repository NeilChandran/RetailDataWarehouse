-- reporting_views.sql

-- Customer Lifetime Value View
CREATE OR ALTER VIEW vw_customer_lifetime_value AS
SELECT 
    c.customer_id,
    SUM(f.amount) AS total_spend,
    COUNT(f.sale_id) AS total_transactions,
    MIN(f.sale_date) AS first_purchase,
    MAX(f.sale_date) AS last_purchase
FROM 
    dim_customer c
    JOIN fact_sales f ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_id;

-- Monthly Product Sales View
CREATE OR ALTER VIEW vw_monthly_product_sales AS
SELECT 
    p.product_id,
    YEAR(f.sale_date) AS sales_year,
    MONTH(f.sale_date) AS sales_month,
    SUM(f.amount) AS total_sales
FROM 
    dim_product p
    JOIN fact_sales f ON p.product_key = f.product_key
GROUP BY 
    p.product_id, YEAR(f.sale_date), MONTH(f.sale_date);

-- Add more views:
-- vw_product_category_performance
-- vw_return_rate_by_customer
-- vw_new_vs_repeat_customers
-- vw_store_performance_by_region
...
