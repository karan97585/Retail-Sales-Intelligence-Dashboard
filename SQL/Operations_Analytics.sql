--Operations_Analytics


--Q17 Product Categories Needing Quality Improvement


SELECT

    ct.product_category_name_english AS category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS total_reviews,

    ROUND(AVG(orv.review_score::NUMERIC),2) AS average_rating,

    COUNT(*) FILTER (
        WHERE orv.review_score::NUMERIC <= 2
    ) AS low_rating_reviews,

    ROUND(

        COUNT(*) FILTER (
            WHERE orv.review_score::NUMERIC <= 2
        ) * 100.0

        /

        COUNT(*)

    ,2) AS low_rating_percentage

FROM products p

INNER JOIN order_items oi
ON p.product_id = oi.product_id

INNER JOIN order_reviews orv
ON oi.order_id = orv.order_id

INNER JOIN category_translation ct
ON p.product_category_name = ct.product_category_name

GROUP BY

    ct.product_category_name_english

HAVING

    COUNT(*) >= 30

ORDER BY

    low_rating_percentage DESC,
    average_rating ASC;

	

--Q18 Average Delivery Time by State

SELECT

    c.customer_state,

    COUNT(o.order_id) AS total_orders,

    ROUND(

        AVG(

            o.order_delivered_customer_date::DATE
            -
            o.order_purchase_timestamp::DATE

        )

    ,2) AS avg_delivery_days,

    MIN(

        o.order_delivered_customer_date::DATE
        -
        o.order_purchase_timestamp::DATE

    ) AS fastest_delivery_days,

    MAX(

        o.order_delivered_customer_date::DATE
        -
        o.order_purchase_timestamp::DATE

    ) AS slowest_delivery_days

FROM orders o

INNER JOIN customers c
ON o.customer_id = c.customer_id

WHERE

    o.order_status = 'delivered'

AND

    o.order_delivered_customer_date IS NOT NULL

GROUP BY

    c.customer_state

ORDER BY

    avg_delivery_days ASC;


--Q19 Late Delivery Analysis by State

SELECT

    c.customer_state,

    COUNT(o.order_id) AS total_delivered_orders,

    COUNT(*) FILTER (

        WHERE o.order_delivered_customer_date::DATE >
              o.order_estimated_delivery_date::DATE

    ) AS late_deliveries,

    ROUND(

        COUNT(*) FILTER (

            WHERE o.order_delivered_customer_date::DATE >
                  o.order_estimated_delivery_date::DATE

        ) * 100.0

        /

        COUNT(*)

    ,2) AS late_delivery_percentage

FROM orders o

INNER JOIN customers c
ON o.customer_id = c.customer_id

WHERE

    o.order_status = 'delivered'

AND

    o.order_delivered_customer_date IS NOT NULL

GROUP BY

    c.customer_state

ORDER BY

    late_delivery_percentage DESC;



--Q20 Early Delivery Performance by State


SELECT

    c.customer_state,

    COUNT(o.order_id) AS total_delivered_orders,

    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date::DATE <
              o.order_estimated_delivery_date::DATE
    ) AS early_deliveries,

    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date::DATE <
                  o.order_estimated_delivery_date::DATE
        ) * 100.0
        /
        COUNT(*)
    ,2) AS early_delivery_percentage,

    ROUND(
        AVG(
            o.order_estimated_delivery_date::DATE -
            o.order_delivered_customer_date::DATE
        )
    ,2) AS average_days_early

FROM orders o

INNER JOIN customers c
ON o.customer_id = c.customer_id

WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY

    c.customer_state

ORDER BY

    early_delivery_percentage DESC,
    average_days_early DESC;


--Q21 Seller Cancellation Rate Analysis


SELECT

    oi.seller_id,

    s.seller_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_status = 'canceled'
    ) AS cancelled_orders,

    ROUND(

        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_status = 'canceled'
        ) * 100.0

        /

        COUNT(DISTINCT o.order_id)

    ,2) AS cancellation_rate

FROM orders o

INNER JOIN order_items oi
ON o.order_id = oi.order_id

INNER JOIN sellers s
ON oi.seller_id = s.seller_id

GROUP BY

    oi.seller_id,
    s.seller_state

HAVING

    COUNT(DISTINCT o.order_id) >= 20

ORDER BY

    cancellation_rate DESC,
    cancelled_orders DESC;


--Q22 Product Category Cancellation Rate Analysis


SELECT

    ct.product_category_name_english AS category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_status = 'canceled'
    ) AS cancelled_orders,

    ROUND(

        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_status = 'canceled'
        ) * 100.0

        /

        COUNT(DISTINCT o.order_id)

    ,2) AS cancellation_rate

FROM orders o

INNER JOIN order_items oi
ON o.order_id = oi.order_id

INNER JOIN products p
ON oi.product_id = p.product_id

INNER JOIN category_translation ct
ON p.product_category_name = ct.product_category_name

GROUP BY

    ct.product_category_name_english

HAVING

    COUNT(DISTINCT o.order_id) >= 30

ORDER BY

    cancellation_rate DESC,
    cancelled_orders DESC;
