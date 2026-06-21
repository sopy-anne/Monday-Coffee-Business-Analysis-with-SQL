-- Question 1: Cofee consumer estimate
-- Objective: to identify the 25% of each city's coffee consumers in millions

SELECT
    city_name,
    ROUND((population * 0.25) / 1000000, 4) AS city_consumers_millions
FROM city
ORDER BY city_consumers_millions DESC;

-- Question 2: Total Revenue - Q4 2023
-- Objective: to indicate the total revenue across the cities in Q4 2023

SELECT
    c.city_name,
    ROUND(SUM(s.total)::numeric, 2) AS total_revenue_Q4
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
  AND EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY c.city_name
ORDER BY total_revenue_Q4 DESC;

-- Question 3 - Sales Volume by Product
-- Objective: to identify how many and which units were sold per product

SELECT
	p.product_name,
	COUNT(s.sale_id) AS units_sold
FROM sales s
JOIN products p
	ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;

-- Question 4: Average sales per customer by city
-- Objective: to idenitfy the total revenue and average sales per unique customers in each city 

SELECT
	c.city_name,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT s.customer_id) AS No_of_Customers,
    ROUND(SUM(s.total)/COUNT(DISTINCT s.customer_id),2) AS avg_sale_per_customer
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
GROUP BY c.city_name
ORDER BY no_of_customers DESC;

-- Question 5: Current customers vs estimated coffee consumers
/** Objective: identify the 25% of the estimated coffee consumers 
and the actual coffee consumers in each city **/

WITH consumers_per_city AS (
    SELECT
        city_id,
        city_name,
        ROUND((population * 0.25) / 1000000,4) AS estimated_consumers_millions
    FROM city
)
SELECT
    cc.city_name,
    cc.estimated_consumers_millions,
    COUNT(DISTINCT s.customer_id) 
	AS actual_customers
FROM consumers_per_city cc
LEFT JOIN customer cs
    ON cc.city_id = cs.city_id
LEFT JOIN sales s
    ON cs.customer_id = s.customer_id
GROUP BY
    cc.city_name,
    cc.estimated_consumers_millions
ORDER BY actual_customers DESC;

-- Question 6: Top Three Products per City
-- Objective: identify the top 3 products ordered in each city

WITH ranked AS (
    SELECT
        c.city_name,
        p.product_name,
        COUNT(s.sale_id) AS no_of_orders,
		RANK() OVER (PARTITION BY c.city_name 
		ORDER BY COUNT(s.sale_id) DESC) 
		AS ranks
    FROM sales s
    JOIN customer cs
        ON s.customer_id = cs.customer_id
    JOIN city c
        ON cs.city_id = c.city_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        c.city_name,
        p.product_name
)
SELECT
    city_name,
    product_name,
    no_of_orders,
    ranks
FROM ranked
WHERE ranks <= 3
ORDER BY city_name, ranks;

-- Question 7: Unique Customers per City
-- Objective: to identify the unique customers in each city with at least one coffee order
SELECT
    c.city_id,
    c.city_name,
    COUNT(DISTINCT s.customer_id) AS unique_customers
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
GROUP BY
    c.city_id,
    c.city_name
ORDER BY unique_customers DESC;

-- Question 8: Average sales vs Average rent per customer
-- Objective: to compare the average sales and rent cost per customer in each city

SELECT
    c.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) 
	AS average_sale_per_customer,
    ROUND(c.estimated_rent / COUNT(DISTINCT s.customer_id), 2) 
	AS average_rent_per_customer
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
GROUP BY
    c.city_name,
    c.estimated_rent
ORDER BY average_sale_per_customer DESC;

-- Question 9: Month on month sales growth
/** Objective: To calculate the montly % changes on total sales across each city 
using LAG and CTE **/

WITH monthly_sales AS (
    SELECT
        c.city_name,
        DATE_TRUNC('month', s.sale_date) AS sales_month,
        SUM(s.total) AS monthly_revenue
    FROM sales s
    JOIN customer cs
        ON s.customer_id = cs.customer_id
    JOIN city c
        ON cs.city_id = c.city_id
    GROUP BY
        c.city_name,
        sales_month
),
month_on_month AS (
    SELECT
        city_name,
        sales_month,
        ROUND(monthly_revenue::numeric, 2) AS revenue,
        ROUND((monthly_revenue - LAG(monthly_revenue) 
			OVER (PARTITION BY city_name 
			ORDER BY sales_month))/LAG(monthly_revenue) 
			OVER (PARTITION BY city_name 
			ORDER BY sales_month)* 100,2) 
			AS monthly_perc_changes
    FROM monthly_sales
)
SELECT *
FROM month_on_month
WHERE monthly_perc_changes IS NOT NULL
ORDER BY city_name, sales_month;

--Question 10: Market potential summary
-- Objective to create a summary table on key indicators

SELECT
    c.city_name,
    SUM(s.total) AS total_revenue,
    c.estimated_rent,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND((c.population * 0.25) / 1000000, 4) 
	AS estimated_consumers_millions,
    ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) 
	AS average_sale_per_customer,
    ROUND(c.estimated_rent / COUNT(DISTINCT s.customer_id), 2) 
	AS average_rent_per_customer
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
GROUP BY
    c.city_name,
    c.estimated_rent,
    c.population
ORDER BY total_revenue DESC;

--Bonus Question
-- Question 1: identify the cities with the highest average customer rating?

SELECT
    c.city_name,
    ROUND(AVG(s.rating),2) AS avg_rating,
    COUNT(s.sale_id) AS total_orders
FROM sales s
JOIN customer cs
    ON s.customer_id = cs.customer_id
JOIN city c
    ON cs.city_id = c.city_id
GROUP BY c.city_name
ORDER BY avg_rating DESC;

/** Interpretation: Cities with high ratings may indicate stronger customer 
loyalty and a better chance of success for physical stores. **/

-- Question 2
-- Which coffee products contribute  to generate the most revenue?

SELECT
    p.product_name,
    ROUND(SUM(s.total),2) AS revenue_generated,
    COUNT(s.sale_id) AS total_orders
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_generated DESC;

/** Interpretation: These products should receive priority shelf space 
and marketing attention in future stores. **//

-- Question 3: Who are the highest-value customers?

SELECT
    cs.customer_id,
    cs.customer_name,
    c.city_name,

    ROUND(SUM(s.total),2) AS lifetime_spend,

    COUNT(s.sale_id) AS total_orders

FROM sales s

JOIN customer cs
    ON s.customer_id = cs.customer_id

JOIN city c
    ON cs.city_id = c.city_id

GROUP BY
    cs.customer_id,
    cs.customer_name,
    c.city_name

ORDER BY lifetime_spend DESC
LIMIT 20;


/** Interpretation: These customers represent Monday Coffee's most 
valuable buyers and could be targeted for loyalty programs 
when physical stores launch. **/
