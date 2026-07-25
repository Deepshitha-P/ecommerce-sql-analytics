USE ecommerce_analytics;

/* ============================================================
   ANALYTICAL QUERIES — demonstrates range of SQL skills
   ============================================================ */

/* 1. JOIN — Full order details (customer + product) */
SELECT o.order_id, c.full_name, p.product_name, oi.quantity,
       oi.unit_price, (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
ORDER BY o.order_id;


/* 2. AGGREGATION + GROUP BY — Revenue per category */
SELECT cat.category_name,
       SUM(oi.quantity * oi.unit_price) AS total_revenue,
       COUNT(DISTINCT o.order_id) AS num_orders
FROM order_items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN orders o        ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY cat.category_name
ORDER BY total_revenue DESC;


/* 3. WINDOW FUNCTION — Rank customers by total spend */
SELECT c.full_name,
       SUM(oi.quantity * oi.unit_price) AS total_spend,
       RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS spend_rank
FROM customers c
JOIN orders o        ON c.customer_id = o.customer_id
JOIN order_items oi  ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.full_name;


/* 4. WINDOW FUNCTION — Running monthly revenue total */
SELECT order_month, monthly_revenue,
       SUM(monthly_revenue) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
) monthly
ORDER BY order_month;


/* 5. SUBQUERY (correlated) — Customers who spent above the average */
SELECT c.full_name,
       (SELECT SUM(oi.quantity * oi.unit_price)
        FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = c.customer_id AND o.status = 'Completed') AS total_spend
FROM customers c
HAVING total_spend > (
    SELECT AVG(cust_total) FROM (
        SELECT SUM(oi.quantity * oi.unit_price) AS cust_total
        FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.status = 'Completed'
        GROUP BY o.customer_id
    ) avg_sub
)
ORDER BY total_spend DESC;


/* 6. CTE — Best-selling product per category */
WITH product_sales AS (
    SELECT p.product_id, p.product_name, p.category_id,
           SUM(oi.quantity) AS units_sold,
           RANK() OVER (PARTITION BY p.category_id ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
)
SELECT cat.category_name, ps.product_name, ps.units_sold
FROM product_sales ps
JOIN categories cat ON ps.category_id = cat.category_id
WHERE ps.rnk = 1;


/* 7. SELF-EXPLANATORY BUSINESS QUERY — Customer retention
      (customers with more than 1 completed order) */
SELECT c.full_name, COUNT(o.order_id) AS orders_placed
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.full_name
HAVING COUNT(o.order_id) > 1
ORDER BY orders_placed DESC;


/* 8. LOW STOCK ALERT — products likely to run out (business use case) */
SELECT product_name, stock_quantity
FROM products
WHERE stock_quantity < 100
ORDER BY stock_quantity ASC;


/* 9. VIEW — Reusable sales summary for dashboards */
CREATE OR REPLACE VIEW vw_customer_sales_summary AS
SELECT c.customer_id, c.full_name, c.city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * oi.unit_price) AS lifetime_value
FROM customers c
JOIN orders o        ON c.customer_id = o.customer_id
JOIN order_items oi  ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.full_name, c.city;

-- Usage:
SELECT * FROM vw_customer_sales_summary ORDER BY lifetime_value DESC;


/* 10. STORED PROCEDURE — Get order history for a given customer */
DELIMITER //
CREATE PROCEDURE GetCustomerOrderHistory(IN cust_id INT)
BEGIN
    SELECT o.order_id, o.order_date, p.product_name,
           oi.quantity, oi.unit_price
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    WHERE o.customer_id = cust_id
    ORDER BY o.order_date;
END //
DELIMITER ;

-- Usage:
CALL GetCustomerOrderHistory(1);


/* 11. TRIGGER — Auto-decrement stock when an order item is inserted */
DELIMITER //
CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;
