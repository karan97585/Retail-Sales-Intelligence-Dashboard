
--Sales_Analytics


--Q6 Which Product Categories Generate the Highest Revenue?
SELECT
    ct.product_category_name_english,
    ROUND(SUM(oi.price::NUMERIC), 2) AS total_revenue

FROM order_items oi

INNER JOIN products p
ON oi.product_id = p.product_id

INNER JOIN category_translation ct
ON p.product_category_name = ct.product_category_name

GROUP BY
    ct.product_category_name_english
ORDER BY
    total_revenue DESC
LIMIT 10;


--Q7 Top 10 Revenue Generating Products

SELECT
    oi.product_id,
    ct.product_category_name_english AS category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue,

    ROUND(AVG(oi.price::NUMERIC),2) AS average_price,

    ROUND(MAX(oi.price::NUMERIC),2) AS highest_price,

    ROUND(MIN(oi.price::NUMERIC),2) AS lowest_price

FROM order_items oi

INNER JOIN products p
ON oi.product_id = p.product_id

INNER JOIN category_translation ct
ON p.product_category_name = ct.product_category_name

GROUP BY
    oi.product_id,
    ct.product_category_name_english

ORDER BY
    total_revenue DESC

LIMIT 10;



--Q8 Top 10 Revenue Generating Sellers
SELECT

    oi.seller_id,

    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS total_products_sold,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue,

    ROUND(AVG(oi.price::NUMERIC),2) AS average_product_price,

    ROUND(MAX(oi.price::NUMERIC),2) AS highest_product_price,

    ROUND(MIN(oi.price::NUMERIC),2) AS lowest_product_price

FROM order_items oi

INNER JOIN sellers s
ON oi.seller_id = s.seller_id

GROUP BY

    oi.seller_id,
    s.seller_state

ORDER BY

    total_revenue DESC

LIMIT 10;


--Q9 Top Revenue Generating States
SELECT

    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue,

    ROUND(AVG(oi.price::NUMERIC),2) AS average_product_price,

    ROUND(SUM(oi.price::NUMERIC) /
          COUNT(DISTINCT o.order_id),2) AS average_order_value,

    ROUND(MAX(oi.price::NUMERIC),2) AS highest_product_price,

    ROUND(MIN(oi.price::NUMERIC),2) AS lowest_product_price

FROM order_items oi

INNER JOIN orders o
ON oi.order_id = o.order_id

INNER JOIN customers c
ON o.customer_id = c.customer_id

GROUP BY
    c.customer_state

ORDER BY
    total_revenue DESC

LIMIT 10;



--Q10 Monthly Revenue Trend Analysis
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP) AS month,
	
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue,

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

    DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP)

ORDER BY

    month;