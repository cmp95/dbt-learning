SELECT *
FROM {{ ref('stg_orders') }} as orders
JOIN {{ ref('stg_payments') }} as payments 
ON orders.order_id = payments.order_id