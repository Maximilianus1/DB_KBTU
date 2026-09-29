
-- 1. Create database and tablesCREATE DATABASE advanced_Lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- 2. INSERT with column specification
INSERT INTO employees (first_name, last_name, department) 
VALUES ('Jhon', 'James', 'IT');

-- 3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Bob', 'Bobov', 'Sales', DEFAULT, '2025-01-10', DEFAULT);

-- 4. INSERT multiple rows in single statement
INSERT INTO departments (dept_name, budget, manager_id) VALUES 
('Marketing', 70000, 3),
('Finance', 110000, 4),
('IT', 40000, 2);

-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alastor', 'Jhowani', 'IT', 50000*1.1, '1999-01-01');

-- 6. INSERT from SELECT (subquery)
CREATE TABLE temp_employees (LIKE employees);

INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

-- 7. UPDATE with arithmetic expressions
UPDATE employees SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees SET status = 'Senior' 
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees 
SET department = CASE 
    WHEN salary > 80000 THEN 'Management' -- first case
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior' -- second case
    ELSE 'Junior' -- third case
END;

-- 10. UPDATE with DEFAULT 
UPDATE employees SET department = DEFAULT 
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE departments d SET budget = (
    SELECT AVG(e.salary) * 1.20  -- main function
    FROM employees e 
    WHERE e.department = d.dept_name );

-- 12. UPDATE multiple columns
UPDATE employees SET salary = salary * 1.15, status = 'Promoted' 
WHERE department = 'Sales';

-- 13. DELETE with simple WHERE condition
DELETE FROM employees 
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees 
WHERE salary < 40000 
  AND hire_date > '2023-01-01' 
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments 
WHERE dept_id NOT IN (
    SELECT DISTINCT department FROM employees
    WHERE department IS NOT NULL
); -- just delete all rows in departments because dept_id is never is a string

-- 16. DELETE with RETURNING clause
DELETE FROM projects 
WHERE end_date < '2023-01-01'
RETURNING *;

-- 17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('David', 'Miller', NULL, NULL, '2026-02-01');

-- 18. UPDATE NULL handling
UPDATE employees SET department = 'Unassigned' 
WHERE department IS NULL;

-- 19. DELETE with NULL conditions
DELETE FROM employees 
WHERE salary IS NULL OR department IS NULL;

-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Peter', 'Parker', 'IT', 75000, '2026-03-01')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21. UPDATE with RETURNING
UPDATE employees SET salary = salary + 5000 
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns
DELETE FROM employees 
WHERE hire_date < '2020-01-01'
RETURNING *;

-- 23. Conditional INSERT
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'James', 'Bond', 'Security', 700, '2026-05-01'
WHERE NOT EXISTS (
    SELECT * FROM employees 
    WHERE first_name = 'James' AND last_name = 'Bond'
);

-- 24. UPDATE with JOIN logic using subqueries
UPDATE employees e
SET salary = CASE 
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000 
        THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE EXISTS (
    SELECT * FROM departments d WHERE d.dept_name = e.department -- protection from NULL values
);

-- 25. Bulk operations
-- Step 1 Insert
WITH inserted_employees AS (
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES 
('Brame', 'Jacks', 'IT', 40000, '2026-01-01'),
('Colt', 'Kuper', 'IT', 42000, '2026-01-02'),
('Joshua', 'Isa', 'Sales', 44000, '2026-01-03'),
('Jeremy', 'Jeke', 'Sales', 46000, '2026-01-04'),
('Gregor', 'Tode', 'HR', 48000, '2026-01-05')
RETURNING emp_id; 

-- Step 2 Update
UPDATE employees
SET salary = salary * 1.10
WHERE emp_id IN (SELECT emp_id FROM inserted_employees);

-- 26. Data migration simulation
CREATE TABLE employee_archive (LIKE employees);

-- get deleted rows to use it later
WITH deleted_rows AS (
    DELETE FROM employees 
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM deleted_rows;

-- 27. Complex business logic
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
    SELECT COUNT(*) 
    FROM employees e 
    JOIN departments d ON e.department = d.dept_name
    WHERE d.dept_id = p.dept_id
  ) > 3;
