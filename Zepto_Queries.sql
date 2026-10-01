DROP TABLE IF EXISTS zepto;

-- Creates the Zepto products table with columns for product details, pricing, discounts, stock availability, quantity, and weight.

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

-- DATA EXPLORATION

-- Counts the total number of product records in the table.
SELECT COUNT(*) FROM zepto;

-- Displays the first 10 records to quickly understand the dataset.
SELECT * FROM zepto LIMIT 10;

-- Checks whether important product columns contain any NULL values.
SELECT * FROM zepto
WHERE name IS NULL
OR category IS NULL
OR mrp IS NULL
OR discountPercent IS NULL
OR discountedSellingPrice IS NULL
OR weightInGms IS NULL
OR availableQuantity IS NULL
OR outOfStock IS NULL
OR quantity IS NULL;

-- Lists all unique product categories available in the dataset.
SELECT DISTINCT category FROM zepto ORDER BY category;

-- Shows how many products are currently in stock and out of stock.
SELECT outOfStock, COUNT(sku_id) FROM zepto GROUP BY outOfStock;

-- Identifies product names that have multiple SKUs in the dataset.
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING

-- Finds products where MRP or discounted selling price is zero.
SELECT * FROM zepto WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Removes products with an MRP value of zero.
DELETE FROM zepto WHERE mrp = 0;

-- Converts MRP and selling prices from paise to rupees.
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

-- Verifies the updated MRP and selling prices after conversion.
SELECT mrp, discountedSellingPrice FROM zepto;

-- DATA ANALYSIS

-- Q1. Finds the top 10 products offering the highest discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2. Finds high-priced products (MRP above ₹300) that are currently out of stock.
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE
AND mrp > 300
ORDER BY mrp DESC;

-- Q3. Estimates potential revenue for each category
-- using discounted price multiplied by available quantity.
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Finds products with high MRP (above ₹500)
-- but with a relatively low discount (less than 10%).
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500
AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;


-- Q5. Finds the top 5 categories with the highest average discount.
SELECT category,
ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Calculate the price per gram for products weighing at least 100g.
-- Lower price per gram indicates better value for money.
SELECT DISTINCT 
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(
        discountedSellingPrice / NULLIF(weightInGms, 0),
        2
    ) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7. Classifies products into Low, Medium, and Bulk categories
-- based on their weight using a CASE statement.
SELECT DISTINCT name, weightInGms,
CASE
    WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
END AS weight_category
FROM zepto;

-- Q8. Calculates the total inventory weight available in each category.
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;