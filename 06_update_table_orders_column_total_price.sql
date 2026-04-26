-- Updates total_price column in orders table

UPDATE orders o
SET total_price = (
  SELECT COALESCE(SUM(oi.quantity * oi.price_at_order_time), 0)
  FROM order_items oi
  WHERE oi.order_id = o.id
);