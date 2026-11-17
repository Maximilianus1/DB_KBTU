--Exercise 1.1: Create Tables and Insert Sample Data
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12, 2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Operations', 'Building C');

INSERT INTO employees VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 101, 55000),
    (3, 'Mike Johnson', 102, 48000),
    (4, 'Sarah Williams', 102, 52000),
    (5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
    (201, 'Website Redesign', 75000, 101),
    (202, 'Database Migration', 120000, 101),
    (203, 'HR System Upgrade', 50000, 102);

--Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Answer: 2 indexes exist at this point: employees_pkey and emp_salary_idx.
-- The primary-key index (employees_pkey) is created automatically by PostgreSQL.

--Exercise 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT *
FROM employees
WHERE dept_id = 101;

-- Answer: indexing a foreign-key column speeds up joins, lookups of child rows,
-- and foreign-key checks when a referenced department is updated or deleted.

--Exercise 2.3: View Index Information
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer: the expected indexes are departments_pkey, employees_pkey,
-- projects_pkey, emp_salary_idx, and emp_dept_idx. The three *_pkey indexes
-- were created automatically by the PRIMARY KEY constraints.

--Exercise 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101
  AND salary > 52000;

-- Answer: no, this index is generally not useful for a query filtering only
-- by salary because its leading (leftmost) column is dept_id.

--Exercise 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102
  AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000
  AND dept_id = 102;

-- Answer: yes, index column order matters because a B-tree multicolumn index
-- is most useful when its leftmost columns are constrained. The written order of predicates in WHERE does not matter; PostgreSQL's planner normalizes it.

--Exercise 4.1: Create a Unique Index
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Answer: ERROR: duplicate key value violates unique constraint
-- "emp_email_unique_idx". The email already belongs to John Smith.

--Exercise 4.2: Unique Index vs UNIQUE Constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
  AND indexname LIKE '%phone%';

-- Answer: yes. PostgreSQL automatically creates a unique B-tree index to enforce the UNIQUE constraint on phone.

--Exercise 5.1: Create an Index for Sorting
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Answer: the index stores salary in the requested order, so PostgreSQL can
-- scan it in order and may avoid a separate sorting operation.

--Exercise 5.2: Index with NULL Handling
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--Exercise 6.1: Create a Function-Based Index
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Answer: without this expression index PostgreSQL normally performs a
-- sequential scan and applies LOWER(emp_name) to each row before comparison.

--Exercise 6.2: Index on Calculated Values
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--Exercise 7.1: Rename an Index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

--Exercise 7.2: Drop Unused Indexes
DROP INDEX emp_salary_dept_idx;

-- Answer: unused or redundant indexes consume disk space and slow INSERT,
-- UPDATE, and DELETE operations because PostgreSQL must maintain each index.

--Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;

-- Answer: REINDEX is useful after bulk inserts, substantial data changes, or
-- when an index becomes bloated and should be rebuilt.

--Exercise 8.1: Optimize a Slow Query
SELECT e.emp_name, e.salary, d.dept_name
FROM employees AS e
JOIN departments AS d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- emp_dept_idx supports the JOIN; emp_salary_desc_idx supports ORDER BY.

--Exercise 8.2: Partial Index
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Answer: a partial index is smaller and cheaper to maintain because it holds
-- only the frequently queried subset of rows, while still speeding up matching queries.

--Exercise 8.3: Analyze Index Usage
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

-- Answer: with this very small sample table, EXPLAIN may choose Seq Scan
-- because scanning all rows is cheaper. Index Scan means the planner estimates
-- the index is cheaper; Seq Scan means a sequential scan is cheaper here.

--Exercise 9.1: Create a Hash Index
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

-- Answer: use a HASH index only for equality comparisons. A B-tree is usually
-- preferred because it also supports range queries and ordering.

--Exercise 9.2: Compare Index Types
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

SELECT *
FROM projects
WHERE proj_name > 'Database';

-- Answer: both B-tree and HASH can support equality searches. Only the B-tree
-- index can support the range search using proj_name > 'Database'.

--Exercise 10.1: Review All Indexes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer: the query output identifies the largest index. Its size depends on
-- the actual data; indexes over more or wider values generally occupy more space.

--Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Answer: proj_name_btree_idx is retained because it supports both equality
-- and range searches, making the HASH index redundant for this table.

--Exercise 10.3: Document Your Indexes
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT *
FROM index_documentation;

--Exercise 10.4: Summary Questions
-- Answer 1: B-tree
-- Answer 2: Frequntly search for some exact value. When use Full-text search in huge dataset. When Frequently join 2 tables by some special condition in select.
-- Answer 3: When the table is small. When usage of index uses more resources than without it. 
-- Answer 4: PostgreSQL automatically updates affected indexes on INSERT,
-- UPDATE, and DELETE, which adds write overhead.
-- Answer 5: Use EXPLAIN or EXPLAIN ANALYZE and inspect the plan for Index Scan,
-- Bitmap Index Scan, or Seq Scan.
