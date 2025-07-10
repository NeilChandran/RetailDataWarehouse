USE tempdb;
GO

-- Drop tables if they exist
IF OBJECT_ID('dbo.Stg_Sales', 'U') IS NOT NULL DROP TABLE dbo.Stg_Sales;
IF OBJECT_ID('dbo.Stg_Customers', 'U') IS NOT NULL DROP TABLE dbo.Stg_Customers;
IF OBJECT_ID('dbo.Stg_Products', 'U') IS NOT NULL DROP TABLE dbo.Stg_Products;
IF OBJECT_ID('dbo.Fact_Sales', 'U') IS NOT NULL DROP TABLE dbo.Fact_Sales;
IF OBJECT_ID('dbo.Dim_Customer', 'U') IS NOT NULL DROP TABLE dbo.Dim_Customer;
IF OBJECT_ID('dbo.Dim_Product', 'U') IS NOT NULL DROP TABLE dbo.Dim_Product;

-- Create staging tables
CREATE TABLE dbo.Stg_Sales (
    SaleID INT PRIMARY KEY,
    SaleDate DATE,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    Amount DECIMAL(10,2),
    Region NVARCHAR(50)
);

CREATE TABLE dbo.Stg_Customers (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    SignupDate DATE,
    IsActive BIT
);

CREATE TABLE dbo.Stg_Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    Price DECIMAL(10,2),
    Discontinued BIT
);

-- Insert dummy data into staging tables
INSERT INTO dbo.Stg_Customers VALUES (1, 'Alice', 'Smith', 'alice@example.com', '2023-01-15', 1);
INSERT INTO dbo.Stg_Customers VALUES (2, 'Bob', 'Brown', 'bob@example.com', '2023-02-20', 1);
INSERT INTO dbo.Stg_Customers VALUES (3, 'Carol', 'Davis', 'carol@example.com', '2023-03-10', 0);
INSERT INTO dbo.Stg_Customers VALUES (4, 'Dan', 'Miller', 'dan@example.com', '2023-04-05', 1);
INSERT INTO dbo.Stg_Customers VALUES (5, 'Eve', 'Wilson', 'eve@example.com', '2023-05-12', 1);

INSERT INTO dbo.Stg_Products VALUES (100, 'Widget', 'Gadgets', 25.00, 0);
INSERT INTO dbo.Stg_Products VALUES (101, 'Gizmo', 'Gadgets', 15.00, 0);
INSERT INTO dbo.Stg_Products VALUES (102, 'Thingamajig', 'Widgets', 35.00, 1);
INSERT INTO dbo.Stg_Products VALUES (103, 'Doodad', 'Gizmos', 45.00, 0);
INSERT INTO dbo.Stg_Products VALUES (104, 'Contraption', 'Widgets', 55.00, 0);

DECLARE @i INT = 1;
WHILE @i <= 200
BEGIN
    INSERT INTO dbo.Stg_Sales
    SELECT
        @i,
        DATEADD(DAY, -@i, GETDATE()),
        (1 + (@i % 5)),
        (100 + (@i % 5)),
        (1 + (@i % 10)),
        (10 + (@i % 50)) * (1 + (@i % 10)),
        CASE WHEN @i % 2 = 0 THEN 'North' ELSE 'South' END;
    SET @i = @i + 1;
END

-- Create dimension tables
CREATE TABLE dbo.Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    SignupDate DATE,
    IsActive BIT
);

CREATE TABLE dbo.Dim_Product (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    Price DECIMAL(10,2),
    Discontinued BIT
);

-- Create fact table
CREATE TABLE dbo.Fact_Sales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT,
    SaleDate DATE,
    CustomerKey INT,
    ProductKey INT,
    Quantity INT,
    Amount DECIMAL(10,2),
    Region NVARCHAR(50)
);

-- Populate dimension tables
INSERT INTO dbo.Dim_Customer (CustomerID, FullName, Email, SignupDate, IsActive)
SELECT
    CustomerID,
    FirstName + ' ' + LastName,
    Email,
    SignupDate,
    IsActive
FROM dbo.Stg_Customers;

INSERT INTO dbo.Dim_Product (ProductID, ProductName, Category, Price, Discontinued)
SELECT
    ProductID,
    ProductName,
    Category,
    Price,
    Discontinued
FROM dbo.Stg_Products;

-- Populate fact table
INSERT INTO dbo.Fact_Sales (SaleID, SaleDate, CustomerKey, ProductKey, Quantity, Amount, Region)
SELECT
    s.SaleID,
    s.SaleDate,
    c.CustomerKey,
    p.ProductKey,
    s.Quantity,
    s.Amount,
    s.Region
FROM dbo.Stg_Sales s
JOIN dbo.Dim_Customer c ON s.CustomerID = c.CustomerID
JOIN dbo.Dim_Product p ON s.ProductID = p.ProductID;

-- Create reporting views
IF OBJECT_ID('dbo.vw_SalesSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_SalesSummary;
GO
CREATE VIEW dbo.vw_SalesSummary AS
SELECT
    d.FullName AS Customer,
    p.ProductName,
    f.Region,
    SUM(f.Quantity) AS TotalQuantity,
    SUM(f.Amount) AS TotalAmount
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Customer d ON f.CustomerKey = d.CustomerKey
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY d.FullName, p.ProductName, f.Region;

-- Generate monthly sales report
WITH MonthlySales AS (
    SELECT
        DATEPART(YEAR, SaleDate) AS SalesYear,
        DATEPART(MONTH, SaleDate) AS SalesMonth,
        SUM(Amount) AS TotalAmount,
        COUNT(*) AS TransactionCount
    FROM dbo.Fact_Sales
    GROUP BY DATEPART(YEAR, SaleDate), DATEPART(MONTH, SaleDate)
)
SELECT * FROM MonthlySales ORDER BY SalesYear, SalesMonth;

-- Top 3 customers by total amount
SELECT TOP 3
    d.FullName,
    SUM(f.Amount) AS TotalSpent
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Customer d ON f.CustomerKey = d.CustomerKey
GROUP BY d.FullName
ORDER BY TotalSpent DESC;

-- Top 3 products by sales
SELECT TOP 3
    p.ProductName,
    SUM(f.Quantity) AS TotalSold
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY TotalSold DESC;

-- Sales by region and product
SELECT
    f.Region,
    p.ProductName,
    SUM(f.Amount) AS TotalAmount
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY f.Region, p.ProductName
ORDER BY f.Region, TotalAmount DESC;

-- Customers with no sales
SELECT
    d.FullName,
    d.Email
FROM dbo.Dim_Customer d
LEFT JOIN dbo.Fact_Sales f ON d.CustomerKey = f.CustomerKey
WHERE f.SalesKey IS NULL;

-- Product performance by month
WITH ProductMonth AS (
    SELECT
        p.ProductName,
        DATEPART(YEAR, f.SaleDate) AS SalesYear,
        DATEPART(MONTH, f.SaleDate) AS SalesMonth,
        SUM(f.Quantity) AS TotalSold,
        SUM(f.Amount) AS TotalAmount
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
    GROUP BY p.ProductName, DATEPART(YEAR, f.SaleDate), DATEPART(MONTH, f.SaleDate)
)
SELECT * FROM ProductMonth ORDER BY ProductName, SalesYear, SalesMonth;

-- Customer activity and churn
SELECT
    d.FullName,
    COUNT(f.SalesKey) AS PurchaseCount,
    MAX(f.SaleDate) AS LastPurchaseDate,
    DATEDIFF(DAY, MAX(f.SaleDate), GETDATE()) AS DaysSinceLastPurchase
FROM dbo.Dim_Customer d
LEFT JOIN dbo.Fact_Sales f ON d.CustomerKey = f.CustomerKey
GROUP BY d.FullName
ORDER BY DaysSinceLastPurchase DESC;

-- Product sales trend (rolling 7 days)
WITH SalesTrend AS (
    SELECT
        f.SaleDate,
        p.ProductName,
        SUM(f.Quantity) AS DailySold
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
    GROUP BY f.SaleDate, p.ProductName
)
SELECT
    SaleDate,
    ProductName,
    DailySold,
    SUM(DailySold) OVER (PARTITION BY ProductName ORDER BY SaleDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling7DayTotal
FROM SalesTrend
ORDER BY ProductName, SaleDate;

-- Regional sales breakdown
SELECT
    Region,
    COUNT(*) AS NumSales,
    SUM(Amount) AS TotalSales,
    AVG(Amount) AS AvgSale
FROM dbo.Fact_Sales
GROUP BY Region;

-- Active customers with sales in last 30 days
SELECT
    d.FullName,
    d.Email,
    COUNT(f.SalesKey) AS RecentPurchases
FROM dbo.Dim_Customer d
JOIN dbo.Fact_Sales f ON d.CustomerKey = f.CustomerKey
WHERE f.SaleDate >= DATEADD(DAY, -30, GETDATE())
AND d.IsActive = 1
GROUP BY d.FullName, d.Email
ORDER BY RecentPurchases DESC;

-- Product discontinuation impact
SELECT
    p.ProductName,
    p.Discontinued,
    SUM(f.Amount) AS TotalSales
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.Discontinued
ORDER BY p.Discontinued DESC, TotalSales DESC;

-- Sales by customer and month
WITH CustomerMonth AS (
    SELECT
        d.FullName,
        DATEPART(YEAR, f.SaleDate) AS SalesYear,
        DATEPART(MONTH, f.SaleDate) AS SalesMonth,
        SUM(f.Amount) AS TotalAmount
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customer d ON f.CustomerKey = d.CustomerKey
    GROUP BY d.FullName, DATEPART(YEAR, f.SaleDate), DATEPART(MONTH, f.SaleDate)
)
SELECT * FROM CustomerMonth ORDER BY FullName, SalesYear, SalesMonth;

-- Inventory simulation (products with low sales)
SELECT
    p.ProductName,
    SUM(f.Quantity) AS TotalSold
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName
HAVING SUM(f.Quantity) < 20
ORDER BY TotalSold ASC;

-- Customers with multiple purchases in a day
SELECT
    d.FullName,
    f.SaleDate,
    COUNT(f.SalesKey) AS Purchases
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Customer d ON f.CustomerKey = d.CustomerKey
GROUP BY d.FullName, f.SaleDate
HAVING COUNT(f.SalesKey) > 1
ORDER BY Purchases DESC;

-- Product category analysis
SELECT
    p.Category,
    SUM(f.Amount) AS TotalSales,
    AVG(f.Amount) AS AvgSale
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Product p ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalSales DESC;

-- Customer lifetime value
SELECT
    d.FullName,
    SUM(f.Amount) AS LifetimeValue
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Customer d ON f.CustomerKey = d.CustomerKey
GROUP BY d.FullName
ORDER BY LifetimeValue DESC;

-- End of script

