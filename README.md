# E-Commerce Sales Analytics — SQL Project

A relational database project simulating an e-commerce platform, built to demonstrate
schema design, query optimization, and analytical SQL.
✅ Schema and all queries tested and verified on [DB Fiddle](https://www.db-fiddle.com/) (MySQL 8.0).

## Files
- `01_schema_and_data.sql` — Database schema (5 normalized tables, PK/FK constraints, indexes) + realistic sample data.
- `02_analytical_queries.sql` — 11 queries covering joins, aggregation, window functions, correlated subqueries, CTEs, a view, a stored procedure, and a trigger.

## How to run
1. Open MySQL Workbench (or any MySQL client).
2. Run `01_schema_and_data.sql` first — creates the database and populates it.
3. Run `02_analytical_queries.sql` — executes each query section by section.

*(Works on MySQL 8+. For PostgreSQL: replace `AUTO_INCREMENT` with `SERIAL`, and swap `DELIMITER` blocks for `$$` syntax.)*

## Schema (ER overview)
```
customers ──< orders ──< order_items >── products >── categories
```
- **customers**: customer_id (PK), full_name, email, city, signup_date
- **categories**: category_id (PK), category_name
- **products**: product_id (PK), product_name, category_id (FK), price, stock_quantity
- **orders**: order_id (PK), customer_id (FK), order_date, status
- **order_items**: order_item_id (PK), order_id (FK), product_id (FK), quantity, unit_price

## SQL concepts demonstrated
| Concept | Where |
|---|---|
| Multi-table JOINs | Query 1, 2 |
| GROUP BY / aggregation | Query 2, 7 |
| Window functions (RANK, running SUM) | Query 3, 4, 6 |
| Correlated subquery | Query 5 |
| Common Table Expression (CTE) | Query 6 |
| Views | Query 9 |
| Stored procedures | Query 10 |
| Triggers | Query 11 |
| Indexing for performance | Schema file |
| Constraints (CHECK, UNIQUE, FK) | Schema file |

## How to talk about this in an interview
- **Why this design**: 3NF normalization avoids data redundancy — product price history stays intact in `order_items.unit_price` even if `products.price` changes later.
- **Why indexes**: Added on FK columns and `order_date` since those are the most common filter/join columns — mention this shows you think about query performance, not just correctness.
- **Window functions**: Use Query 3/4 to explain the difference between `RANK()` and a plain `GROUP BY` — this is a common interview follow-up.
- **Trigger**: Shows you understand how to enforce business logic (stock management) at the database level, not just the application level.

## Possible extensions if you get a follow-up question
- Add a `payments` table and demonstrate a transaction (`START TRANSACTION` / `COMMIT` / `ROLLBACK`).
- Add `EXPLAIN` output for one query to discuss query plans.
- Partition `orders` by year for a "scaling" discussion.
