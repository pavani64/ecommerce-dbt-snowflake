# Olist E-Commerce Analytics — dbt + Snowflake

A production-style analytics engineering project built with **dbt and Snowflake**, using the Brazilian Olist E-Commerce dataset.

The project demonstrates how raw e-commerce data can be transformed into a tested, analytics-ready data model using **layered dbt transformations, dimensional modelling, data quality tests, Snowflake, and GitHub Actions CI/CD**.

---

## Architecture

```text
                    ┌─────────────────────┐
                    │   Olist Raw Data    │
                    │      CSV / Data      │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      Snowflake      │
                    │        RAW          │
                    └──────────┬──────────┘
                               │
                               │ dbt source()
                               ▼
                    ┌─────────────────────┐
                    │     STAGING         │
                    │                     │
                    │ • stg_orders        │
                    │ • stg_customers     │
                    │ • stg_order_items   │
                    │ • stg_products      │
                    │ • stg_sellers       │
                    │ • stg_payments      │
                    │ • stg_reviews       │
                    └──────────┬──────────┘
                               │
                               │ dbt ref()
                               ▼
                    ┌─────────────────────┐
                    │   INTERMEDIATE      │
                    │                     │
                    │ • orders_enriched   │
                    │ • order_items       │
                    │ • payments_agg      │
                    │ • reviews           │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       MARTS         │
                    │                     │
                    │ Dimensions          │
                    │ • dim_customers     │
                    │ • dim_products      │
                    │ • dim_sellers       │
                    │                     │
                    │ Facts               │
                    │ • fact_orders       │
                    │ • fact_order_items  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      ANALYTICS      │
                    │                     │
                    │ • sales_performance │
                    │ • customer_perf.    │
                    │ • product_perf.     │
                    │ • delivery_perf.    │
                    │ • review_perf.      │
                    └─────────────────────┘

                       GitHub Actions
                              │
                              ▼
                    dbt debug → dbt build
                    + automated tests
```

---

## Project Overview

This project uses **dbt on Snowflake** to transform the Olist Brazilian E-Commerce dataset into a layered analytics model.

The project focuses on practical analytics engineering patterns:

* Source management
* Staging transformations
* Intermediate business logic
* Dimensional modelling
* Fact tables
* Analytics marts
* Data quality testing
* Grain-aware modelling
* Snowflake SQL
* dbt dependency management
* Git-based development
* GitHub Actions CI/CD
* Automated `dbt build` validation

The goal is to demonstrate how a real-world analytics transformation project can be structured, tested and maintained rather than simply creating a collection of SQL queries.

---

## Project Objectives

The project demonstrates how to:

1. Load raw e-commerce data into Snowflake.
2. Define raw Snowflake tables as dbt sources.
3. Build clean staging models.
4. Apply business transformations in intermediate models.
5. Create dimensional and fact models.
6. Build analytics-ready datasets.
7. Add automated data quality tests.
8. Handle real-world data modelling challenges.
9. Document modelling decisions.
10. Run automated CI validation using GitHub Actions.
11. Keep Snowflake credentials outside the repository.

---

## Technology Stack

| Technology         | Purpose                            |
| ------------------ | ---------------------------------- |
| **Snowflake**      | Cloud data warehouse               |
| **dbt**            | Data transformation and modelling  |
| **SQL**            | Transformation logic               |
| **Git / GitHub**   | Version control                    |
| **GitHub Actions** | CI/CD and automated dbt validation |
| **Python / uv**    | Local development environment      |

---

## Dataset

The project uses the **Brazilian Olist E-Commerce dataset**, containing information about orders, customers, products, sellers, payments and reviews.

The dataset contains approximately:

* **99K orders**
* **112K order items**
* **96K unique customers**
* Thousands of products
* Thousands of sellers
* Multiple payment records per order
* Customer reviews
* Product category translations

The raw data is stored in Snowflake under:

```text
ECOMMERCE_DB.RAW
```

### Raw Tables

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

---

# Data Model

The dbt project follows a layered transformation architecture.

```text
RAW
 │
 ▼
SOURCES
 │
 ▼
STAGING
 │
 ▼
INTERMEDIATE
 │
 ▼
MARTS
 │
 ▼
ANALYTICS
```

Each layer has a specific responsibility.

---

## 1. Staging Layer

The staging layer provides a clean interface over the raw Snowflake tables.

Models:

```text
stg_customers
stg_orders
stg_order_items
stg_order_payments
stg_order_reviews
stg_products
stg_sellers
stg_product_category_translation
```

Typical staging responsibilities include:

* Selecting required columns
* Renaming fields where appropriate
* Standardising data types
* Preserving source information needed by downstream models
* Defining model grain
* Applying basic data quality tests

The staging layer intentionally contains limited business logic.

---

## 2. Intermediate Layer

The intermediate layer contains reusable business transformations that are shared by downstream marts.

### `int_orders_enriched`

Combines orders with customer information.

Grain:

```text
One row per order
```

Validation:

```text
Total orders:           99,441
Distinct orders:        99,441
```

---

### `int_order_items_enriched`

Combines order items with:

* Products
* Sellers

Grain:

```text
(order_id, order_item_id)
```

Validation:

```text
Total rows:                    112,650
Distinct order/item pairs:    112,650
```

The model was specifically validated to ensure that joining products and sellers did not multiply order-item rows.

---

### `int_order_payments_aggregated`

Payments can contain multiple records for the same order.

Instead of joining raw payment rows directly to orders, payments are aggregated first:

```sql
select
    order_id,
    count(*) as payment_count,
    sum(payment_value) as total_payment_value,
    max(payment_installments) as max_payment_installments
from {{ ref('stg_order_payments') }}
group by order_id
```

This produces:

```text
One row per order
```

and prevents payment joins from multiplying the order grain.

---

### `int_order_reviews`

Provides a reusable review model and categorises review scores:

```text
1–2 → negative
3   → neutral
4–5 → positive
```

The source dataset contains duplicate `review_id` values, so `review_id` is intentionally **not treated as a globally unique key**.

This is an example of allowing the source data's actual behaviour to influence the data model rather than blindly applying uniqueness assumptions.

---

# 3. Marts Layer

The marts layer contains analytics-ready dimensional and fact models.

## Dimensions

### `dim_customers`

Customer modelling uses:

```text
customer_unique_id
```

as the business-level customer grain.

The Olist dataset can contain multiple `customer_id` values associated with the same `customer_unique_id`.

Therefore:

```text
customer_unique_id = business customer
customer_id        = order-level/source customer identifier
```

The model contains approximately:

```text
96,096 customers
```

This prevents customer analytics from being incorrectly split across multiple source customer IDs.

---

### `dim_products`

Contains product attributes and translated product categories.

The model uses the English category translation when available:

```sql
coalesce(
    t.product_category_name_english,
    p.product_category_name
) as product_category
```

This provides a more analytics-friendly product category field while retaining the original category when a translation is unavailable.

---

### `dim_sellers`

Contains seller-level information.

Grain:

```text
One row per seller
```

---

## Facts

### `fact_orders`

Grain:

```text
One row per order
```

The model combines:

* Order information
* Customer information
* Aggregated payment information
* Delivery dates
* Delivery status

It also derives whether an order was delivered on time using actual and estimated delivery dates.

---

### `fact_order_items`

Grain:

```text
(order_id, order_item_id)
```

The model contains:

* Product
* Seller
* Price
* Freight
* Product attributes
* Seller attributes

It also calculates:

```text
total_item_value = price + freight_value
```

The composite grain is important because `order_item_id` is only unique within an order and should not be treated as globally unique.

---

# 4. Analytics Layer

The analytics layer contains business-focused models designed for downstream analysis and BI.

## `sales_performance`

Provides sales trends over time.

Example dimensions and measures include:

* Order month
* Order count
* Revenue
* Average order value
* Payment metrics

The monthly grain is represented as a `DATE` rather than a timestamp:

```sql
cast(
    date_trunc('month', order_purchase_timestamp)
    as date
) as order_month
```

---

## `customer_performance`

Provides customer-level metrics including:

* Order count
* Total revenue
* Average order value
* First order date
* Last order date
* Delivered order count
* Delivered revenue

Missing payment values are handled explicitly using `COALESCE` where appropriate.

For example:

```sql
sum(coalesce(total_payment_value, 0)) as total_revenue
```

while `average_order_value` intentionally preserves the original `AVG()` semantics rather than treating missing payments as zero.

---

## `product_performance`

Provides product-level performance metrics such as:

* Orders
* Units sold
* Revenue
* Average selling price
* Freight
* Product category performance

---

## `delivery_performance`

Provides delivery analysis including:

* Estimated delivery dates
* Actual delivery dates
* Delivery duration
* On-time delivery performance
* Late delivery patterns

---

## `review_performance`

Provides customer review analysis including:

* Review scores
* Positive / neutral / negative classification
* Review volumes
* Review performance by product/category/order

---

# Data Quality & Testing

Data quality is implemented using dbt tests.

Examples include:

* `not_null`
* `unique`
* Relationship tests
* Grain-aware validation
* Business-rule validation

Examples of tested keys include:

```text
stg_orders.order_id
stg_customers.customer_id
```

Composite grains are tested according to their actual business meaning.

For example:

```text
fact_order_items
----------------
(order_id, order_item_id)
```

rather than incorrectly assuming:

```text
order_item_id
```

is globally unique.

This is particularly important because source datasets frequently contain assumptions that do not hold when inspected at scale.

---

# Important Modelling Decisions

## Customer Grain

The Olist dataset contains both:

```text
customer_id
customer_unique_id
```

`customer_unique_id` is used as the business-level customer grain because a single customer can have multiple source-level customer IDs.

---

## Order Item Grain

Order items use:

```text
(order_id, order_item_id)
```

as their composite grain.

`order_item_id` alone is not treated as globally unique.

---

## Payment Aggregation

Orders can have multiple payment records.

Therefore, payments are aggregated before joining to the order fact.

```text
Raw payments
     │
     ▼
Aggregate by order_id
     │
     ▼
One payment summary per order
     │
     ▼
fact_orders
```

This prevents accidental row multiplication and incorrect revenue calculations.

---

## Review IDs

The source contains duplicate `review_id` values.

Instead of imposing an incorrect uniqueness constraint, the model preserves the source behaviour and avoids using `review_id` as a unique key.

---

## Missing Payment Values

Revenue calculations explicitly handle missing payment values using `COALESCE` where zero is the appropriate business interpretation.

At the same time, averages are not automatically converted to zero because doing so would change the meaning of the metric.

---

## Delivery Performance

Delivery performance is derived from actual and estimated delivery timestamps rather than simply relying on order status.

This allows the model to answer questions such as:

```text
Was the order delivered on time?
```

---

# Data Quality Validation

The project validates important assumptions throughout the transformation pipeline.

Examples include:

### Orders

```text
99,441 total orders
99,441 distinct orders
```

### Order Items

```text
112,650 total order-item records
112,650 distinct (order_id, order_item_id) combinations
```

### Customers

```text
96,096 business-level customers
96,096 distinct customer_unique_id values
```

### Join Validation

The order-item enrichment was validated to ensure:

```text
All product matches found
All seller matches found
No unexpected join multiplication
```

The full dbt project successfully passes:

```bash
dbt build
```

including the associated dbt tests.

---

# CI/CD with GitHub Actions

The project includes automated CI validation using **GitHub Actions**.

The workflow runs automatically on:

```text
push → main
pull request → main
```

The workflow performs:

```text
Checkout repository
        │
        ▼
Set up Python
        │
        ▼
Install dbt-snowflake
        │
        ▼
Create temporary dbt profile
        │
        ▼
dbt debug
        │
        ▼
dbt build
        │
        ▼
dbt models + tests
```

### Credential Security

Snowflake credentials are **not stored in the repository**.

GitHub Actions receives:

* Snowflake account
* Snowflake user
* Snowflake role
* Snowflake database
* Snowflake warehouse
* Snowflake schema

through GitHub repository variables.

The Snowflake password is stored as a GitHub Actions secret.

The workflow creates a temporary `profiles.yml` on the GitHub Actions runner.

The local dbt profile remains outside the repository:

```text
~/.dbt/profiles.yml
```

This keeps development credentials and production/CI credentials separate.

---

# Running the Project Locally

## Prerequisites

You will need:

* Python
* dbt
* dbt-snowflake
* Snowflake account
* Snowflake database and warehouse
* Git

---

## Clone the Repository

```bash
git clone https://github.com/pavani64/ecommerce-dbt-snowflake.git

cd ecommerce-dbt-snowflake
```

---

## Configure Snowflake Credentials

The dbt profile is intentionally stored outside the repository:

```text
~/.dbt/profiles.yml
```

Example structure:

```yaml
olist_analytics:
  target: dev

  outputs:
    dev:
      type: snowflake
      account: <account>
      user: <username>
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: <role>
      database: ECOMMERCE_DB
      warehouse: <warehouse>
      schema: <schema>
      threads: 4
```

Set the password through an environment variable:

```bash
export SNOWFLAKE_PASSWORD="your-password"
```

Do not commit credentials to Git.

---

# Install Dependencies

If using the Python environment included with the project:

```bash
uv sync
```

Alternatively, install dbt-snowflake in another Python environment:

```bash
pip install dbt-snowflake
```

---

# Validate the dbt Connection

From the dbt project directory:

```bash
cd olist_analytics

dbt debug
```

A successful connection should report that the dbt configuration and Snowflake connection are valid.

---

# Run the Project

Build all models and execute tests:

```bash
dbt build
```

This executes the dependency graph in the correct order and runs applicable tests.

---

# Run Specific Models

Build a single model:

```bash
dbt build --select customer_performance
```

Build a model and its upstream dependencies:

```bash
dbt build --select +customer_performance
```

Build a complete layer:

```bash
dbt build --select staging
```

or select models by path:

```bash
dbt build --select path:models/marts
```

---

# Generate dbt Documentation

Generate the dbt documentation site:

```bash
dbt docs generate
```

Start the local documentation server:

```bash
dbt docs serve
```

The documentation provides:

* Model descriptions
* Column information
* Tests
* Sources
* Model dependencies
* Lineage graph

The generated documentation is intended for local development and exploration unless separately deployed.

---

# Project Structure

```text
ecommerce-dbt-snowflake/
│
├── .github/
│   └── workflows/
│       └── dbt.yml
│
├── olist_analytics/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── sources.yml
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   ├── stg_order_payments.sql
│   │   │   ├── stg_order_reviews.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_sellers.sql
│   │   │   └── stg_product_category_translation.sql
│   │   │
│   │   ├── intermediate/
│   │   │   ├── int_orders_enriched.sql
│   │   │   ├── int_order_items_enriched.sql
│   │   │   ├── int_order_payments_aggregated.sql
│   │   │   └── int_order_reviews.sql
│   │   │
│   │   ├── marts/
│   │   │   ├── dim_customers.sql
│   │   │   ├── dim_products.sql
│   │   │   ├── dim_sellers.sql
│   │   │   ├── fact_orders.sql
│   │   │   └── fact_order_items.sql
│   │   │
│   │   └── analytics/
│   │       ├── sales_performance.sql
│   │       ├── customer_performance.sql
│   │       ├── product_performance.sql
│   │       ├── delivery_performance.sql
│   │       └── review_performance.sql
│   │
│   ├── dbt_project.yml
│   └── ...
│
├── scripts/
│   └── snowflake/
│
├── .gitignore
├── pyproject.toml
├── uv.lock
└── README.md
```

---

# Business Questions

The analytics models can be used to answer questions such as:

### Sales

* How is revenue changing over time?
* What are the highest-revenue periods?
* What is the average order value?
* How many orders are being placed?

### Customers

* Who are the highest-value customers?
* How frequently do customers purchase?
* What is the customer's first and most recent order?
* How much revenue comes from delivered orders?

### Products

* Which products generate the most revenue?
* Which categories sell the most units?
* Which products have high freight costs?
* Which product categories perform best?

### Delivery

* What percentage of orders arrive on time?
* Which periods have the highest delivery delays?
* Are certain products or sellers associated with delivery issues?

### Reviews

* Which products receive the highest ratings?
* What proportion of reviews are positive?
* Which categories have weaker customer satisfaction?

---

# Skills Demonstrated

This project demonstrates practical experience with:

### Snowflake

* Database and schema organisation
* Snowflake SQL
* Analytical transformations
* Warehouse-based analytics

### dbt

* Sources
* `ref()` dependencies
* Staging models
* Intermediate models
* Dimensional modelling
* Fact modelling
* Analytics marts
* Data quality tests
* Model selection
* Documentation
* Dependency graphs

### Data Modelling

* Defining table grain
* Fact and dimension design
* Composite keys
* Business keys
* Handling source-system identifiers
* Preventing join multiplication
* Aggregation before joins

### Data Quality

* Not-null validation
* Uniqueness testing
* Relationship validation
* Grain-aware testing
* Business-rule validation
* Handling missing values

### Engineering Practices

* Git
* GitHub
* CI/CD
* GitHub Actions
* Secure credential management
* Reproducible dbt builds

---

# Future Enhancements

Potential future improvements include:

* Incremental dbt models
* dbt source freshness checks
* Additional generic and singular tests
* Customer segmentation
* RFM analysis
* Customer lifetime value (CLV)
* Product category analysis
* BI dashboard
* Snowflake query-performance optimisation
* Snowflake warehouse/cost optimisation
* Additional dbt documentation and lineage visualisation

The project intentionally focuses on **dbt + Snowflake analytics engineering** rather than introducing additional orchestration or infrastructure tools that are not required for the use case.

---

# Key Takeaways

The main focus of this project is not simply transforming CSV data into tables.

It demonstrates the reasoning required to build a reliable analytics model:

```text
Understand source data
        ↓
Define business grain
        ↓
Build clean staging models
        ↓
Apply reusable transformations
        ↓
Prevent join multiplication
        ↓
Create facts and dimensions
        ↓
Build business-facing analytics
        ↓
Test assumptions
        ↓
Automate validation with CI/CD
```

The resulting project provides a practical example of building a **tested, maintainable Snowflake + dbt analytics platform using modern analytics engineering practices**.
