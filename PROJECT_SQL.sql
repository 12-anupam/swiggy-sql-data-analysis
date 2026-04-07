SELECT * FROM swiggy;

-- Data Cleaning and Validation
-- Null Check
SELECT 
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_count_rating
FROM swiggy;

-- Blank or Empty Strings
SELECT *
FROM swiggy
WHERE 
State = '' OR City = '' OR Restaurant_Name = '' OR Location = '' OR Category = '' OR Dish_name = '';


-- Duplicate records Check
SELECT 
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_name, Price_INR, Rating, Rating_Count
, COUNT(*) AS CNT
FROM swiggy
GROUP BY 
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_name, Price_INR, Rating, Rating_Count
HAVING COUNT(*) > 1;
-- ALTERNATIVE OF ABOVE QUERY.
SELECT * , COUNT(*) AS CNT
FROM SWIGGY
GROUP BY State, City, Order_Date, Restaurant_Name, Location, Category, Dish_name, Price_INR, Rating, Rating_Count
HAVING COUNT(*) > 1;

-- DELETE DUPLICATE RECORDS
WITH CTE AS(
SELECT *, ROW_NUMBER() Over(
	PARTITION BY State, City, Order_Date, Restaurant_Name, Location, Category, Dish_name, Price_INR, Rating, Rating_Count
    ORDER BY (SELECT NULL)
) AS rn
FROM swiggy
)
DELETE FROM CTE WHERE rn>1; -- this query does not work in mysql


-- Dimensional Modelling
-- Creating different dimension tables
--Creating Schema
-- Date Table
CREATE TABLE dim_date(
	Date_id INT IDENTITY(1,1) PRIMARY KEY, -- IDENTITY(MSSQL) IS SAME AS AUTO_INCREMENT(MYSQL)
	Full_date DATE,
	Year INT,
	Month INT,
	Month_name VARCHAR(20),
	Quarter INT,
	Day INT,
	Week INT
);

-- DIM_LOCATION
CREATE TABLE dim_location (
	Location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);

-- DIM_RESTAURANT
CREATE TABLE dim_restaurant (
	Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_name VARCHAR(100)
);

-- DIM_CATEGORY
CREATE TABLE dim_category (
	Category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200)
);

-- rename the category column
--EXEC sp_rename 'dim_category.Categroy_id', 'Category_id', 'COLUMN';

-- DIM_DISH
CREATE TABLE dim_dish (
	Dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_name VARCHAR(200)
);

-- FACT TABLE
CREATE TABLE fact_swiggy_orders (
	Order_id INT IDENTITY(1,1) PRIMARY KEY,

	Date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL(4,2),
	Rating_Count INT,

	Location_id INT,
	Restaurant_id INT,
	Category_id INT,
	Dish_id INT,

	FOREIGN KEY (Date_id) REFERENCES dim_date(Date_id),
	FOREIGN KEY (Location_id) REFERENCES dim_location(Location_id),
	FOREIGN KEY (Restaurant_id) REFERENCES dim_restaurant(Restaurant_id),
	FOREIGN KEY (Category_id) REFERENCES dim_category(Category_id),
	FOREIGN KEY (Dish_id) REFERENCES dim_dish(Dish_id)
);

select * from fact_swiggy_orders;


-- insert data into table
-- dim_date
INSERT INTO dim_date(Full_date, Year, Month, Month_name, Quarter, Day, Week)
SELECT DISTINCT	
	Order_date,
	YEAR(Order_date),
	MONTH(Order_date),
	DATENAME(MONTH, Order_date),
	DATEPART(QUARTER, Order_date),
	DAY(Order_date),
	DATEPART(WEEK, Order_date)
FROM swiggy
WHERE Order_Date IS NOT NULL;


SELECT * FROM dim_date;

--dim_location
INSERT INTO dim_location( State, City, Location)
SELECT DISTINCT	
	State,
	City,
	Location
FROM swiggy;

SELECT * FROM dim_location;

-- dim_restaurant
INSERT INTO dim_restaurant(Restaurant_name)
SELECT DISTINCT
	Restaurant_name
FROM swiggy;

SELECT * FROM dim_restaurant;

-- dim_category
INSERT INTO dim_category(Category)
SELECT DISTINCT
	Category
FROM swiggy;
SELECT * FROM dim_category;

-- dim_dish
INSERT INTO dim_dish(Dish_name)
SELECT DISTINCT
	Dish_Name
FROM swiggy;
SELECT * FROM dim_dish;


-- fact_table
INSERT INTO fact_swiggy_orders
(
	Date_id,
	Price_INR,
	Rating,
	Rating_Count,
	Location_id,
	Restaurant_id,
	Category_id,
	Dish_id
)
SELECT 
	dd.Date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,

	dl.Location_id,
	dr.Restaurant_id,
	dc.Category_id,
	dsh.Dish_id
FROM swiggy s

JOIN dim_date dd
	ON dd.Full_date = s.Order_date	

JOIN dim_location dl
	ON dl.State = s.State
	AND dl.City = s.City
	AND dl.Location = s.Location

JOIN dim_restaurant dr
	ON dr.Restaurant_name = s.Restaurant_name

JOIN dim_category dc
	ON dc.Category = s.Category

JOIN dim_dish dsh
	ON dsh.Dish_Name = s.Dish_Name;

SELECT * FROM fact_swiggy_orders;

SELECT * 
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_id = d.Date_id
JOIN dim_location l ON f.Location_id = l.Location_id
JOIN dim_restaurant r ON f.Restaurant_id = r.Restaurant_id
JOIN dim_category c ON f.Category_id = c.Category_id
JOIN dim_dish di ON f.Dish_id = di.Dish_id;



-- KPIs

-- Total Orders
SELECT COUNT(Order_id) AS Total_Orders FROM fact_swiggy_orders;

-- Total Revenue
SELECT 
FORMAT(SUM(CONVERT(FLOAT, Price_INR))/ 1000000, 'N2') + 'INR Million'
AS Total_Revenue 
FROM fact_swiggy_orders;

-- Average Dish Price
SELECT 
FORMAT(AVG(CONVERT(FLOAT, Price_INR)), 'N2') + 'INR'
AS Total_Revenue 
FROM fact_swiggy_orders;

-- Average Rating
SELECT
AVG(Rating) AS Average_rating
FROM fact_swiggy_orders;

-- Granular Requirements

-- Deep-Dive-Business-Analysis
-- Monthly Order Trends
SELECT 
d.Year,
d.Month,
d.Month_name,
COUNT(*) AS Total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_id = d.Date_id
GROUP BY 
d.Year,
d.Month,
d.Month_name
ORDER BY COUNT(*) DESC;

-- Quarterly Trend
SELECT 
d.Year,
d.Quarter,
COUNT(*) AS Total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_id = d.Date_id
GROUP BY 
d.Year,
d.Quarter
ORDER BY COUNT(*) DESC;

-- Yearly Trend
SELECT 
d.Year,
COUNT(*) AS Total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.Date_id = d.Date_id
GROUP BY 
d.Year
ORDER BY COUNT(*) DESC;

-- Orders by Day of Week (Mon-Sun)
SELECT
    DATENAME(WEEKDAY, d.full_date) AS day_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date), DATEPART(WEEKDAY, d.full_date)
ORDER BY DATEPART(WEEKDAY, d.full_date);


-- Location Based Analysis
-- Top 10 Cities by Order Volume;
SELECT TOP 10
dl.City,
COUNT(Order_id) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_location dl ON dl.Location_id = f.Location_id  
GROUP BY dl.City
ORDER BY COUNT(Order_id) DESC;


-- Revenue Contribution by States
SELECT
dl.State,
FORMAT(SUM(CONVERT(FLOAT, Price_INR))/ 1000000, 'N2') + 'INR Million' AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location dl ON dl.Location_id = f.Location_id  
GROUP BY dl.State
ORDER BY COUNT(Order_id) DESC;

-- Top 10 restaurant By orders
SELECT TOP 10
dr.Restaurant_name,
COUNT(Order_id) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_restaurant dr ON dr.Restaurant_id = f.Restaurant_id 
GROUP BY dr.Restaurant_name
ORDER BY COUNT(Order_id) DESC;

-- Top Categories
SELECT 
dc.Category,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_category dc ON dc.Category_id = f.Category_id
GROUP BY dc.Category
ORDER BY COUNT(*) DESC;

-- Most Order dish
SELECT TOP 10
d.Dish_name,
COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_dish d ON d.Dish_id = f.Dish_id 
GROUP BY d.Dish_name
ORDER BY COUNT(*) DESC;

-- Cuisine Performance
SELECT
c.Category,
COUNT(*) AS Total_Orders,
AVG(CONVERT(FLOAT, f.Rating)) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c ON f.Category_id = c.Category_id 
GROUP BY c.Category
ORDER BY COUNT(*) DESC;


-- Total Orders By Price Range
SELECT
  CASE
    WHEN CONVERT(FLOAT, Price_INR) < 100 THEN 'Under 100'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 100 AND 199 THEN '100 - 199'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 200 AND 299 THEN '200 - 299'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 300 AND 499 THEN '300 - 499'
    ELSE '500+'
  END AS price_range,
  COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY
  CASE
    WHEN CONVERT(FLOAT, Price_INR) < 100 THEN 'Under 100'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 100 AND 199 THEN '100 - 199'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 200 AND 299 THEN '200 - 299'
    WHEN CONVERT(FLOAT, Price_INR) BETWEEN 300 AND 499 THEN '300 - 499'
    ELSE '500+'
  END
ORDER BY total_orders DESC;

-- Rating Count Dsitribution (1-5)
SELECT
    Rating,
    COUNT(*) AS rating_count
FROM fact_swiggy_orders
GROUP BY Rating
ORDER BY Rating;
