E-Commerce Customer Churn Analysis (MySQL)
📘 Overview

This project explores customer churn analysis within an e-commerce business context, leveraging MySQL for data cleaning, transformation, and analysis.
It demonstrates how to identify factors contributing to customer attrition, using transactional and behavioral data to generate actionable insights that can guide retention strategies and business decision-making.

📂 Repository Structure
📁 E_Commerce_Customer_Churn_Analysis
├── 📄 Ecomm_Assignment_1_Data_Cleaning.sql
├── 📄 Ecomm_Assignment_2_Data_Transformation.sql
├── 📄 Ecomm_Assignment_3_Data_Analysis.sql
├── 📄 Customer_Returns_Table.sql
├── 📘 README.md

💼 Problem Statement

E-commerce businesses often struggle to retain customers due to evolving preferences and market competition.
The goal of this project is to analyze customer churn drivers — such as tenure, satisfaction scores, payment modes, and purchase patterns — to help businesses proactively reduce churn and improve customer engagement.

🧹 1️⃣ Data Cleaning
🔸 Handling Missing Values & Outliers

Imputed mean values for:
WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder.

Imputed mode values for:
Tenure, CouponUsed, OrderCount.

Removed outliers in WarehouseToHome where values exceeded 100 km.

🔸 Dealing with Inconsistencies

Replaced:

“Phone” → “Mobile Phone” (PreferredLoginDevice)

“Mobile” → “Mobile Phone” (PreferedOrderCat)

Standardized payment modes:

“COD” → “Cash on Delivery”

“CC” → “Credit Card”

🔄 2️⃣ Data Transformation

Renamed Columns:

PreferedOrderCat → PreferredOrderCat

HourSpendOnApp → HoursSpentOnApp

Created New Columns:

ComplaintReceived = “Yes” if Complain = 1, else “No”.

ChurnStatus = “Churned” if Churn = 1, else “Active”.

Dropped Columns:

Removed Churn and Complain after transformation.

📊 3️⃣ Data Exploration & Analysis
🔍 Descriptive & Aggregated Insights

Counted churned vs active customers.

Calculated average tenure and total cashback for churned customers.

Determined percentage of churned customers who complained.

Identified city tier with the highest churn in “Laptop & Accessory” orders.

Found most preferred payment mode among active customers.

Analyzed order amount hikes for single mobile-phone users.

Computed average devices registered by UPI users.

Identified top city tier and gender using the highest number of coupons.

Calculated total order count and maximum hours spent per preferred order category.

Listed credit card users with max satisfaction scores and their order totals.

Derived average satisfaction score among customers who complained.

Highlighted top 3 preferred order categories by average cashback.

Created distance-based categories (‘Very Close’, ‘Close’, ‘Moderate’, ‘Far’) and analyzed churn breakdown.

Listed married customers in City Tier-1 with above-average order counts.

🧾 4️⃣ Customer Returns Table
CREATE TABLE customer_returns (
  ReturnID INT PRIMARY KEY,
  CustomerID INT,
  ReturnDate DATE,
  RefundAmount DECIMAL(10,2)
);


Inserted 8 records representing recent customer refunds, then joined with churned and complaining customer data for return pattern analysis.

🎯 Key Outcomes

✅ Built a clean and relational dataset ready for churn analytics.
✅ Identified behavioral factors contributing to churn.
✅ Enhanced data-driven retention strategy formulation for e-commerce.
✅ Demonstrated SQL expertise across DDL, DML, data wrangling, and reporting.

🧰 Tools Used

MySQL Workbench / CLI

Google Sheets / Excel (for data preview)

Power BI (optional) – for post-SQL visualization

🧑‍💻 Author

Developed by Agnes A
A SQL-based analytical project showcasing expertise in data cleaning, transformation, and business insight generation.
