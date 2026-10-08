select
    customer_unique_id,
    min(customer_id) as customer_id,
    min(customer_zip_code_prefix) as customer_zip_code_prefix,
    min(customer_city) as customer_city,
    min(customer_state) as customer_state

from {{ ref('stg_customers') }}

group by customer_unique_id