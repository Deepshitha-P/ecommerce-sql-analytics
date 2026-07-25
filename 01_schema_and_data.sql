/* ============================================================
   E-COMMERCE SALES ANALYTICS DATABASE
   Author: Deepshitha P
   Purpose: Demonstrates schema design, normalization, joins,
            aggregation, window functions, views, procedures,
            triggers, and indexing in MySQL / PostgreSQL.
   ============================================================ */

DROP DATABASE IF EXISTS ecommerce_analytics;
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

/* ---------- 1. SCHEMA (3NF, with PK/FK constraints) ---------- */

CREATE TABLE customers (
    customer_id     INT PRIMARY KEY AUTO_INCREMENT,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    city            VARCHAR(50),
    signup_date     DATE NOT NULL
);

CREATE TABLE categories (
    category_id     INT PRIMARY KEY AUTO_INCREMENT,
    category_name   VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id      INT PRIMARY KEY AUTO_INCREMENT,
    product_name    VARCHAR(100) NOT NULL,
    category_id     INT NOT NULL,
    price           DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity  INT NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id        INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    order_date      DATE NOT NULL,
    status          VARCHAR(20) DEFAULT 'Completed',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id   INT PRIMARY KEY AUTO_INCREMENT,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

/* Indexes for query performance on frequently filtered/joined columns */
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orderitems_order ON order_items(order_id);
CREATE INDEX idx_orderitems_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category_id);


/* ---------- 2. SAMPLE DATA ---------- */

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Fashion'), ('Home & Kitchen'), ('Books'), ('Beauty');

INSERT INTO customers (full_name, email, city, signup_date) VALUES
('Ananya Rajan', 'ananya.r@mail.com', 'Chennai', '2024-01-15'),
('Vikram Iyer', 'vikram.i@mail.com', 'Bengaluru', '2024-02-10'),
('Sneha Kumar', 'sneha.k@mail.com', 'Chennai', '2024-02-20'),
('Rahul Nair', 'rahul.n@mail.com', 'Kochi', '2024-03-05'),
('Divya Menon', 'divya.m@mail.com', 'Hyderabad', '2024-03-18'),
('Arjun Reddy', 'arjun.r@mail.com', 'Chennai', '2024-04-01'),
('Priya Sharma', 'priya.s@mail.com', 'Mumbai', '2024-04-22'),
('Karthik Babu', 'karthik.b@mail.com', 'Chennai', '2024-05-10');

INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('Wireless Earbuds', 1, 2499.00, 150),
('Smartwatch', 1, 5999.00, 80),
('Bluetooth Speaker', 1, 1799.00, 120),
('Men Casual Shirt', 2, 999.00, 200),
('Women Kurti', 2, 1299.00, 180),
('Non-stick Cookware Set', 3, 2999.00, 60),
('Electric Kettle', 3, 1099.00, 90),
('Data Structures Textbook', 4, 599.00, 100),
('Novel - Fiction', 4, 349.00, 130),
('Face Serum', 5, 799.00, 220),
('Lipstick Combo', 5, 649.00, 250);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-06-01', 'Completed'),
(2, '2024-06-03', 'Completed'),
(1, '2024-06-10', 'Completed'),
(3, '2024-06-12', 'Cancelled'),
(4, '2024-06-15', 'Completed'),
(5, '2024-06-18', 'Completed'),
(2, '2024-07-01', 'Completed'),
(6, '2024-07-05', 'Completed'),
(7, '2024-07-08', 'Completed'),
(1, '2024-07-12', 'Completed'),
(8, '2024-07-15', 'Completed'),
(3, '2024-07-20', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 2499.00),
(1, 8, 1, 599.00),
(2, 2, 1, 5999.00),
(3, 3, 1, 1799.00),
(3, 10, 2, 799.00),
(4, 4, 3, 999.00),
(5, 6, 1, 2999.00),
(5, 7, 1, 1099.00),
(6, 5, 2, 1299.00),
(7, 1, 1, 2499.00),
(7, 11, 3, 649.00),
(8, 9, 4, 349.00),
(9, 2, 1, 5999.00),
(9, 3, 2, 1799.00),
(10, 4, 1, 999.00),
(10, 10, 1, 799.00),
(11, 6, 2, 2999.00),
(12, 1, 1, 2499.00);
