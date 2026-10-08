select
    product_id,

    product_category_name,

    count(*) as item_count,

    count(distinct order_id) as order_count,

    count(distinct seller_id) as seller_count,

    sum(price) as product_revenue,

    sum(freight_value) as total_freight,

    sum(total_item_value) as total_sales_value,

    avg(price) as average_item_price,

    avg(freight_value) as average_freight_value

from {{ ref('fact_order_items') }}

group by
    product_id,
    product_category_name