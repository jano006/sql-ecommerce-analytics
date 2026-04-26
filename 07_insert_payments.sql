-- Generates payment records based on orders with simulated payment methods and statuses

INSERT INTO payments (order_id, amount, payment_method, payment_date, status)
SELECT
    o.id,
    o.total_price,
    
    CASE 
        WHEN o.id % 3 = 0 THEN 'PAYPAL'
        WHEN o.id % 5 = 0 THEN 'CASH'
        ELSE 'CARD'
    END,
    
    o.order_date,
    
    CASE
        WHEN o.status = 'SHIPPED' THEN 'COMPLETED'
        WHEN o.status = 'NEW' THEN 'PENDING'
        WHEN o.status = 'CANCELLED' THEN 'FAILED'
    END
FROM orders o;