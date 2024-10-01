SELECT SUM(base_msrp)/Count(*) AS avg_base_msrp FROM Products;

SELECT COUNT(DISTINCT state) FROM customers;

/* Avg number of customers in a state */
SELECT COUNT(customer_id):: numeric/ COUNT(DISTINCT state) FROM customers;

/* Calculate lowest, highest and average price, std */

SELECT 

MIN(base_msrp),
MAX(base_msrp),
AVG(base_msrp),
STDDEV(base_msrp)

FROM products;


SELECT DISTINCT state from customers order by 1;

/* How many customers are in each state  */

SELECT state, count(*) FROM customers GROUP BY 1 ORDER BY 1;

/* Customers added per year */

SELECT TO_CHAR(date_added, 'YYYY') AS YEAR, COUNT(*) from customers GROUP BY TO_CHAR(date_added, 'YYYY');

/* Count Female customers in each state */

SELECT state, count(*) from customers where gender = 'F' GROUP BY state order by 2;

/* Determine the sales and number of customers in each state */

SELECT state, count(product_id) from sales join customers using(customer_id) group by state;

SELECT channel, sum(sales_amount), count(*) from sales group by channel;

/* The manager wants statistical analysis on each product type */

SELECT product_type, MIN(base_msrp), MAX(base_msrp), AVG(base_msrp), STDDEV(base_msrp)
FROM products GROUP BY product_type;

/* Using GROUPING SET statement */

SELECT state, gender, count(*) FROM customers GROUP BY GROUPING SETS((state), 
(state, gender)) ORDER BY 1, 2;

/* ORDERED SET aggregate functions is used in cases where the order of a column is 
need like when calculating Median */

/* calculate the median price of the products table - Median is the 50th percentile */

SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY base_msrp) AS median FROM products;

/* Calculate the mode of price, year in products table */

SELECT MODE() WITHIN GROUP (ORDER BY base_msrp) AS Mode_of_price FROM products;

/* The most occuring production year in the products table */
SELECT MODE() WITHIN GROUP (ORDER BY year) AS Mode_of_price FROM products;

/* Show the percentage of missing states in customer table */

SELECT SUM(CASE WHEN state IS NULL OR state = '' THEN 1 ELSE 0 END):: FLOAT/ COUNT(*) 
as missing_values FROM customers;

/* WINDOW FUNCTION */

SELECT customer_id, title, first_name, last_name, count(*) OVER () AS total_customers
FROM customers ORDER BY customer_id;

/* USING PARTITION BY */

SELECT customer_id, title, first_name, last_name, gender, COUNT(*) OVER(PARTITION BY gender) AS total_customers
FROM customers ORDER BY customer_id;

/* Using ORDER BY with the OVER FUNCTION */

/* Once the windows are established, for every value group, the window function 
is calculated based on the window. In this example, this means COUNT is applied 
to every window. */

SELECT customer_id, title, first_name, last_name, gender, 
COUNT(*) OVER(ORDER BY customer_id) AS total_customers
FROM customers;

/* Using both PARTITION BY and ORDER BY */

SELECT customer_id, first_name, ,ast_name, gender, COUNT(*) 
OVER(PARTITION BY gender ORDER BY customer_id) AS total_customers
FROM customers;

/*  The company would like a running total of how many users 
have filled in their street addresses over time. Write a query to 
produce these results. */

SELECT customer_id, date_added:: Date, street_address, 
COUNT(
	CASE WHEN street_address IS NOT NULL THEN customer_id 
	ELSE NULL END
) OVER (ORDER BY date_added:: DATE) AS none_null_streets,
COUNT(*) OVER(ORDER BY date_added:: DATE) AS total_street_address
FROM customers;

/* What is the percentage of null addresses at each date added */

WITH total_rolling_address AS (
	SELECT customer_id, street_address, date_added:: DATE, 
	COUNT(
		CASE WHEN street_address IS NOT NULL THEN customer_id
		ELSE NULL END
	
	) OVER(ORDER BY date_added:: DATE) AS none_null_address,
	COUNT(*) OVER(ORDER BY date_added:: DATE) AS total_street_address
	FROM customers
)

SELECT DISTINCT date_added, none_null_address, total_street_address,
1 - none_null_address::FLOAT/total_street_address AS pct_null_address
FROM total_rolling_address ORDER BY date_added;

/* Using the window clause */
WITH customer_title AS (
SELECT customer_id, title, first_name, last_name, gender,
COUNT(*) OVER w AS total_customers,
SUM(
	CASE WHEN title IS NOT NULL THEN 1 ELSE 0 END
	
) OVER w AS customers_with_title
FROM customers
WINDOW w AS (
	PARTITION BY gender ORDER BY customer_id
)
ORDER BY customer_id
)

/* write a query that will rank the customers 
according to their joining date (date_added) for each state */

SELECT customer_id, first_name, last_name, state,date_added:: DATE,
RANK() OVER (PARTITION BY state ORDER BY date_added) AS customer_ranking
FROM customers;

/* Calcu;ating Rolling AVERAGE */

WITH 
  daily_sales as (
    SELECT 
      sales_transaction_date::DATE,
      SUM(sales_amount) as total_sales
    FROM sales
    GROUP BY 1
  ),
  moving_average_calculation_7 AS (
    SELECT 
      sales_transaction_date, 
      total_sales,
      AVG(total_sales) OVER (
        ORDER BY sales_transaction_date 
        ROWS BETWEEN 6 PRECEDING and CURRENT ROW
      ) AS sales_moving_average_7,
      ROW_NUMBER() OVER (
        ORDER BY sales_transaction_date
      ) as row_number
    FROM 
      daily_sales
    ORDER BY 1
  )
SELECT 
  sales_transaction_date,
  CASE 
    WHEN row_number>=7 THEN sales_moving_average_7 
    ELSE NULL 
  END AS sales_moving_average_7
FROM 
  moving_average_calculation_7;
  
 WITH 
  daily_sales as (
    SELECT 
      sales_transaction_date::DATE,
      SUM(sales_amount) as total_sales
    FROM 
      sales
    GROUP BY
      1
  ),
  sales_stats_30 AS (
    SELECT 
      sales_transaction_date, 
      total_sales,
      MAX(total_sales) OVER (
        ORDER BY sales_transaction_date 
        ROWS BETWEEN 30 PRECEDING and 1 PRECEDING
      ) AS max_sales_30
    FROM 
      daily_sales
    ORDER BY
      1
  )
SELECT 
  sales_transaction_date, 
  total_sales,
  max_sales_30
FROM 
  sales_stats_30
WHERE
  sales_transaction_date>='2019-01-01';

-- Step 3
WITH 
  daily_sales as (
    SELECT 
      sales_transaction_date::DATE,
      SUM(sales_amount) as total_sales
    FROM sales
    GROUP BY 1
  ),
  sales_stats_30 AS (
    SELECT 
      sales_transaction_date, 
      total_sales,
      MAX(total_sales) OVER (
        ORDER BY sales_transaction_date 
        ROWS BETWEEN 30 PRECEDING and 1 PRECEDING
      ) AS max_sales_30
    FROM 
      daily_sales
    ORDER BY 1
  )
SELECT 
  sales_transaction_date, 
  total_sales,
  max_sales_30
FROM 
  sales_stats_30
WHERE
  total_sales > max_sales_30 
AND
  sales_transaction_date>='2019-01-01';

 