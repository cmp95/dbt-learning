WITH 

Orders AS (
  SELECT * FROM {{ ref('int_orders') }}
),

Customers AS (
  SELECT * FROM {{ ref('stg_jaffle_shop__customers') }}
),


CustomerOrders AS (
  SELECT 
    orders.*,
    customers.full_name,
    customers.surname,
    customers.givenname,
    MIN(orders.order_date) OVER (PARTITION BY orders.customer_id) AS customer_first_order_date,
    MIN(orders.valid_order_date) OVER (PARTITION BY orders.customer_id) AS customer_first_non_returned_order_date,
    MAX(orders.valid_order_date) OVER (PARTITION BY orders.customer_id) AS customer_most_recent_non_returned_order_date,
    COUNT(*) OVER (PARTITION BY orders.customer_id) AS customer_order_count,
    SUM(IF(orders.valid_order_date IS NOT NULL, 1, 0)) OVER (PARTITION BY orders.customer_id) AS customer_non_returned_order_count,
    SUM(IF(orders.valid_order_date IS NOT NULL, orders.order_value_dollars, 0)) OVER (PARTITION BY orders.customer_id) AS customer_total_lifetime_value,
    ARRAY_AGG(orders.order_id) OVER (PARTITION BY orders.customer_id) AS customer_order_ids_array -- Remove DISTINCT
  FROM Orders
  INNER JOIN Customers ON orders.customer_id = customers.customer_id
),


AddAvgOrderValues AS (
  SELECT
    *,
    customer_total_lifetime_value / customer_non_returned_order_count AS customer_avg_non_returned_order_value
  FROM CustomerOrders
),


Final AS (
  SELECT 
    order_id,
    customer_id,
    surname,
    givenname,
    customer_first_order_date AS first_order_date,
    customer_order_count AS order_count,
    customer_total_lifetime_value AS total_lifetime_value,
    order_value_dollars,
    order_status,
    payment_status,
    -- Convert ARRAY_AGG to STRING_AGG with CAST
    STRING_AGG(CAST(order_id AS STRING), ',') OVER (PARTITION BY customer_id) AS customer_order_ids
  FROM AddAvgOrderValues, UNNEST(customer_order_ids_array) AS order_id -- Unnest the array for STRING_AGG
)
SELECT * FROM Final
