-- ============================================================
-- Olist E-Commerce Analytics
-- Load CSV files into RAW tables
-- ============================================================

USE DATABASE ECOMMERCE_DB;
USE SCHEMA RAW;

-- ------------------------------------------------------------
-- Customers
-- ------------------------------------------------------------
COPY INTO CUSTOMERS
FROM @OLIST_STAGE/olist_customers_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Orders
-- ------------------------------------------------------------
COPY INTO ORDERS
FROM @OLIST_STAGE/olist_orders_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Order Items
-- ------------------------------------------------------------
COPY INTO ORDER_ITEMS
FROM @OLIST_STAGE/olist_order_items_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Order Payments
-- ------------------------------------------------------------
COPY INTO ORDER_PAYMENTS
FROM @OLIST_STAGE/olist_order_payments_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Order Reviews
-- ------------------------------------------------------------
COPY INTO ORDER_REVIEWS
FROM @OLIST_STAGE/olist_order_reviews_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Products
-- ------------------------------------------------------------
COPY INTO PRODUCTS
FROM @OLIST_STAGE/olist_products_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Sellers
-- ------------------------------------------------------------
COPY INTO SELLERS
FROM @OLIST_STAGE/olist_sellers_dataset.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ------------------------------------------------------------
-- Product Category Translation
-- ------------------------------------------------------------
COPY INTO PRODUCT_CATEGORY_TRANSLATION
FROM @OLIST_STAGE/product_category_name_translation.csv
FILE_FORMAT = (
    FORMAT_NAME = CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';