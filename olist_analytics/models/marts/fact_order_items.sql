select
    order_id,
    order_item_id,

    product_id,
    seller_id,

    shipping_limit_date,

    price,
    freight_value,

    price + freight_value as total_item_value,

    product_category_name,

    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,

    seller_city,
    seller_state

from {{ ref('int_order_items_enriched') }}
