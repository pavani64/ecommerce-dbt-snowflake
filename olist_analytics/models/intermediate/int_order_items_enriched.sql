select
    oi.order_id,
    oi.order_item_id,

    oi.product_id,
    p.product_category_name,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    oi.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,

    oi.shipping_limit_date,
    oi.price,
    oi.freight_value

from {{ ref('stg_order_items') }} oi

left join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id

left join {{ ref('stg_sellers') }} s
    on oi.seller_id = s.seller_id