-- Example: Large SQL Script Template (Over 200 Lines)
-- Purpose: ETL process for sales data warehouse

-- =========================================
-- 1. SETUP
-- =========================================
USE SalesDataWarehouse;
GO

-- Drop temp tables if they exist
IF OBJECT_ID('tempdb..#RawSales') IS NOT NULL DROP TABLE #RawSales;
IF OBJECT_ID('tempdb..#CleanSales') IS NOT NULL DROP TABLE #CleanSales;

-- =========================================
-- 2. LOAD RAW DATA
-- =========================================
SELECT *
INTO #RawSales
FROM SourceDB.dbo.SalesTransactions;

-- =========================================
-- 3. CLEAN DATA
-- =========================================
SELECT
    SaleID,
    CustomerID,
    ProductID,
    SaleDate,
    CASE WHEN Amount < 0 THEN 0 ELSE Amount END AS Amount,
    ISNULL(Region, 'Unknown') AS Region
INTO #CleanSales
FROM #RawSales
WHERE SaleDate >= '2024-01-01';

-- =========================================
-- 4. TRANSFORMATIONS (CTEs)
-- =========================================
-- Example CTE chain for modular logic
WITH
    SalesByRegion AS (
        SELECT
            Region,
            SUM(Amount) AS TotalSales
        FROM #CleanSales
        GROUP BY Region
    ),
    TopRegions AS (
        SELECT TOP 5
            Region,
            TotalSales
        FROM SalesByRegion
        ORDER BY TotalSales DESC
    ),
    SalesByProduct AS (
        SELECT
            ProductID,
            SUM(Amount) AS ProductSales
        FROM #CleanSales
        GROUP BY ProductID
    )
-- =========================================
-- 5. FINAL REPORT
-- =========================================
SELECT
    cr.Region,
    tr.TotalSales,
    sp.ProductID,
    sp.ProductSales
FROM TopRegions tr
JOIN #CleanSales cr ON tr.Region = cr.Region
JOIN SalesByProduct sp ON cr.ProductID = sp.ProductID
ORDER BY tr.TotalSales DESC;

-- =========================================
-- 6. LOGGING AND AUDIT
-- =========================================
INSERT INTO AuditLog (ProcessName, RunDate, Status)
VALUES ('Sales ETL', GETDATE(), 'Success');

-- =========================================
-- 7. CLEANUP
-- =========================================
DROP TABLE IF EXISTS #RawSales;
DROP TABLE IF EXISTS #CleanSales;

-- =========================================
-- 8. ADDITIONAL MODULES (Repeat as needed)
-- =========================================
-- More CTEs, INSERTs, UPDATEs, complex logic, etc.

-- (Continue expanding each section with real business logic, transformations, error handling, and documentation comments.)

-- =========================================
-- 9. END OF SCRIPT
-- =========================================

-- This template can easily be expanded to 200+ lines by adding more business logic, transformations, and documentation.

