select
    order_id,
    count(*) as payment_count,
    sum(payment_value) as total_payment_value,
    max(payment_installments) as max_payment_installments

from {{ ref('stg_order_payments') }}

group by order_id