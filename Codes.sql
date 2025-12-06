USE ecomm;
SELECT * FROM customer_churn LIMIT 10;

--  QUESTION1: DATA CLEANING
-- Scenario:
-- Handle missing values and outliers to make the dataset reliable.
-- Task:
--  a) Impute mean for numeric columns.
--  b) Impute mode for discrete columns.
--  c) Remove outliers where WarehouseToHome > 100.
-- =====================================================================

-- Step 1: Check for missing values
SELECT 
    SUM(CASE WHEN WarehouseToHome IS NULL THEN 1 ELSE 0 END) AS Missing_WarehouseToHome,
    SUM(CASE WHEN HourSpendOnApp IS NULL THEN 1 ELSE 0 END) AS Missing_HourSpendOnApp,
    SUM(CASE WHEN OrderAmountHikeFromlastYear IS NULL THEN 1 ELSE 0 END) AS Missing_OrderHike,
    SUM(CASE WHEN DaySinceLastOrder IS NULL THEN 1 ELSE 0 END) AS Missing_DaySinceOrder,
    SUM(CASE WHEN Tenure IS NULL THEN 1 ELSE 0 END) AS Missing_Tenure,
    SUM(CASE WHEN CouponUsed IS NULL THEN 1 ELSE 0 END) AS Missing_CouponUsed,
    SUM(CASE WHEN OrderCount IS NULL THEN 1 ELSE 0 END) AS Missing_OrderCount
FROM customer_churn;

-- Step 2: Impute MEAN for numeric columns
-- Columns: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder

-- Check the mean values
SELECT 
    ROUND(AVG(WarehouseToHome),0) AS Avg_WarehouseToHome,
    ROUND(AVG(HourSpendOnApp),0) AS Avg_HourSpendOnApp,
    ROUND(AVG(OrderAmountHikeFromlastYear),0) AS Avg_OrderHike,
    ROUND(AVG(DaySinceLastOrder),0) AS Avg_LastOrder
FROM customer_churn;

-- Replace NULLs with average values
SET SQL_SAFE_UPDATES = 0;

UPDATE customer_churn
SET WarehouseToHome = (SELECT ROUND(AVG(WarehouseToHome),0)
FROM (SELECT * FROM customer_churn WHERE WarehouseToHome IS NOT NULL) AS t)
WHERE WarehouseToHome IS NULL;

UPDATE customer_churn
SET HourSpendOnApp = (SELECT ROUND(AVG(HourSpendOnApp),0)
FROM (SELECT * FROM customer_churn WHERE HourSpendOnApp IS NOT NULL) AS t)
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear),0)
FROM (SELECT * FROM customer_churn WHERE OrderAmountHikeFromlastYear IS NOT NULL) AS t)
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = (SELECT ROUND(AVG(DaySinceLastOrder),0)
FROM (SELECT * FROM customer_churn WHERE DaySinceLastOrder IS NOT NULL) AS t)
WHERE DaySinceLastOrder IS NULL;

-- Step 3: Impute MODE for categorical/discrete columns
-- Columns: Tenure, CouponUsed, OrderCount

-- Find the most frequent (mode) values
SELECT Tenure, COUNT(*) AS Frequency
FROM customer_churn
GROUP BY Tenure
ORDER BY Frequency DESC
LIMIT 5;

SELECT CouponUsed, COUNT(*) AS Frequency
FROM customer_churn
GROUP BY CouponUsed
ORDER BY Frequency DESC
LIMIT 5;

SELECT OrderCount, COUNT(*) AS Frequency
FROM customer_churn
GROUP BY OrderCount
ORDER BY Frequency DESC
LIMIT 5;

-- (Replace with actual mode values after running above queries)
UPDATE customer_churn SET Tenure = 12 WHERE Tenure IS NULL;
UPDATE customer_churn SET CouponUsed = 1 WHERE CouponUsed IS NULL;
UPDATE customer_churn SET OrderCount = 3 WHERE OrderCount IS NULL;

-- Step 4: Remove Outliers (WarehouseToHome > 100)
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

-- =====================================================================
-- QUESTION 3: DEALING WITH INCONSISTENCIES
-- Scenario:
-- Some categorical values in the dataset are inconsistent or abbreviated.
-- Goal:
-- Standardize the naming conventions for clarity and uniformity.
-- Tasks:
--    Replace "Phone" with "Mobile Phone" in 'PreferredLoginDevice'.
--    Replace "Mobile" with "Mobile Phone" in 'PreferedOrderCat'.
--    Replace "COD" with "Cash on Delivery" in 'PreferredPaymentMode'.
--    Replace "CC" with "Credit Card" in 'PreferredPaymentMode'.
-- =====================================================================

--  Replace 'Phone' with 'Mobile Phone' in PreferredLoginDevice
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

--  Replace 'Mobile' with 'Mobile Phone' in PreferedOrderCat
UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

--  Replace 'COD' with 'Cash on Delivery' in PreferredPaymentMode
UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

--  Replace 'CC' with 'Credit Card' in PreferredPaymentMode
UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

--  Verifying the  updates
SELECT DISTINCT PreferredLoginDevice FROM customer_churn;
SELECT DISTINCT PreferedOrderCat FROM customer_churn;
SELECT DISTINCT PreferredPaymentMode FROM customer_churn;

-- =====================================================================
-- QUESTION 4: DATA TRANSFORMATION
-- Scenario:
-- Some column names in the dataset have typos or unclear wording.
-- Task:
-- Rename columns for clarity and consistency.
-- 
--  Rename "PreferedOrderCat" → "PreferredOrderCat"
--  Rename "HourSpendOnApp" → "HoursSpentOnApp"
-- =====================================================================

--  Rename 'PreferedOrderCat' to 'PreferredOrderCat'
ALTER TABLE customer_churn
rename COLUMN PreferedOrderCat to PreferredOrderCat ;

--  Rename 'HourSpendOnApp' to 'HoursSpentOnApp'
ALTER TABLE customer_churn
Rename COLUMN HourSpendOnApp to  HoursSpentOnApp ;

--  Verify the column names after renaming
DESCRIBE customer_churn;
select * from customer_churn limit 30;

-- =====================================================================
-- QUESTION 5: DATA TRANSFORMATION – CREATING NEW COLUMNS
-- Scenario:
-- Management wants clearer categorical columns instead of binary (0/1) values
-- for better readability and reporting in Power BI or Excel.
--
-- Task:
-- Create a new column 'ComplaintReceived':
--     - Set as 'Yes' if Complain = 1
--     - Set as 'No'  if Complain = 0 or NULL
--
--  Create a new column 'ChurnStatus':
--     - Set as 'Churned' if Churn = 1
--     - Set as 'Active'  otherwise
-- =====================================================================

--  Step 1: Add the new columns to the table
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(10),
ADD COLUMN ChurnStatus VARCHAR(10);

--  Step 2: Populate 'ComplaintReceived' column
UPDATE customer_churn
SET ComplaintReceived = CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;

--  Step 3: Populate 'ChurnStatus' column
UPDATE customer_churn
SET ChurnStatus = CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END;

-- Step 4: Verify that the new columns are created and populated correctly
SELECT 
    CustomerID, 
    Complain, 
    ComplaintReceived,
    Churn, 
    ChurnStatus
FROM customer_churn
LIMIT 30;

-- =====================================================================
-- QUESTION 6: COLUMN DROPPING
-- Scenario:
-- The columns 'Churn' and 'Complain' have already been transformed into
-- more descriptive columns ('ChurnStatus' and 'ComplaintReceived').
-- These original binary columns are no longer needed for reporting.
--
-- Task:
--  Drop the columns "Churn" and "Complain" from the table.
-- =====================================================================

--  Step 1: Drop both columns
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

select * from customer_churn limit 30;

-- =====================================================================
--  QUESTION 7: DATA EXPLORATION AND ANALYSIS
-- Scenario:
-- After cleaning and transforming the data, the management wants
-- analytical insights to understand churn patterns and customer behavior.
-- =====================================================================


-- ============================================================
-- 7.1 Retrieve the count of churned and active customers
-- ============================================================

SELECT 
    ChurnStatus,
    COUNT(*) AS Total_Customers
FROM customer_churn
GROUP BY ChurnStatus;

-- ============================================================
-- 7.2 Display the average tenure and total cashback amount
--     of customers who churned
-- ============================================================

SELECT 
    ROUND(AVG(Tenure),2) AS Avg_Tenure_Churned,
    SUM(CashbackAmount) AS Total_Cashback_Churned
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- ============================================================
-- 7.3 Determine the percentage of churned customers who complained
-- ============================================================

SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN ChurnStatus = 'Churned' AND ComplaintReceived = 'Yes' THEN 1 ELSE 0 END)
            / SUM(CASE WHEN ChurnStatus = 'Churned' THEN 1 ELSE 0 END)) * 100, 2
        ),
        '%'
    ) AS Pct_Churned_With_Complaints
FROM customer_churn;

-- ============================================================
-- Verification Step (Optional)
-- ============================================================

-- Check raw counts for better clarity
SELECT 
    SUM(CASE WHEN ChurnStatus = 'Churned' AND ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) AS Churned_Complained,
    SUM(CASE WHEN ChurnStatus = 'Churned' THEN 1 ELSE 0 END) AS Total_Churned
FROM customer_churn;

-- =====================================================================
-- QUESTION 7 ADVANCED DATA EXPLORATION & ANALYSIS
-- Scenario:
-- Further explore churn behavior and purchasing patterns using cleaned data.
-- ============================================================
-- 7.4 City tier with the highest number of churned customers
--     whose preferred order category is 'Laptop & Accessory'
-- ============================================================

SELECT 
    CityTier,
    COUNT(*) AS Total_Churned_Laptop_Customers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY Total_Churned_Laptop_Customers DESC
LIMIT 10;
-- ============================================================
--  7.5 Most preferred payment mode among active customers
-- ============================================================

SELECT 
    PreferredPaymentMode,
    COUNT(*) AS Active_Customers
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY Active_Customers DESC
LIMIT 10;

-- ============================================================
-- 7.6 Total order amount hike from last year for customers
--     who are single and prefer mobile phones for ordering
-- ============================================================

SELECT 
    SUM(OrderAmountHikeFromlastYear) AS Total_Order_Hike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';
-- ============================================================
-- 7.7 Average number of devices registered among customers
--     who used 'UPI' as their preferred payment mode
-- ============================================================

SELECT 
    ROUND(AVG(NumberOfDeviceRegistered),2) AS Avg_Devices_UPI_Users
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';


-- 7.8 Determine the city tier with the highest number of customers
SELECT 
    CityTier,
    COUNT(*) AS Total_Customers
FROM customer_churn
GROUP BY CityTier
ORDER BY Total_Customers DESC
LIMIT 10;

-- 7.9 Identify the gender that utilized the highest number of coupons
SELECT 
    Gender,
    SUM(CouponUsed) AS Total_Coupons_Used
FROM customer_churn
GROUP BY Gender
ORDER BY Total_Coupons_Used DESC
LIMIT 10;

-- 7.10 List the number of customers and maximum hours spent on the app 
--      in each preferred order category
SELECT 
    PreferredOrderCat,
    COUNT(*) AS Total_Customers,
    MAX(HoursSpentOnApp) AS Max_Hours_Spent
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY Total_Customers DESC;

-- 7.11 Calculate the total order count for customers who prefer 
--      using credit cards and have the maximum satisfaction score
SELECT 
    SUM(OrderCount) AS Total_Order_Count
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- 7.12 What is the average satisfaction score of customers who have complained
SELECT 
    ROUND(AVG(SatisfactionScore),2) AS Avg_Satisfaction_Complained
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- 7.13 List the preferred order category among customers who used more than 5 coupons
SELECT 
    PreferredOrderCat,
    COUNT(*) AS Total_Customers
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY Total_Customers DESC;

-- 7.14 List the top 3 preferred order categories with the highest average cashback amount
SELECT 
    PreferredOrderCat,
    ROUND(AVG(CashbackAmount),2) AS Avg_Cashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY Avg_Cashback DESC
LIMIT 3;

-- 7.15 Find the preferred payment modes of customers whose average tenure 
--      is 10 months and have placed more than 500 orders
SELECT 
    PreferredPaymentMode,
    ROUND(AVG(Tenure),2) AS Avg_Tenure,
    SUM(OrderCount) AS Total_Orders
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING Avg_Tenure = 10 AND Total_Orders > 500;

-- 7.16 Categorize customers based on 'WarehouseToHome' distance 
--      and display churn status breakdown for each distance category
SELECT 
    CASE 
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS Total_Customers
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;

-- =====================================================================
--  QUESTION 8: CUSTOMER INSIGHTS & JOINS
-- Scenario:
-- Analyze customer behavior based on marital status, city tier, and order activity,
-- and connect return details with churned customers who made complaints.
-- =====================================================================


-- ============================================================
-- 8.1 List the customer’s order details who are married,
--     live in City Tier-1, and whose order count is greater than
--     the average order count of all customers
-- ============================================================

SELECT 
    CustomerID,
    MaritalStatus,
    CityTier,
    OrderCount,
    PreferredOrderCat,
    PreferredPaymentMode,
    CashbackAmount
FROM customer_churn
WHERE 
    MaritalStatus = 'Married'
    AND CityTier = 1
    AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);

-- ============================================================
-- 8.2 a) Create a 'customer_returns' table in the 'ecomm' database
--         and insert the given data
-- ============================================================

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

-- ============================================================
-- 8.2 b) Display return details with customer details
--         of customers who have churned and have made complaints
-- ============================================================

SELECT 
    cr.ReturnID,
    cr.CustomerID,
    cr.ReturnDate,
    cr.RefundAmount,
    cc.MaritalStatus,
    cc.CityTier,
    cc.PreferredPaymentMode,
    cc.PreferredOrderCat,
    cc.CashbackAmount,
    cc.ChurnStatus,
    cc.ComplaintReceived
FROM customer_returns AS cr
JOIN customer_churn AS cc 
    ON cr.CustomerID = cc.CustomerID
WHERE 
    cc.ChurnStatus = 'Churned'
    AND cc.ComplaintReceived = 'Yes';



















