select
    customer_unique_id,

    count(*) as order_count,

    sum(coalesce(total_payment_value, 0)) as total_revenue,

    avg(total_payment_value) as average_order_value,

    min(order_purchase_timestamp) as first_order_date,

    max(order_purchase_timestamp) as last_order_date,

    count(
        case
            when order_status = 'delivered'
            then 1
        end
    ) as delivered_order_count,

    sum(
        case
            when order_status = 'delivered'
            then coalesce(total_payment_value, 0)
            else 0
        end
    ) as delivered_revenue

from {{ ref('fact_orders') }}

group by
    customer_unique_id