-- ============================================================
-- SQL JOINS - Class 03
-- ============================================================


-- ============================================================
-- LEFT JOIN
-- ============================================================

-- Returns all products, including those with no orders (NULL order_id)
SELECT
    p.product_name,
    oi.order_id
FROM production.products p
LEFT JOIN sales.order_items oi
    ON p.product_id = oi.product_id
ORDER BY order_id;


-- Left join across 3 tables: products → order_items → orders
SELECT
    p.product_name,
    oi.order_id,
    oi.item_id,
    o.order_date
FROM production.products p
LEFT JOIN sales.order_items oi
    ON oi.product_id = p.product_id
LEFT JOIN sales.orders o
    ON o.order_id = oi.order_id
ORDER BY order_date;


-- All columns version of the 3-table left join
SELECT *
FROM production.products p
LEFT JOIN sales.order_items oi
    ON oi.product_id = p.product_id
LEFT JOIN sales.orders o
    ON o.order_id = oi.order_id;


-- ============================================================
-- RIGHT JOIN
-- ============================================================

-- Equivalent to the left join above but with tables swapped
SELECT
    product_name,
    order_id
FROM sales.order_items oi
RIGHT JOIN production.products p
    ON p.product_id = oi.product_id
ORDER BY order_id;


-- All columns: products with or without matching order_items
SELECT *
FROM production.products p
LEFT JOIN sales.order_items oi
    ON oi.product_id = p.product_id;


-- All stores, including those with no orders
SELECT *
FROM sales.orders o
RIGHT JOIN sales.stores st
    ON st.store_id = o.store_id;


-- ============================================================
-- FULL JOIN
-- ============================================================

-- Returns all rows from both tables; NULLs where no match exists
SELECT
    product_name,
    order_id
FROM sales.order_items oi
FULL JOIN production.products p
    ON p.product_id = oi.product_id
ORDER BY order_id;


-- ============================================================
-- INNER JOIN
-- ============================================================

-- Candidates who are also employees (matched by full name)
SELECT
    c.id  AS candid_id,
    e.id  AS emp_id,
    c.fullname
FROM hr.candidates c
INNER JOIN hr.employees e
    ON c.fullname = e.fullname;


-- ============================================================
-- LEFT / RIGHT / FULL JOIN on hr tables
-- ============================================================

-- All candidates; shows NULL emp_id if not an employee
SELECT
    c.id  AS candid_id,
    e.id  AS emp_id,
    c.fullname
FROM hr.candidates c
LEFT JOIN hr.employees e
    ON c.fullname = e.fullname;


-- All employees; shows NULL candid_id if not a candidate
SELECT
    c.id  AS candid_id,
    e.id  AS emp_id,
    e.fullname
FROM hr.candidates c
RIGHT JOIN hr.employees e
    ON c.fullname = e.fullname;


-- All candidates and all employees; NULLs where no name match
SELECT
    c.id        AS candid_id,
    e.id        AS emp_id,
    e.fullname  AS emp_name,
    c.fullname  AS candid_name
FROM hr.candidates c
FULL JOIN hr.employees e
    ON c.fullname = e.fullname;


-- Quick look at the hr tables
SELECT * FROM hr.candidates;
SELECT * FROM hr.employees;


-- ============================================================
-- CROSS JOIN
-- ============================================================

-- Syntax:
--   SELECT select_list
--   FROM table t1
--   CROSS JOIN table t2;

-- Produces Cartesian product: 321 products × 3 stores = 963 rows
SELECT *
FROM production.products
CROSS JOIN sales.stores;


-- Cartesian product: products × order_items (large result set)
SELECT *
FROM production.products
CROSS JOIN sales.order_items;

-- Reference count for order_items
SELECT * FROM sales.order_items; -- 4722 rows


-- ============================================================
-- SELF JOIN
-- ============================================================

-- Syntax:
--   SELECT select_list
--   FROM table t1
--   INNER/LEFT/RIGHT JOIN table t2 ON ...

-- Each staff member paired with their manager
SELECT
    e.staff_id                          AS emp_staff_id,
    e.first_name + ' ' + e.last_name    AS staff_name,
    m.staff_id                          AS manager_staff_id,
    m.first_name + ' ' + m.last_name    AS manager_name
FROM sales.staffs e
INNER JOIN sales.staffs m
    ON m.staff_id = e.manager_id;


SELECT * FROM sales.staffs;


-- Customers from the same city, avoiding duplicate pairs (c1.id > c2.id)
SELECT
    c1.city,
    c1.first_name + ' ' + c1.last_name  AS customer_1,
    c2.first_name + ' ' + c2.last_name  AS customer_2
FROM sales.customers c1
INNER JOIN sales.customers c2
    ON  c1.customer_id > c2.customer_id
    AND c1.city = c2.city
WHERE c1.city = 'Albany'
ORDER BY city;
