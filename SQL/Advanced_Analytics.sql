--Advanced_Analytics


--Q23 Delivery Time vs Customer Rating Analysis


SELECT

    CASE

        WHEN (
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ) <= 5 THEN '0-5 Days'

        WHEN (
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ) <= 10 THEN '6-10 Days'

        WHEN (
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ) <= 15 THEN '11-15 Days'

        ELSE '16+ Days'

    END AS delivery_time_group,

    COUNT(o.order_id) AS total_orders,

    ROUND(
        AVG(orv.review_score::NUMERIC),
        2
    ) AS average_rating,

    ROUND(
        AVG(
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ),
        2
    ) AS avg_delivery_days

FROM orders o

INNER JOIN order_reviews orv
ON o.order_id = orv.order_id

WHERE

    o.order_status = 'delivered'

AND o.order_delivered_customer_date IS NOT NULL

GROUP BY

    delivery_time_group

ORDER BY

    avg_delivery_days;


--Q24 Customer Segmentation by Revenue

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue

    FROM customers c

    INNER JOIN orders o
    ON c.customer_id = o.customer_id

    INNER JOIN order_items oi
    ON o.order_id = oi.order_id

    GROUP BY

        c.customer_unique_id

)

SELECT

    CASE

        WHEN total_revenue >= 5000 THEN 'VIP Customer'

        WHEN total_revenue >= 2000 THEN 'Premium Customer'

        WHEN total_revenue >= 500 THEN 'Regular Customer'

        ELSE 'Budget Customer'

    END AS customer_segment,

    COUNT(*) AS total_customers,

    ROUND(AVG(total_revenue),2) AS avg_customer_revenue,

    ROUND(SUM(total_revenue),2) AS segment_revenue

FROM customer_revenue

GROUP BY

    customer_segment

ORDER BY

    segment_revenue DESC;



--Q25 RFM (Recency, Frequency, Monetary) Analysis

WITH rfm AS (

SELECT

    c.customer_unique_id,

    MAX(o.order_purchase_timestamp::DATE) AS last_purchase_date,

    (
        SELECT MAX(order_purchase_timestamp::DATE)
        FROM orders
    ) - MAX(o.order_purchase_timestamp::DATE) AS recency,

    COUNT(DISTINCT o.order_id) AS frequency,

    ROUND(SUM(oi.price::NUMERIC),2) AS monetary

FROM customers c

INNER JOIN orders o
ON c.customer_id = o.customer_id

INNER JOIN order_items oi
ON o.order_id = oi.order_id

GROUP BY

    c.customer_unique_id

)

SELECT

    customer_unique_id,

    recency,

    frequency,

    monetary,

    CASE

        WHEN recency <= 30
             AND frequency >= 5
             AND monetary >= 1000

        THEN 'Champions'

        WHEN recency <= 60
             AND frequency >= 3

        THEN 'Loyal Customers'

        WHEN recency > 180

        THEN 'At Risk'

        ELSE 'Regular Customers'

    END AS customer_segment

FROM rfm

ORDER BY

    monetary DESC;


--Q26 Customer Lifetime Value (CLV)


WITH customer_summary AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(SUM(oi.price::NUMERIC),2) AS lifetime_revenue,

        ROUND(
            SUM(oi.price::NUMERIC)
            /
            COUNT(DISTINCT o.order_id)
        ,2) AS avg_order_value,

        MIN(o.order_purchase_timestamp::DATE) AS first_purchase,

        MAX(o.order_purchase_timestamp::DATE) AS last_purchase

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id

    INNER JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        c.customer_unique_id

)

SELECT

    customer_unique_id,

    total_orders,

    lifetime_revenue,

    avg_order_value,

    first_purchase,

    last_purchase,

    (last_purchase - first_purchase) AS customer_lifetime_days

FROM customer_summary

ORDER BY

    lifetime_revenue DESC

LIMIT 20;


--Q27 Pareto Analysis (80/20 Rule)


WITH product_revenue AS (

    SELECT

        oi.product_id,

        ct.product_category_name_english AS category,

        ROUND(SUM(oi.price::NUMERIC),2) AS total_revenue

    FROM order_items oi

    INNER JOIN products p
        ON oi.product_id = p.product_id

    INNER JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name

    GROUP BY

        oi.product_id,
        ct.product_category_name_english

)

SELECT

    product_id,

    category,

    total_revenue,

    ROUND(

        total_revenue * 100.0
        /

        SUM(total_revenue) OVER()

    ,2) AS revenue_percentage,

    ROUND(

        SUM(total_revenue)
        OVER(
            ORDER BY total_revenue DESC
        )

        *100.0

        /

        SUM(total_revenue) OVER()

    ,2) AS cumulative_revenue_percentage

FROM product_revenue

ORDER BY

    total_revenue DESC;


--Q28 Month-over-Month Revenue Growth Analysis
-- Production Version


WITH monthly_revenue AS (

    SELECT

        DATE_TRUNC('month', o.order_purchase_timestamp::DATE) AS month,

        ROUND(SUM(oi.price::NUMERIC),2) AS revenue

    FROM orders o

    INNER JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        DATE_TRUNC('month', o.order_purchase_timestamp::DATE)

),

growth_data AS (

    SELECT

        month,

        revenue,

        LAG(revenue) OVER(
            ORDER BY month
        ) AS previous_revenue

    FROM monthly_revenue

)

SELECT

    month,

    revenue,

    previous_revenue,

    ROUND(

        (
            revenue - previous_revenue
        )

        *100.0

        /

        previous_revenue

    ,2) AS mom_growth_percentage

FROM growth_data

ORDER BY

    month;


--Q29 Monthly Revenue Ranking Analysis


WITH monthly_revenue AS (

    SELECT

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp::DATE
        ) AS month,

        ROUND(
            SUM(oi.price::NUMERIC),
        2) AS revenue

    FROM orders o

    INNER JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp::DATE
        )

)

SELECT

    month,

    revenue,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS dense_rank,

    ROUND(

        revenue * 100.0

        /

        SUM(revenue) OVER()

    ,2) AS contribution_percentage

FROM monthly_revenue

ORDER BY

    revenue_rank;


--Q30 Executive Business Dashboard


WITH revenue_summary AS (

    SELECT
        ROUND(SUM(price::NUMERIC),2) AS total_revenue,
        ROUND(AVG(price::NUMERIC),2) AS average_product_price
    FROM order_items

),

order_summary AS (

    SELECT

        COUNT(*) AS total_orders,

        COUNT(*) FILTER (
            WHERE order_status='delivered'
        ) AS delivered_orders,

        COUNT(*) FILTER (
            WHERE order_status='canceled'
        ) AS cancelled_orders

    FROM orders

),

customer_summary AS (

    SELECT

        COUNT(DISTINCT customer_unique_id) AS total_customers

    FROM customers

),

review_summary AS (

    SELECT

        ROUND(
            AVG(review_score::NUMERIC)
        ,2) AS average_review

    FROM order_reviews

),

seller_summary AS (

    SELECT

        COUNT(*) AS total_sellers

    FROM sellers

)

SELECT

    rs.total_revenue,

    rs.average_product_price,

    os.total_orders,

    os.delivered_orders,

    os.cancelled_orders,

    ROUND(

        os.delivered_orders*100.0

        /

        os.total_orders

    ,2) AS delivery_success_rate,

    cs.total_customers,

    ss.total_sellers,

    rv.average_review

FROM revenue_summary rs

CROSS JOIN order_summary os

CROSS JOIN customer_summary cs

CROSS JOIN seller_summary ss

CROSS JOIN review_summary rv;
