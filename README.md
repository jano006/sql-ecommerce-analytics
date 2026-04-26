# SQL Analytics Project – E-commerce Dataset

## Project Overview

This project demonstrates practical SQL skills for data analysis, including aggregations, joins, and window functions on a simulated e-commerce dataset.
The project contains a collection of SQL queries designed to extract business insights related to revenue, customer behavior, and product performance.

The queries are organized into sections and progress from basic aggregations to more advanced analytics using subqueries and window functions.  
The dataset is stored in a PostgreSQL database ("ecommerce").

## Dataset Description

The database consists of the following tables:

- **customers** – customer information (name, country, age, registration timestamp)  
- **products** – product catalog (name, price, stock quantity)  
- **orders** – customer orders (order date, status, total price)  
- **order_items** – products within orders (quantity, price at order time)  
- **payments** – payment transactions (amount, method, status, payment date)  

## Data Model

- One customer can have multiple orders  
- Each order belongs to exactly one customer  
- One order can contain multiple items  
- Each item is linked to a specific product  
- Each order can have associated payments  

## Project Structure

- 01_create_tables_and_indexes.sql
- 02_insert_customers.sql
- 03_insert_products.sql
- 04_insert_orders.sql
- 05_insert_order_items.sql
- 06_update_table_orders_column_total_price.sql
- 07_insert_payments.sql
- 08_analytics_queries.sql


## Key Metrics & Analysis

### Revenue & Payments

- Total revenue from completed payments  
- Monthly revenue trends  
- Payment success rate  

### Orders & Products

- Average order value (**AOV**)  
- Average number of items per order  
- Top products by revenue and quantity  
- Revenue by product category  

### Customers

- Customer segmentation (active vs no orders)  
- Distribution of customers by order count  
- Repeat customer rate  
- Customers grouped by age  

### Time-Based Analytics

- Monthly new customers  
- Monthly active customers  
- Time between registration and first order  
- Average time between orders  

## Techniques Used

- Aggregations (**SUM**, **COUNT**, **AVG**)  
- JOIN operations (**INNER JOIN**, **LEFT JOIN**)  
- Subqueries  
- Window functions (**DENSE_RANK**, **LAG**)  
- Conditional logic (**CASE WHEN**)  
- Date functions (**DATE_TRUNC**, **EXTRACT**)  

## Technologies

- PostgreSQL  
- DBeaver  
- SQL  

## How to Run

1. Run `01_create_tables_and_indexes.sql`  
2. Run insert scripts in order (`02 → 07`)  
3. Run `08_analytics_queries.sql`  

## Notes & Assumptions

- Dataset is intentionally small and manually generated to focus on query logic and analytical patterns  
- The schema is designed to simulate a real-world e-commerce system  
- Only **SHIPPED** orders are considered completed  
- **CANCELLED** orders are excluded from revenue-related metrics  
