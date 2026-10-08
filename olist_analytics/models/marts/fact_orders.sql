select
    o.order_id,
    o.customer_id,
    o.customer_unique_id,

    o.order_status,

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    p.payment_count,
    p.total_payment_value,
    p.max_payment_installments,

    case
        when o.order_delivered_customer_date is not null
         and o.order_estimated_delivery_date is not null
         and o.order_delivered_customer_date
             <= o.order_estimated_delivery_date
        then true
        when o.order_delivered_customer_date is not null
         and o.order_estimated_delivery_date is not null
        then false
        else null
    end as delivered_on_time

from {{ ref('int_orders_enriched') }} o

left join {{ ref('int_order_payments_aggregated') }} p
    on o.order_id = p.order_id