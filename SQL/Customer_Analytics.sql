--Customer_Analytics


--Q11 Top 10 Customers by Spending
SELECT

    c.customer_unique_id,

    c.customer_state,

    c.customer_city,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(*) AS total_products_purchased,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_spending,

    ROUND(AVG(oi.price::NUMERIC),2) AS average_product_price,

    ROUND(
        SUM(oi.price::NUMERIC)
        /
        COUNT(DISTINCT o.order_id)
    ,2) AS average_order_value,

    ROUND(MAX(oi.price::NUMERIC),2) AS highest_product_price,

    ROUND(MIN(oi.price::NUMERIC),2) AS lowest_product_price

FROM order_items oi

INNER JOIN orders o
ON oi.order_id = o.order_id

INNER JOIN customers c
ON o.customer_id = c.customer_id

GROUP BY

    c.customer_unique_id,
    c.customer_state,
    c.customer_city

ORDER BY

    total_spending DESC

LIMIT 10;


--12 Repeat Customer Analysis
SELECT

    c.customer_unique_id,

    COUNT(o.order_id) AS total_orders,

    MIN(o.order_purchase_timestamp) AS first_order_date,

    MAX(o.order_purchase_timestamp) AS last_order_date

FROM orders o

INNER JOIN customers c
ON o.customer_id = c.customer_id

GROUP BY

    c.customer_unique_id

HAVING

    COUNT(o.order_id) > 1

ORDER BY

    total_orders DESC;



--Q13 Repeat Customer Rate Analysis

WITH customer_orders AS (

    SELECT

        c.customer_unique_id,

        COUNT(o.order_id) AS total_orders

    FROM orders o

    INNER JOIN customers c
    ON o.customer_id = c.customer_id

    GROUP BY
        c.customer_unique_id

)

SELECT

    COUNT(*) AS total_unique_customers,

    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,

    COUNT(*) FILTER (WHERE total_orders = 1) AS one_time_customers,

    ROUND(
        COUNT(*) FILTER (WHERE total_orders > 1)::NUMERIC
        * 100
        /
        COUNT(*)
    ,2) AS repeat_customer_rate

FROM customer_orders;


--Q14 Top 10 Cities by Customer Base


SELECT

    customer_city,

    customer_state,

    COUNT(DISTINCT customer_unique_id) AS total_customers,

    ROUND(
        COUNT(DISTINCT customer_unique_id) * 100.0 /
        (
            SELECT COUNT(DISTINCT customer_unique_id)
            FROM customers
        ),
        2
    ) AS customer_percentage

FROM customers

GROUP BY

    customer_city,
    customer_state

ORDER BY

    total_customers DESC

LIMIT 10;


--Q15 Top 10 States by Customer Base

SELECT

    customer_state,

    COUNT(DISTINCT customer_unique_id) AS total_customers,

    COUNT(DISTINCT customer_city) AS total_cities,

    ROUND(
        COUNT(DISTINCT customer_unique_id) * 100.0 /
        (
            SELECT COUNT(DISTINCT customer_unique_id)
            FROM customers
        ),
        2
    ) AS customer_percentage

FROM customers

GROUP BY

    customer_state

ORDER BY

    total_customers DESC

LIMIT 10;




--16 Top 10 Revenue Generating Cities


SELECT

    c.customer_city,
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue,

    ROUND(
        SUM(oi.price::NUMERIC)
        /
        COUNT(DISTINCT o.order_id)
    ,2) AS average_order_value,

    ROUND(AVG(oi.price::NUMERIC),2) AS average_product_price

FROM order_items oi

INNER JOIN orders o
ON oi.order_id = o.order_id

INNER JOIN customers c
ON o.customer_id = c.customer_id

GROUP BY

    c.customer_city,
    c.customer_state

ORDER BY

    total_revenue DESC

LIMIT 10;
