--Maxim Zuyev 25B030181

-- Task 1.1: Basic CHECK Constraint and 1.4

CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65), -- CHECK: age must be between 18 and 65 inclusive.
    salary NUMERIC CHECK (salary > 0) -- CHECK: salary must be greater than zero.
);

INSERT INTO employees VALUES
    (1, 'Aida', 'Sadykova', 25, 350000),
    (2, 'Daniyar', 'Kim', 42, 520000);

-- Failure: age is below 18.
-- INSERT INTO employees VALUES (3, 'Jhon', 'Low', 17, 100000);

-- Failure: age is above 65.
-- INSERT INTO employees VALUES (4, 'Jhon', 'How', 66, 100000);

-- Failure: salary must be greater than zero.
-- INSERT INTO employees VALUES (5, 'Jhon', 'BelZo', 30, -1);


-- Task 1.2: Named CHECK Constraint and 1.4

CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,

    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
    -- CHECK: both prices must be positive, and discount_price must be strictly less than regular_price.
);

INSERT INTO products_catalog VALUES
    (1, 'Keyboard', 25000, 19900),
    (2, 'Mouse', 12000, 9500);

-- Failure: regular_price is zero.
-- INSERT INTO products_catalog VALUES (3, 'Laptop', 0, 10);

-- Failure: discount_price is zero.
-- INSERT INTO products_catalog VALUES (4, 'Phone', 100, 0);

-- Failure: discount_price equals regular_price.
-- INSERT INTO products_catalog VALUES (5, 'Disc', 100, 100);


-- Task 1.3: Multiple Column CHECK and 1.4

CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10), -- CHECK: the number of guests must be between 1 and 10.
    CONSTRAINT bookings_dates_order CHECK (check_out_date > check_in_date) -- CHECK: checkout must occur after check-in.
);

INSERT INTO bookings VALUES
    (1, DATE '2026-11-01', DATE '2026-11-05', 2),
    (2, DATE '2026-12-10', DATE '2026-12-12', 4);

-- Failure: zero guests.
-- INSERT INTO bookings VALUES
-- (3, DATE '2026-11-01', DATE '2026-11-02', 0);

-- Failure: more than ten guests.
-- INSERT INTO bookings VALUES
-- (4, DATE '2026-11-01', DATE '2026-11-02', 11);

-- Failure: checkout equals check-in.
-- INSERT INTO bookings VALUES
-- (5, DATE '2026-11-05', DATE '2026-11-05', 2);


-- Task 2.1: NOT NULL Implementation and 2.3

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
        -- customer ID cannot be NULL.
    email TEXT NOT NULL,
        -- email cannot be NULL.
    phone TEXT,
    registration_date DATE NOT NULL
        -- NOT NULL: registration date is required.
);

INSERT INTO customers VALUES
    (1, 'customer1@example.com', NULL, DATE '2026-01-10'),
    (2, 'customer2@example.com', '+77010000002', DATE '2026-02-12');

-- Failure: customer_id cannot be NULL.
-- INSERT INTO customers VALUES
-- (NULL, 'badid@example.com', NULL, DATE '2026-03-01');

-- Failure: email cannot be NULL.
-- INSERT INTO customers VALUES
-- (3, NULL, NULL, DATE '2026-03-01');

-- Failure: registration_date cannot be NULL.
-- INSERT INTO customers VALUES
-- (4, 'baddate@example.com', NULL, NULL);

INSERT INTO customers VALUES
    (5, 'customer5@example.com', NULL, DATE '2026-03-15');


-- Task 2.2: Combining Constraints and 2.3

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
        --  item_id is required.

    item_name TEXT NOT NULL,
        -- item_name is required.

    quantity INTEGER NOT NULL
        CONSTRAINT inventory_quantity_nonnegative
        CHECK (quantity >= 0),
        -- quantity cannot be NULL.
        -- quantity cannot be negative.

    unit_price NUMERIC NOT NULL
        CONSTRAINT inventory_price_positive
        CHECK (unit_price > 0),
        -- unit price cannot be NULL.
        -- unit price must be greater than zero.

    last_updated TIMESTAMP NOT NULL
        -- update timestamp is required.
);

INSERT INTO inventory VALUES
    (1, 'Notebook', 100, 450.00, TIMESTAMP '2026-10-01 10:00:00'),
    (2, 'Pen', 250, 120.00, TIMESTAMP '2026-10-02 11:30:00');

-- Failure: item_id cannot be NULL.
-- INSERT INTO inventory VALUES
-- (NULL, 'Bad ID', 1, 1, CURRENT_TIMESTAMP);

-- Failure: item_name cannot be NULL.
-- INSERT INTO inventory VALUES
-- (3, NULL, 1, 1, CURRENT_TIMESTAMP);

-- Failure: quantity cannot be NULL.
-- INSERT INTO inventory VALUES
-- (4, 'Bad quantity', NULL, 1, CURRENT_TIMESTAMP);

-- Failure: unit_price cannot be NULL.
-- INSERT INTO inventory VALUES
-- (5, 'Bad price', 1, NULL, CURRENT_TIMESTAMP);

-- Failure: last_updated cannot be NULL.
-- INSERT INTO inventory VALUES
-- (6, 'Bad timestamp', 1, 1, NULL);

-- Failure: quantity cannot be negative.
-- INSERT INTO inventory VALUES
-- (7, 'Negative quantity', -1, 1, CURRENT_TIMESTAMP);

-- Failure: unit_price must be positive.
-- INSERT INTO inventory VALUES
-- (8, 'Zero price', 1, 0, CURRENT_TIMESTAMP);


-- Task 3.1: Single Column UNIQUE

CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
        -- usernames cannot be duplicated.

    email TEXT
        CONSTRAINT unique_email UNIQUE,
        -- email addresses cannot be duplicated.

    created_at TIMESTAMP
);



-- Task 3.2: Course enrollments

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
        UNIQUE (student_id, course_code, semester)
        -- a student cannot enroll in the same course during the same semester more than once.
);

--Task 3.3 Named UNIQUE Constraints

ALTER TABLE users 
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users 
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES
    (1, 'aida', 'aida@example.com', TIMESTAMP '2026-01-01 09:00:00'),
    (2, 'daniyar', 'daniyar@example.com', TIMESTAMP '2026-01-02 10:00:00');

-- Failure: username 'aida' already exists.
-- INSERT INTO users VALUES
-- (3, 'aida', 'another@example.com', CURRENT_TIMESTAMP);

-- Failure: email already exists.
-- INSERT INTO users VALUES
-- (4, 'othername', 'aida@example.com', CURRENT_TIMESTAMP);


-- Task 4.1: Task 4.1: Single Column Primary Key

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
        -- dept_id must be unique and NOT NULL.
    dept_name TEXT NOT NULL,
        -- dept_name cannot be NULL.
    location TEXT
);

INSERT INTO departments VALUES
    (1, 'IT', 'Almaty'),
    (2, 'Human Resources', 'Astana'),
    (3, 'Finance', 'Shymkent');

-- Failure: dept_id 1 already exists.
-- INSERT INTO departments VALUES (1, 'Duplicate department', 'Almaty');

-- Failure: a primary key cannot be NULL.
-- INSERT INTO departments VALUES (NULL, 'No ID', 'Astana');


-- Task 4.2: Composite Primary Key

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,

    CONSTRAINT student_courses_pk
        PRIMARY KEY (student_id, course_id)
        -- the student-course pair must be unique.
        -- Neither student_id nor course_id can be NULL.
);

INSERT INTO student_courses VALUES
    (101, 1, DATE '2026-09-01', 'A'),
    (101, 2, DATE '2026-09-02', 'B'),
    (102, 1, DATE '2026-09-01', 'A');

-- Failure: student 101 is already enrolled in course 1.
-- INSERT INTO student_courses VALUES
-- (101, 1, DATE '2026-09-03', 'C');


-- Task 4.3: UNIQUE vs PRIMARY KEY
-- 1. UNIQUE VS PRIMARY KEY DIFFERENCES

-- PRIMARY KEY: Identifies the row. Only ONE per table. Cannot contain NULLs.
-- UNIQUE:      Enforces business rules. MULTIPLE allowed. Permits NULL values.

-- 2. SINGLE-COLUMN VS COMPOSITE PRIMARY KEY

-- SINGLE-COLUMN: Uses 1 column (usually a surrogate ID like INT AUTO_INCREMENT/UUID).
--                Best for independent core entities (e.g., users, products).
-- COMPOSITE:     Uses 2+ columns combined to guarantee a unique row identity.
--                Best for bridge tables (many-to-many, e.g., student_id + course_id).

-- 3. WHY ONLY ONE PK BUT MULTIPLE UNIQUE CONSTRAINTS?

-- ONE PK:      A row can only have ONE primary physical address on disk, and 
--              an object needs exactly ONE main identity for Foreign Key links.
-- MANY UNIQUE: An entity can have multiple distinct attributes that cannot 
--              be duplicated (e.g., user_id [PK], but email [UNIQUE] and SSN [UNIQUE]).

-- Task 5.1: Basic Foreign Key

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: employee ID must be unique and NOT NULL.

    emp_name TEXT NOT NULL,
        -- NOT NULL: employee name is required.

    dept_id INTEGER REFERENCES departments(dept_id),
        -- FOREIGN KEY: dept_id must match an existing department.

    hire_date DATE
);

INSERT INTO employees_dept VALUES
    (1, 'Arman', 1, DATE '2024-05-10'),
    (2, 'Dana', 2, DATE '2025-03-15'),
    (3, 'Miras', 3, DATE '2026-01-20');

-- Failure: department 999 does not exist.
-- INSERT INTO employees_dept VALUES
-- (4, 'Invalid Department', 999, CURRENT_DATE);


-- Task 5.2: Multiple Foreign Keys

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
        -- each author has a unique, non-null author_id to use for connection .
    author_name TEXT NOT NULL,
        -- author_name is required.
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
        -- each publisher has a unique, non-NULL ID.
    publisher_name TEXT NOT NULL,-- publisher name is required.
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: each book has a unique, non-NULL ID.

    title TEXT NOT NULL,
        -- NOT NULL: book title is required.

    author_id INTEGER REFERENCES authors(author_id),
        -- FOREIGN KEY: a specified author must exist.

    publisher_id INTEGER REFERENCES publishers(publisher_id), -- FOREIGN KEY: a specified publisher must exist.
    publication_year INTEGER,

    isbn TEXT UNIQUE
        -- UNIQUE: non-NULL ISBN values cannot be duplicated.
);

INSERT INTO authors VALUES
    (1, 'Mukhtar Auezov', 'Kazakhstan'),
    (2, 'Abai Qunanbaiuly', 'Kazakhstan'),
    (3, 'Jane Austen', 'United Kingdom'),
    (4, 'George Orwell', 'United Kingdom'),
    (5, 'Chinua Achebe', 'Nigeria');

INSERT INTO publishers VALUES
    (1, 'Atamura', 'Almaty'),
    (2, 'Zhazushy', 'Almaty'),
    (3, 'Penguin Classics', 'London'),
    (4, 'Secker & Warburg', 'London'),
    (5, 'Heinemann', 'London');

INSERT INTO books VALUES
    (1, 'The Path of Abai', 1, 1, 1942, '9780000000001'),
    (2, 'Book of Words', 2, 2, 1890, '9780000000002'),
    (3, 'Pride and Prejudice', 3, 3, 1813, '9780000000003'),
    (4, 'Nineteen Eighty-Four', 4, 4, 1949, '9780000000004'),
    (5, 'Things Fall Apart', 5, 5, 1958, '9780000000005');

-- Failure: author 999 does not exist.
-- INSERT INTO books VALUES (6, 'Unknown Author', 999, 1, 2020, '9780000000006');

-- Failure: publisher 999 does not exist.
-- INSERT INTO books VALUES (7, 'Unknown Publisher', 1, 999, 2020, '9780000000007');

-- Failure: isbn already exists.
-- INSERT INTO books VALUES(8, 'Duplicate ISBN', 1, 1, 2020, '9780000000001');


-- Task 5.3: ON DELETE Options

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: category ID must be unique and NOT NULL.

    category_name TEXT NOT NULL
        -- NOT NULL: category name is required.
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
        -- product_id must be unique and NOT NULL.

    product_name TEXT NOT NULL, -- product name is required.

    category_id INTEGER
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
        -- FOREIGN KEY: referenced category must exist.
        -- ON DELETE RESTRICT: cannot delete a category that is
        -- referenced by products.
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
        -- order_id must be unique and NOT NULL.

    order_date DATE NOT NULL -- order date is required.
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
        -- item_id must be unique and NOT NULL.

    order_id INTEGER
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
        -- FOREIGN KEY: referenced order must exist.
        -- ON DELETE CASCADE: deleting an order automatically
        -- deletes its associated order_items rows.

    product_id INTEGER REFERENCES products_fk(product_id),
        -- referenced product must exist.

    quantity INTEGER CHECK (quantity > 0)
        -- quantity must be positive when not NULL.
);

INSERT INTO categories VALUES
    (1, 'Electronics'),
    (2, 'Stationery');

INSERT INTO products_fk VALUES
    (1, 'Headphones', 1),
    (2, 'USB cable', 1),
    (3, 'Notebook', 2);

INSERT INTO orders VALUES
    (1, DATE '2026-10-01'),
    (2, DATE '2026-10-02');

INSERT INTO order_items VALUES
    (1, 1, 1, 2),
    (2, 1, 2, 1),
    (3, 2, 3, 5);

-- Failure: category 1 is referenced by products.
-- ON DELETE RESTRICT prevents deletion.
-- DELETE FROM categories WHERE category_id = 1;

-- CASCADE test: delete order 1.
-- Its order_items rows (item_id 1 and 2) are deleted automatically.
DELETE FROM orders WHERE order_id = 1;

-- Expected result: only item_id 3 remains.
SELECT * FROM order_items ORDER BY item_id;

-- Task 6.1: E-commerce Database Design

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: customer ID must be unique and NOT NULL.

    name TEXT NOT NULL,
        -- NOT NULL: customer name is required.

    email TEXT NOT NULL UNIQUE,
        -- NOT NULL: email is required.
        -- UNIQUE: each customer must have a different email.
    phone TEXT,

    registration_date DATE NOT NULL
        -- NOT NULL: registration date is required.
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: product ID must be unique and NOT NULL.

    name TEXT NOT NULL,
        -- NOT NULL: product name is required.

    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
        -- NOT NULL: price is required.
        -- CHECK: price cannot be negative.

    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
        -- NOT NULL: stock quantity is required.
        -- CHECK: stock quantity cannot be negative.
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: order ID must be unique and NOT NULL.

    customer_id INTEGER NOT NULL
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
        -- NOT NULL: every order must have a customer.
        -- FOREIGN KEY: customer must exist.
        -- ON DELETE RESTRICT: a customer with orders cannot be deleted.

    order_date DATE NOT NULL,
        -- NOT NULL: order date is required.

    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
        -- NOT NULL: total amount is required.
        -- CHECK: total amount cannot be negative.

    status TEXT NOT NULL CHECK (
        status IN (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    )
    -- NOT NULL: status is required.
    -- CHECK: status must be one of the five permitted values.
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
        -- PRIMARY KEY: order-detail ID must be unique and NOT NULL.

    order_id INTEGER NOT NULL
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
        -- NOT NULL: each order detail must belong to an order.
        -- FOREIGN KEY: order must exist.
        -- ON DELETE CASCADE: deleting an order deletes its details.

    product_id INTEGER NOT NULL
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
        -- NOT NULL: product ID is required.
        -- FOREIGN KEY: product must exist.
        -- ON DELETE RESTRICT: a product referenced by an order
        -- detail cannot be deleted.

    quantity INTEGER NOT NULL CHECK (quantity > 0),
        -- NOT NULL: quantity is required.
        -- CHECK: quantity must be greater than zero.

    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0)
        -- NOT NULL: unit price is required.
        -- CHECK: unit price cannot be negative.
);


-- Sample data: 5 customers

INSERT INTO customers VALUES
    (1, 'Aida Sadykova', 'aida.shop@example.com',
        '+77010000001', DATE '2026-01-10'),
    (2, 'Daniyar Kim', 'daniyar.shop@example.com',
        '+77010000002', DATE '2026-02-11'),
    (3, 'Arman Ilyas', 'arman.shop@example.com',
        NULL, DATE '2026-03-12'),
    (4, 'Dana Omar', 'dana.shop@example.com',
        '+77010000004', DATE '2026-04-13'),
    (5, 'Miras Ali', 'miras.shop@example.com',
        '+77010000005', DATE '2026-05-14');


-- Sample data: 5 products

INSERT INTO products VALUES
    (1, 'Keyboard', 'Mechanical keyboard', 25000.00, 20),
    (2, 'Mouse', 'Wireless mouse', 12000.00, 35),
    (3, 'Monitor', '27-inch monitor', 95000.00, 8),
    (4, 'USB cable', 'USB-C cable', 2500.00, 100),
    (5, 'Laptop stand', 'Adjustable stand', 15000.00, 15);


-- Sample data: 5 orders

INSERT INTO orders VALUES
    (1, 1, DATE '2026-10-01', 37000.00, 'pending'),
    (2, 2, DATE '2026-10-02', 95000.00, 'processing'),
    (3, 3, DATE '2026-10-03', 5000.00, 'shipped'),
    (4, 4, DATE '2026-10-04', 15000.00, 'delivered'),
    (5, 5, DATE '2026-10-05', 25000.00, 'cancelled');


-- Sample data: order details

INSERT INTO order_details VALUES
    (1, 1, 1, 1, 25000.00),
    (2, 1, 2, 1, 12000.00),
    (3, 2, 3, 1, 95000.00),
    (4, 3, 4, 2, 2500.00),
    (5, 4, 5, 1, 15000.00),
    (6, 5, 1, 1, 25000.00);

--Tests:

-- Expected failure: email must be unique.
-- INSERT INTO ecommerce_customers VALUES
-- (6, 'Duplicate Email', 'aida.shop@example.com', NULL, CURRENT_DATE);

-- Expected failure: customer name cannot be NULL.
-- INSERT INTO customers VALUES
-- (6, NULL, 'new@example.com', NULL, CURRENT_DATE);

-- Expected failure: product price cannot be negative.
-- INSERT INTO products VALUES
-- (6, 'Invalid price', 'test', -1, 1);

-- Expected failure: stock quantity cannot be negative.
-- INSERT INTO products VALUES
-- (7, 'Invalid stock', 'test', 1, -1);

-- Expected failure: 'returned' is not an allowed order status.
-- INSERT INTO orders VALUES
-- (6, 1, CURRENT_DATE, 10, 'returned');

-- Expected failure: customer 999 does not exist.
-- INSERT INTO orders VALUES (7, 999, CURRENT_DATE, 10, 'pending');

-- Expected failure: order quantity must be greater than zero.
-- INSERT INTO order_details VALUES (7, 1, 1, 0, 10);

-- Expected failure: product 999 does not exist.
-- INSERT INTO order_details VALUES (8, 1, 999, 1, 10);

-- Expected failure: PRIMARY KEY must be unique duplicate customer_id.
-- INSERT INTO ecommerce_customers VALUES
-- (1, 'Duplicate ID Customer', 'duplicate.id@example.com', NULL, DATE '2026-10-14');

-- Expected failure: PRIMARY KEY must be unique вuplicate product_id.
-- INSERT INTO products VALUES
-- (5, 'Duplicate ID Product', 'Test description', 1000.00, 10);

-- Expected failure: PRIMARY KEY cannot be NULL customer_id is NULL.
-- INSERT INTO ecommerce_customers VALUES
-- (NULL, 'No ID Customer', 'noid@example.com', NULL, DATE '2026-10-14');

-- Expected failure: PRIMARY KEY cannot be NULL order_id is NULL.
-- INSERT INTO orders VALUES
-- (NULL, 2, DATE '2026-10-06', 12000.00, 'pending');



-- Display customers.
SELECT * FROM customers ORDER BY customer_id;

-- Display products.
SELECT * FROM products ORDER BY product_id;

-- Display orders.
SELECT * FROM orders ORDER BY order_id;

-- Display order details.
SELECT * FROM order_details ORDER BY order_detail_id;
