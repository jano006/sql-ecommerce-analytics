-- =========================================
-- SQL ANALYTICS PROJECT
-- Description: Business analytics queries on e-commerce dataset (customers, orders, payments)
-- Note: Queries are organized into sections and progress from basic to advanced analytics
-- =========================================

-- =========================================
-- REVENUE & PAYMENTS
-- =========================================

-- 1. Total revenue from completed payments
SELECT 
	sum(amount) 
FROM payments 
WHERE status = 'COMPLETED';

-- 2. Monthly revenue from completed payments
SELECT 
	date_trunc('month', payment_date) AS month,
	sum(amount) AS total_spent
FROM payments p 
WHERE status = 'COMPLETED'
GROUP BY month
ORDER BY month;

-- 3. Payment success rate based on completed and failed payments
SELECT 
	completed_payments,
	failed_payments,
	round(
	completed_payments *100.0 / NULLIF(completed_payments + failed_payments, 0), 2)
	AS success_rate
FROM (
SELECT 
	count(CASE WHEN status = 'COMPLETED' THEN 1 end) AS completed_payments,
	count(CASE WHEN status = 'FAILED' THEN 1 end) AS failed_payments
FROM payments p) sub;

-- =========================================
-- ORDERS & PRODUCTS
-- =========================================

-- 4. Number of orders by status
SELECT 
	status,
	count(*) AS orders_total
FROM orders
GROUP BY status
ORDER BY orders_total desc;

-- 5. Average order value (AOV)
SELECT 
	round(avg(total_price), 2) AS avg_order_value
FROM orders
WHERE status = 'SHIPPED';

-- 6. Average number of items per order
SELECT 
	round(avg(num_of_items), 2) AS avg_items_per_order
FROM (
SELECT 
	sum(oi.quantity) AS num_of_items
FROM orders o 
JOIN order_items oi 
	ON o.id = oi.order_id 
WHERE o.status = 'SHIPPED'
GROUP BY o.id) sub ;

-- 7. Top 5 products by revenue
SELECT 
	*
FROM (
SELECT 
	p.id,
	p.name,
	sum(oi.price_at_order_time * oi.quantity) AS revenue,
	DENSE_RANK () OVER (ORDER BY sum(oi.price_at_order_time * oi.quantity) desc) AS rnk
FROM products p 
JOIN order_items oi 
	ON p.id = oi.product_id 
JOIN orders o 
	ON o.id = oi.order_id
WHERE o.status = 'SHIPPED'
GROUP BY
	p.id,
	p.name ) sub 
WHERE rnk <= 5;

-- 8. Top 3 products by quantity sold
SELECT 
	*
FROM (
SELECT 
	p.id,
    p.name,
    sum(oi.quantity) AS total_quantity,
    DENSE_RANK() OVER (ORDER BY sum(oi.quantity) DESC) AS rnk
FROM products p 
JOIN order_items oi 
    ON p.id = oi.product_id 
JOIN orders o 
    ON o.id = oi.order_id
WHERE o.status = 'SHIPPED'
GROUP BY p.id, p.name) sub 
WHERE rnk <= 3;

-- 9. Revenue by product price category
SELECT 
    CASE 
        WHEN p.price < 50 THEN 'LOW'
        WHEN p.price BETWEEN 50 AND 100 THEN 'MID'
        ELSE 'HIGH'
    END AS price_category,
    sum(oi.price_at_order_time * oi.quantity) AS revenue
FROM products p
JOIN order_items oi 
    ON p.id = oi.product_id
JOIN orders o
    ON oi.order_id = o.id
WHERE o.status = 'SHIPPED'
GROUP BY price_category
ORDER BY revenue DESC;

-- =========================================
-- CUSTOMERS & SEGMENTATION
-- =========================================

-- 10. Customer segmentation by activity and total spend
SELECT 
    c.id,
    c.name, 
    CASE 
        WHEN count(o.id) = 0 THEN 'NO ORDERS'
        ELSE 'ACTIVE'
    END AS customer_status,
    COALESCE(sum(o.total_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'SHIPPED'
GROUP BY c.id, c.name
ORDER BY c.id;

-- 11. Number of customers by order count
SELECT 
	order_count, 
	count(*) AS customer_count
FROM (
    SELECT c.id, 
    count(o.id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'SHIPPED'
    GROUP BY c.id
) sub
GROUP BY order_count
ORDER BY order_count;

-- 12. Number of customers with zero orders
SELECT 
	count(*) AS num_of_customers 
FROM customers c 
LEFT JOIN orders o 
	ON c.id = o.customer_id 
WHERE o.id IS NULL;

-- 13. Customers with more than one order
SELECT 
    c.id,
    c.name,
    count(o.id) AS order_count
FROM customers c
JOIN orders o 
    ON c.id = o.customer_id
WHERE o.status = 'SHIPPED'
GROUP BY c.id, c.name
HAVING count(o.id) > 1
ORDER BY order_count desc;

-- 14. Repeat customer rate
SELECT 
	round(
    sum(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) * 100.0 / count(*),
    2)
    AS repeat_customer_rate
FROM (
SELECT 
     c.id,
     count(o.id) AS num_orders
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
AND o.status = 'SHIPPED'
GROUP BY c.id) sub;

-- 15. Number of customers by age group
SELECT 
    count(*) AS customer_count,
    CASE 
        WHEN age < 30 THEN 'below_30'
        WHEN age BETWEEN 30 AND 49 THEN '30_to_49'
        ELSE '50_plus'
    END AS age_group
FROM customers
GROUP BY age_group
ORDER BY customer_count DESC;

-- =========================================
-- TIME-BASED ANALYTICS
-- =========================================

-- 16. Monthly new customer count
SELECT 
    date_trunc('month', created_at) AS month,
    count(*) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

-- 17. Monthly active customers
SELECT 
    date_trunc('month', order_date) AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM orders
WHERE status = 'SHIPPED'
GROUP BY month
ORDER BY month;

-- 18. Days between registration and first order
SELECT 
    c.id,
    EXTRACT(EPOCH FROM (MIN(o.order_date) - c.created_at)) / 86400 AS days_to_first_order
FROM customers c
JOIN orders o 
    ON c.id = o.customer_id 
WHERE o.status = 'SHIPPED'
GROUP BY c.id, c.created_at
ORDER BY days_to_first_order;

-- 19. Average days between customer orders
SELECT 
	round(AVG(days_between_orders), 2) AS avg_days_between_orders
FROM (
SELECT 
    customer_id,
    EXTRACT(EPOCH FROM (order_date - prev_order_date)) / 86400 AS days_between_orders
FROM (
SELECT 
    customer_id,
    order_date,
    LAG(order_date) OVER (
	   PARTITION BY customer_id 
       ORDER BY order_date
       ) AS prev_order_date
FROM orders
WHERE status = 'SHIPPED') sub1
WHERE prev_order_date IS NOT NULL) sub2;

-- =========================================
-- ADVANCED ANALYTICS
-- =========================================

-- 20. Top 5 customers by total spending
SELECT 
	*
FROM (
SELECT 
	c.id,
	c.name,
	sum(o.total_price) AS total_spent,
	DENSE_RANK () OVER (
		ORDER BY sum(o.total_price) DESC
		) AS rnk
FROM customers c 
JOIN orders o 
	ON c.id = o.customer_id 
	AND o.status = 'SHIPPED'
GROUP BY c.id, c.name) sub 
WHERE rnk <= 5;

-- 21. Top 3 customers by total spending per country
SELECT 
	*
FROM (
SELECT 
	c.country,
    c.id,
    c.name,
    sum(o.total_price) AS total_spent,
    DENSE_RANK () OVER (
         PARTITION BY c.country 
         ORDER BY sum(o.total_price) DESC
        ) AS rnk
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'SHIPPED'
GROUP BY c.country, c.id, c.name) sub
WHERE rnk <= 3;


