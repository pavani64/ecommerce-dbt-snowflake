-- ============================================================
-- Olist E-Commerce Analytics
-- Create RAW tables
-- ============================================================

USE DATABASE ECOMMERCE_DB;
USE SCHEMA RAW;

-- ------------------------------------------------------------
-- Customers
-- Source: olist_customers_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR,
    customer_state VARCHAR
);

-- ------------------------------------------------------------
-- Orders
-- Source: olist_orders_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE ORDERS (
    order_id VARCHAR,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP_NTZ,
    order_approved_at TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ
);

-- ------------------------------------------------------------
-- Order Items
-- Source: olist_order_items_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE ORDER_ITEMS (
    order_id VARCHAR,
    order_item_id INTEGER,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP_NTZ,
    price NUMBER(10,2),
    freight_value NUMBER(10,2)
);

-- ------------------------------------------------------------
-- Order Payments
-- Source: olist_order_payments_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE ORDER_PAYMENTS (
    order_id VARCHAR,
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
    payment_value NUMBER(10,2)
);

-- ------------------------------------------------------------
-- Order Reviews
-- Source: olist_order_reviews_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE ORDER_REVIEWS (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INTEGER,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);

-- ------------------------------------------------------------
-- Products
-- Source: olist_products_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE PRODUCTS (
    product_id VARCHAR,
    product_category_name VARCHAR,
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- ------------------------------------------------------------
-- Sellers
-- Source: olist_sellers_dataset.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE SELLERS (
    seller_id VARCHAR,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR,
    seller_state VARCHAR
);

-- ------------------------------------------------------------
-- Product Category Translation
-- Source: product_category_name_translation.csv
-- ------------------------------------------------------------
CREATE OR REPLACE TABLE PRODUCT_CATEGORY_TRANSLATION (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);