select
    date_trunc('month', order_purchase_timestamp) as order_month,

    count(*) as order_count,

    count(distinct customer_unique_id) as unique_customers,

    sum(total_payment_value) as total_revenue,

    avg(total_payment_value) as average_order_value,

    sum(
        case
            when order_status = 'delivered'
            then total_payment_value
            else 0
        end
    ) as delivered_revenue

from {{ ref('fact_orders') }}

group by
    date_trunc('month', order_purchase_timestamp)