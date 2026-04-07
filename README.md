# 🍔 Swiggy Sales Data Analysis (SQL Project)

## 📌 Project Overview
This project focuses on analyzing Swiggy food delivery data using SQL. The objective is to transform raw data into meaningful business insights through data cleaning, dimensional modeling, and analytical queries.

---

## 🧹 Data Cleaning & Validation
- Performed null checks across key columns (State, City, Restaurant, etc.)
- Identified blank and inconsistent values
- Detected duplicate records using GROUP BY
- Applied ROW_NUMBER() logic for duplicate removal

---

## 🏗️ Data Modeling (Star Schema)
Designed a Star Schema to optimize analytical performance:

### Dimension Tables:
- dim_date  
- dim_location  
- dim_restaurant  
- dim_category  
- dim_dish  

### Fact Table:
- fact_swiggy_orders  

This structure improves query performance and simplifies reporting.

---

## 📊 KPIs
- Total Orders  
- Total Revenue (INR Million)  
- Average Dish Price  
- Average Rating  

---

## 🔍 Business Insights
- Monthly, Quarterly, and Yearly order trends  
- Top cities by order volume  
- Revenue contribution by state  
- Top-performing restaurants  
- Most ordered dishes and categories  
- Customer spending patterns  
- Rating distribution analysis  

---

## 🛠️ Tools Used
- SQL (MySQL / SQL Server)
- Data Modeling
- Data Analysis


## 🎯 Key Learnings
- Real-world data cleaning techniques  
- Dimensional modeling using Star Schema  
- Writing complex SQL queries for business insights  
