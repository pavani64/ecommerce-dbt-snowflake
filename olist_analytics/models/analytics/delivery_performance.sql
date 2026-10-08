select
    cast(
        date_trunc('month', order_purchase_timestamp)
        as date
    ) as order_month,

    count(*) as order_count,

    count(
        case
            when order_status = 'delivered'
            then 1
        end
    ) as delivered_order_count,

    count(
        case
            when delivered_on_time = true
            then 1
        end
    ) as on_time_order_count,

    count(
        case
            when delivered_on_time = false
            then 1
        end
    ) as late_order_count,

    avg(
        case
            when order_delivered_customer_date is not null
             and order_purchase_timestamp is not null
            then datediff(
                'day',
                order_purchase_timestamp,
                order_delivered_customer_date
            )
        end
    ) as average_delivery_days,

    avg(
        case
            when order_delivered_customer_date is not null
             and order_estimated_delivery_date is not null
            then datediff(
                'day',
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        end
    ) as average_delivery_variance_days

from {{ ref('fact_orders') }}

group by
    cast(
        date_trunc('month', order_purchase_timestamp)
        as date
    )