select
    product_category_name,
    product_category_name_english
from {{ source('raw', 'PRODUCT_CATEGORY_TRANSLATION') }}