/* =========================================================
   SWIGGY DATA WAREHOUSE PROJECT
   Author : Santhosh
   Database : PostgreSQL
   Description : Data Cleaning + Star Schema + Analysis
========================================================= */


/* =========================================================
   1. CREATE RAW TABLE
========================================================= */

DROP TABLE IF EXISTS swiggy_orders;

CREATE TABLE swiggy_orders (
    state TEXT,
    city TEXT,
    order_date DATE,
    restaurant_name TEXT,
    location TEXT,
    category TEXT,
    dish_name TEXT,
    price_inr NUMERIC,
    rating NUMERIC,
    rating_count INT
);

SELECT * FROM swiggy_orders;



/* =========================================================
   2. DATA CLEANING
========================================================= */

----- CHECK NULLS

SELECT
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_null,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_null,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS date_null,
    SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS restaurant_null,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS location_null,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_null,
    SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS dish_null,
    SUM(CASE WHEN price_inr IS NULL THEN 1 ELSE 0 END) AS price_null,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_null,
    SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS rating_count_null
FROM swiggy_orders;


----- CHECK BLANKS

SELECT *
FROM swiggy_orders
WHERE
    state = ''
    OR city = ''
    OR restaurant_name = ''
    OR location = ''
    OR category = ''
    OR dish_name = '';



----- CHECK DUPLICATES

SELECT
    state, city, order_date, restaurant_name, location,
    category, dish_name, price_inr, rating, rating_count,
    COUNT(*) AS cnt
FROM swiggy_orders
GROUP BY
    state, city, order_date, restaurant_name, location,
    category, dish_name, price_inr, rating, rating_count
HAVING COUNT(*) > 1;



----- DELETE DUPLICATES

WITH cte AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY
                state, city, order_date,
                restaurant_name, location,
                category, dish_name,
                price_inr, rating, rating_count
            ORDER BY ctid
        ) AS rn
    FROM swiggy_orders
)

DELETE FROM swiggy_orders
USING cte
WHERE swiggy_orders.ctid = cte.ctid
AND cte.rn > 1;



/* =========================================================
   3. DIMENSION TABLES
========================================================= */

----- DATE

CREATE TABLE dim_date (
    date_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    day INT,
    week INT
);


----- LOCATION

CREATE TABLE dim_location (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    state VARCHAR(200),
    city VARCHAR(200),
    location VARCHAR(200)
);


----- RESTAURANT

CREATE TABLE dim_restaurant (
    restaurant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_name VARCHAR(200)
);


----- CATEGORY

CREATE TABLE dim_category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category VARCHAR(200)
);


----- DISH

CREATE TABLE dim_dish (
    dish_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dish_name VARCHAR(200)
);



/* =========================================================
   4. FACT TABLE
========================================================= */

CREATE TABLE fact_swiggy_orders (

    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    date_id INT,
    price_inr NUMERIC(10,2),
    rating NUMERIC(4,2),
    rating_count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)

);



/* =========================================================
   5. LOAD DIM TABLES
========================================================= */

INSERT INTO dim_date
(full_date, year, month, month_name, quarter, day, week)

SELECT DISTINCT
    order_date,
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Month'),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(DAY FROM order_date),
    EXTRACT(WEEK FROM order_date)
FROM swiggy_orders;



INSERT INTO dim_location (state, city, location)
SELECT DISTINCT state, city, location
FROM swiggy_orders;



INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT restaurant_name
FROM swiggy_orders;



INSERT INTO dim_category (category)
SELECT DISTINCT category
FROM swiggy_orders;



INSERT INTO dim_dish (dish_name)
SELECT DISTINCT dish_name
FROM swiggy_orders;



/* =========================================================
   6. LOAD FACT TABLE
========================================================= */

INSERT INTO fact_swiggy_orders (

    date_id,
    price_inr,
    rating,
    rating_count,

    location_id,
    restaurant_id,
    category_id,
    dish_id
)

SELECT
    dd.date_id,
    s.price_inr,
    s.rating,
    s.rating_count,

    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    di.dish_id

FROM swiggy_orders s

JOIN dim_date dd
ON dd.full_date = s.order_date

JOIN dim_location dl
ON dl.state = s.state
AND dl.city = s.city
AND dl.location = s.location

JOIN dim_restaurant dr
ON dr.restaurant_name = s.restaurant_name

JOIN dim_category dc
ON dc.category = s.category

JOIN dim_dish di
ON di.dish_name = s.dish_name;



/* =========================================================
   7. ANALYSIS QUERIES
========================================================= */

----- TOTAL ORDERS

SELECT COUNT(*) AS total_orders
FROM fact_swiggy_orders;



----- TOTAL REVENUE

SELECT ROUND(SUM(price_inr)/1000000, 2) AS total_revenue_million
FROM fact_swiggy_orders;



----- MONTHLY TREND

SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(f.order_id) AS orders
FROM fact_swiggy_orders f
JOIN dim_date dd
ON f.date_id = dd.date_id
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.month;



----- TOP CITIES

SELECT
    dl.city,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location dl
ON f.location_id = dl.location_id
GROUP BY dl.city
ORDER BY total_orders DESC
LIMIT 10;



----- TOP RESTAURANTS

SELECT
    dr.restaurant_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_restaurant dr
ON f.restaurant_id = dr.restaurant_id
GROUP BY dr.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;



----- PRICE SEGMENT

SELECT
    CASE
        WHEN price_inr < 100 THEN 'UNDER 100'
        WHEN price_inr BETWEEN 100 AND 199 THEN '100-200'
        WHEN price_inr BETWEEN 200 AND 399 THEN '200-400'
        WHEN price_inr BETWEEN 400 AND 499 THEN '400-500'
        ELSE '500+'
    END AS price_range,

    COUNT(*) AS total_orders

FROM fact_swiggy_orders

GROUP BY price_range
ORDER BY total_orders DESC;
