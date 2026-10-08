# Olist E-Commerce Analytics — dbt + Snowflake

A modern data transformation and analytics project built using **Snowflake and dbt** on the Brazilian Olist e-commerce dataset.

The project demonstrates an end-to-end analytics engineering workflow: loading raw e-commerce data into Snowflake, modelling it through staging and intermediate layers, creating dimensional/fact models, and producing business-focused analytics models with dbt testing and documentation.

---

## Architecture

```text
                         Olist E-Commerce Dataset
                                   │
                                   ▼
                          ┌─────────────────┐
                          │     Snowflake   │
                          │       RAW       │
                          └────────┬────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │   dbt Sources   │
                          └────────┬────────┘
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │       STAGING            │
                    │                          │
                    │ stg_orders               │
                    │ stg_customers            │
                    │ stg_order_items           │
                    │ stg_order_payments        │
                    │ stg_order_reviews         │
                    │ stg_products              │
                    │ stg_sellers               │
                    │ stg_product_category...   │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │      INTERMEDIATE        │
                    │                          │
                    │ int_orders_enriched      │
                    │ int_order_items_enriched │
                    │ int_order_payments...    │
                    │ int_order_reviews        │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │          MARTS            │
                    │                          │
                    │ dim_customers            │
                    │ dim_products             │
                    │ dim_sellers              │
                    │ fact_orders              │
                    │ fact_order_items         │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │       ANALYTICS           │
                    │                          │
                    │ sales_performance        │
                    │ customer_performance     │
                    │ product_performance      │
                    │ delivery_performance     │
                    │ review_performance       │
                    └──────────────────────────┘
```

---

## Project Objectives

The main objectives are to:

* Build a structured analytics data warehouse using Snowflake.
* Use dbt to transform raw e-commerce data into analytics-ready models.
* Demonstrate layered data modelling using **staging → intermediate → marts → analytics**.
* Apply dimensional modelling principles.
* Define and test model and column-level data quality rules.
* Create reusable business metrics for sales, customers, products, delivery and reviews.
* Document transformation logic and model relationships using dbt.
* Provide a foundation for BI tools and further analytical exploration.

---

## Technology Stack

| Technology         | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| **Snowflake**      | Cloud data warehouse                                      |
| **dbt**            | SQL transformations, modelling, testing and documentation |
| **SQL**            | Data transformation and analytical logic                  |
| **Git / GitHub**   | Version control                                           |
| **GitHub Actions** | Planned CI/CD automation                                  |

---

## Dataset

The project uses the **Brazilian Olist E-Commerce dataset**.

The dataset contains information about:

* Customers
* Orders
* Order items
* Payments
* Reviews
* Products
* Sellers
* Product categories

The original dataset contains approximately:

* **99K orders**
* **112K order items**
* **96K unique customers**
* Thousands of products and sellers

The dataset is particularly useful because it contains multiple related entities and realistic one-to-many relationships.

---

# Data Model

## 1. Raw Layer

The raw data is loaded into Snowflake without applying business transformations.

Schema:

```text
ECOMMERCE_DB.RAW
```

Tables:

```text
CUSTOMERS
ORDERS
ORDER_ITEMS
ORDER_PAYMENTS
ORDER_REVIEWS
PRODUCTS
PRODUCT_CATEGORY_TRANSLATION
SELLERS
```

The raw layer acts as the source-of-truth ingestion layer.

---

## 2. Staging Layer

The staging layer provides a clean interface over the raw source tables.

Models:

```text
stg_customers
stg_orders
stg_order_items
stg_order_payments
stg_order_reviews
stg_products
stg_product_category_translation
stg_sellers
```

The staging layer focuses on:

* Selecting required columns
* Establishing consistent naming
* Creating clean source interfaces
* Defining source/model tests

Business logic is intentionally kept limited at this layer.

---

## 3. Intermediate Layer

The intermediate layer contains reusable transformations and joins.

Models:

```text
int_orders_enriched
int_order_items_enriched
int_order_payments_aggregated
int_order_reviews
```

Examples:

### `int_orders_enriched`

Combines orders with customer information.

```text
orders
   │
   └── customer_id
          │
          ▼
      customers
```

### `int_order_items_enriched`

Combines order items with product and seller information.

```text
order_items
     │
     ├── product_id ──► products
     │
     └── seller_id  ──► sellers
```

### `int_order_payments_aggregated`

Changes the payment grain from individual payment records to:

```text
one row per order
```

and calculates:

* Payment count
* Total payment value
* Maximum payment installments

### `int_order_reviews`

Adds a business classification to review scores:

```text
1–2 → negative
3   → neutral
4–5 → positive
```

---

# 4. Marts Layer

The marts layer contains business-oriented fact and dimension models.

## Dimensions

### `dim_customers`

One row per `customer_unique_id`.

Provides:

* Customer identifier
* Location
* Customer attributes

The Olist dataset can contain multiple `customer_id` values for the same underlying customer, so `customer_unique_id` is used as the business-level customer identifier.

---

### `dim_products`

One row per product.

Provides:

* Product identifier
* Product category
* Product dimensions
* Product weight
* Product metadata

The Portuguese product category is translated to English where a translation is available.

---

### `dim_sellers`

One row per seller.

Provides:

* Seller identifier
* Location
* State
* ZIP code

---

## Facts

### `fact_orders`

One row per order.

Contains:

* Order information
* Customer information
* Payment metrics
* Delivery status
* On-time delivery indicator

The model also derives:

```text
delivered_on_time
```

based on actual versus estimated delivery dates.

---

### `fact_order_items`

One row per:

```text
(order_id, order_item_id)
```

Contains:

* Product
* Seller
* Price
* Freight
* Product attributes
* Seller location

It also calculates:

```text
total_item_value = price + freight_value
```

The composite grain is intentional because `order_item_id` is not globally unique across all orders.

---

# 5. Analytics Layer

The analytics layer contains business-facing models designed for reporting and analysis.

## `sales_performance`

Monthly sales metrics including:

* Order count
* Unique customers
* Total revenue
* Average order value
* Delivered revenue

Example questions:

```text
How is monthly revenue changing?

How many customers are placing orders?

What is the average order value?

How much revenue comes from delivered orders?
```

---

## `customer_performance`

One row per customer.

Metrics include:

* Order count
* Total revenue
* Average order value
* First order date
* Last order date
* Delivered order count
* Delivered revenue

This provides a foundation for customer segmentation and lifetime-value analysis.

---

## `product_performance`

One row per product.

Metrics include:

* Number of items sold
* Number of orders
* Number of sellers
* Product revenue
* Freight value
* Total sales value
* Average item price

This can be used to identify top-selling and high-value products.

---

## `delivery_performance`

Monthly delivery performance metrics including:

* Total orders
* Delivered orders
* On-time orders
* Late orders
* Average delivery time
* Delivery variance against estimate

Delivery variance is calculated as:

```text
Actual delivery date - Estimated delivery date
```

Therefore:

```text
-3 → delivered 3 days early
 0 → delivered on estimated date
+4 → delivered 4 days late
```

---

## `review_performance`

Monthly customer review metrics including:

* Review count
* Average review score
* Positive reviews
* Neutral reviews
* Negative reviews
* Reviews containing comments

Review classification:

```text
1–2 → Negative
3   → Neutral
4–5 → Positive
```

---

# Data Quality & Testing

dbt tests are used to validate important assumptions about the data.

Examples include:

```yaml
data_tests:
  - unique
  - not_null
```

Tests are applied according to the grain of each model.

For example:

### Orders

```text
order_id → unique
```

### Customers

```text
customer_unique_id → unique
```

### Products

```text
product_id → unique
```

### Order Items

The grain is:

```text
(order_id, order_item_id)
```

Therefore a global uniqueness test is not applied to `order_item_id`.

This is intentional and reflects the actual structure of the source data.

---

# Important Data Modelling Decisions

## Customer Grain

The source contains both:

```text
customer_id
customer_unique_id
```

`customer_id` identifies the customer record associated with an order, while `customer_unique_id` represents the underlying customer across potentially multiple orders.

Therefore:

```text
dim_customers
```

uses:

```text
customer_unique_id
```

as its grain.

---

## Order Item Grain

Order items use:

```text
(order_id, order_item_id)
```

as their grain.

`order_item_id` should not be treated as globally unique.

This prevents incorrect uniqueness assumptions and preserves the actual source grain.

---

## Review IDs

The source contains duplicate `review_id` values.

Therefore the project does **not** enforce:

```text
review_id unique
```

at the staging/intermediate level.

Instead, the model reflects the source data rather than imposing an incorrect uniqueness assumption.

---

## Payment Aggregation

Orders can contain multiple payment records.

The intermediate payment model aggregates payments to:

```text
one row per order
```

before joining them to `fact_orders`.

This prevents payment records from multiplying order-level rows.

---

# Example Business Questions

The resulting models can answer questions such as:

### Sales

* What is monthly revenue?
* What is the average order value?
* How many unique customers purchase each month?
* What percentage of revenue comes from delivered orders?

### Customers

* Which customers generate the most revenue?
* How frequently do customers reorder?
* What is the average customer order value?
* Which customers have been active most recently?

### Products

* Which products generate the most revenue?
* Which products have the highest sales volume?
* Which products have high freight costs?
* Which products are sold by multiple sellers?

### Delivery

* What percentage of orders are delivered on time?
* Which months had the highest late-delivery rate?
* What is the average delivery time?
* How far ahead or behind estimates are actual deliveries?

### Reviews

* What is the average customer review score?
* How many reviews are negative?
* Are negative reviews increasing?
* How frequently do customers leave written comments?

---

# Running the Project

## Prerequisites

You need:

* Snowflake account
* Python
* dbt
* Git

Install the Snowflake dbt adapter:

```bash
pip install dbt-snowflake
```

> The project uses a Snowflake connection configured through `~/.dbt/profiles.yml`.

---

## Configure Snowflake Credentials

The password is supplied through an environment variable rather than being stored directly in the dbt profile.

Example:

```bash
export SNOWFLAKE_PASSWORD="your-password"
```

The profile uses:

```yaml
password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
```

This keeps credentials out of source control.

---

# Validate the dbt Connection

From the project directory:

```bash
dbt debug
```

A successful result should show:

```text
Connection test: [OK connection ok]
```

---

# Install Dependencies

If the project contains a `packages.yml`:

```bash
dbt deps
```

---

# Run the Project

Run all models:

```bash
dbt run
```

Run all tests:

```bash
dbt test
```

Or run the complete build:

```bash
dbt build
```

`dbt build` is particularly useful because it executes models and their associated tests according to the dependency graph.

---

# Run Individual Layers

### Staging

```bash
dbt run --select staging
```

### Intermediate

```bash
dbt run --select intermediate
```

### Marts

```bash
dbt run --select marts
```

### Analytics

```bash
dbt run --select analytics
```

You can also run an individual model:

```bash
dbt run --select sales_performance
```

---

# Testing

Run tests for a specific model:

```bash
dbt test --select customer_performance
```

Run all tests:

```bash
dbt test
```

For the full project:

```bash
dbt build
```

---

# Documentation

Generate dbt documentation:

```bash
dbt docs generate
```

Start the documentation server:

```bash
dbt docs serve
```

The generated documentation provides:

* Model descriptions
* Column descriptions
* Data tests
* Model dependencies
* Source definitions
* DAG lineage

The lineage graph makes the transformation flow visible:

```text
RAW
 ↓
Sources
 ↓
Staging
 ↓
Intermediate
 ↓
Marts
 ↓
Analytics
```

---

# Project Structure

```text
olist_analytics/
│
├── dbt_project.yml
│
├── models/
│   │
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_order_payments.sql
│   │   ├── stg_order_reviews.sql
│   │   ├── stg_products.sql
│   │   ├── stg_sellers.sql
│   │   └── stg_product_category_translation.sql
│   │
│   ├── intermediate/
│   │   ├── int_orders_enriched.sql
│   │   ├── int_order_items_enriched.sql
│   │   ├── int_order_payments_aggregated.sql
│   │   └── int_order_reviews.sql
│   │
│   ├── marts/
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   │   ├── dim_sellers.sql
│   │   ├── fact_orders.sql
│   │   └── fact_order_items.sql
│   │
│   └── analytics/
│       ├── sales_performance.sql
│       ├── customer_performance.sql
│       ├── product_performance.sql
│       ├── delivery_performance.sql
│       └── review_performance.sql
│
├── analyses/
├── macros/
├── seeds/
├── snapshots/
└── tests/
```

---

# Future Enhancements

The project is designed to be extended with additional production-style capabilities.

Planned enhancements include:

* [ ] Incremental dbt model
* [ ] Additional generic and singular dbt tests
* [ ] dbt source freshness checks
* [ ] GitHub Actions CI/CD
* [ ] Automated `dbt build` validation
* [ ] Additional customer segmentation
* [ ] RFM analysis
* [ ] Customer lifetime value analysis
* [ ] Product category performance analysis
* [ ] BI dashboard integration
* [ ] Snowflake cost/performance optimisation

---

# Key Skills Demonstrated

This project demonstrates practical experience with:

**Data Engineering**

* Cloud data warehousing
* Snowflake
* SQL
* Relational data modelling
* Fact and dimension modelling
* Data quality

**Analytics Engineering**

* dbt
* dbt sources
* dbt models
* `ref()` and dependency management
* Model layering
* Data tests
* Documentation
* DAG-based transformations

**Data Modelling**

* Dimensional modelling
* Grain definition
* One-to-many relationships
* Aggregation
* Slowly evolving customer identity concepts
* Business metric modelling

**Engineering Practices**

* Git
* Environment-based credentials
* Reproducible transformations
* CI/CD
* Automated testing

---

# Design Philosophy

The project intentionally separates transformations into layers rather than creating a single collection of large SQL queries.

```text
Staging
  ↓
Clean source representations

Intermediate
  ↓
Reusable joins and transformations

Marts
  ↓
Business entities and facts

Analytics
  ↓
Business-facing metrics
```

This approach improves:

* Maintainability
* Reusability
* Testability
* Lineage
* Debuggability
* Collaboration

The goal is not simply to transform the Olist dataset, but to demonstrate how a modern analytics engineering project can be structured for maintainability and future growth.
