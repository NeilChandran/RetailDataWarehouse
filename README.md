# Retail Data Warehouse SQL ETL

This project contains a comprehensive SQL script that simulates an end-to-end ETL (Extract, Transform, Load) process for a fictional retail company's data warehouse. The script demonstrates best practices for staging, cleaning, transforming, aggregating, and reporting on sales, customer, and product data using SQL Server (T-SQL) syntax.

## Features

- **Staging Tables:** Loads raw sales, customer, and product data into staging tables.
- **Data Cleansing:** Handles data quality issues such as missing values and negative amounts.
- **Dimension Tables:** Builds customer and product dimension tables for analytics.
- **Fact Table:** Populates a sales fact table with cleaned and transformed data.
- **Aggregated Reporting:** Includes sample queries for sales summaries, customer lifetime value, product performance, and more.
- **Sample Data:** Generates dummy data for demonstration and testing purposes.

## Use Cases

- Demonstrating ETL processes in SQL for educational or interview purposes.
- Prototyping a retail analytics data warehouse.
- Learning SQL Server data warehousing techniques.

## How to Use

1. Clone or download this repository.
2. Open the `retail_etl_script.sql` file in your SQL Server Management Studio or preferred SQL editor.
3. Run the script in a test database (e.g., `tempdb`).
4. Explore and modify the queries to fit your own data or reporting needs.

## Requirements

- Microsoft SQL Server (tested on SQL Server 2019 and later)
- Sufficient permissions to create tables and views in the target database
