 /* ================== DATABASE ================== */
CREATE DATABASE IF NOT EXISTS etl_db;
USE etl_db;


/* ================== TABLE ================== */
CREATE TABLE IF NOT EXISTS Orders (
    Order_ID VARCHAR(10),
    Customer_ID VARCHAR(10),
    Sales_Amount VARCHAR(50),
    Order_Date VARCHAR(20)
);


/* ================== INSERT DATA ================== */
INSERT INTO Orders VALUES
('O101','C001','4500','12-01-2024'),
('O102','C002',NULL,'15-01-2024'),
('O103','C003','3200','2024/01/18'),
('O101','C001','4500','12-01-2024'),
('O104','C004','Three Thousand','20-01-2024'),
('O105','C005','5100','25-01-2024');


/* ================== Q1: Data Issues ================== */
SELECT *
FROM Orders
WHERE Sales_Amount IS NULL
   OR Sales_Amount NOT REGEXP '^[0-9]+$'
   OR Order_Date NOT REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';


/* ================== Q2: Duplicate PK ================== */
SELECT Order_ID, COUNT(*)
FROM Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;


/* ================== Q3: Missing Values ================== */
SELECT *
FROM Orders
WHERE Sales_Amount IS NULL;


/* ================== Q4: Data Type Issues ================== */
SELECT *
FROM Orders
WHERE Sales_Amount NOT REGEXP '^[0-9]+$'
   OR Sales_Amount IS NULL;


/* ================== Q5: Date Format Issues ================== */
SELECT *
FROM Orders
WHERE Order_Date LIKE '%/%';


/* ================== Q6: Clean Data Check ================== */
SELECT *
FROM Orders
WHERE Sales_Amount IS NOT NULL
  AND Sales_Amount REGEXP '^[0-9]+$'
  AND Order_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';


/* ================== Q7: Pre-load Validation ================== */
SELECT *
FROM Orders
WHERE Order_ID IS NULL
   OR Sales_Amount IS NULL
   OR Sales_Amount NOT REGEXP '^[0-9]+$'
   OR Order_Date NOT REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';


/* ================== Q8: CLEANING ================== */
SET SQL_SAFE_UPDATES = 0;

-- Fix text amount
UPDATE Orders
SET Sales_Amount = '3000'
WHERE Sales_Amount = 'Three Thousand';

-- Fix date format (convert to standard DATE)
UPDATE Orders
SET Order_Date = DATE_FORMAT(STR_TO_DATE(Order_Date, '%d-%m-%Y'), '%Y-%m-%d')
WHERE Order_Date LIKE '%-%';

SET SQL_SAFE_UPDATES = 1;


/* ================== Q9: Incremental Load ================== */
SELECT *
FROM Orders
WHERE Order_Date >= '2024-01-20';


/* ================== Q10: BI Impact ================== */
-- Before cleaning (may give wrong result)
SELECT SUM(CAST(Sales_Amount AS UNSIGNED)) AS Total_Sales
FROM Orders;

-- After cleaning (correct result)
SELECT SUM(CAST(Sales_Amount AS UNSIGNED)) AS Clean_Total_Sales
FROM Orders
WHERE Sales_Amount REGEXP '^[0-9]+$';