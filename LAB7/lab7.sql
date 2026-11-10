

CREATE TABLE IF NOT EXISTS employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);


-- Exercise 2.1: Simple View Creation
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees AS e
JOIN departments AS d ON d.dept_id = e.dept_id;

SELECT * FROM employee_details;
-- Answer: the original sample data returns 4 rows. Tom Brown has a NULL
-- dept_id, so the INNER JOIN finds no matching department and excludes him.

-- Exercise 2.2: View with Aggregation
CREATE OR REPLACE VIEW dept_statistics AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments AS d
LEFT JOIN employees AS e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics ORDER BY employee_count DESC;

-- Exercise 2.3: View with Multiple Joins
CREATE OR REPLACE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects AS p
LEFT JOIN departments AS d ON d.dept_id = p.dept_id
LEFT JOIN employees AS e ON e.dept_id = d.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name, d.location;

SELECT * FROM project_overview ORDER BY project_name;

-- Exercise 2.4: View with Filtering
CREATE OR REPLACE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees AS e
LEFT JOIN departments AS d ON d.dept_id = e.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;
-- Answer: the view returns only rows whose salary is greater than 55,000.
-- With the original data it shows Jane Doe and Sarah Williams, which are all
-- high-earning employees under this definition


-- Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees AS e
JOIN departments AS d ON d.dept_id = e.dept_id;

SELECT * FROM employee_details;

-- Exercise 3.2: Rename a View
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;

-- Exercise 3.3: Drop a View
CREATE VIEW temp_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;

-- Exercise 4.1: Create an Updatable View
CREATE OR REPLACE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

-- Exercise 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000.00
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
-- Answer: yes. PostgreSQL applies the update to the employees base table.

-- Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000.00);

SELECT * FROM employees WHERE emp_id = 6;
-- Answer: yes. This simple view is automatically updatable, so Alice Johnson
-- is inserted into employees as well.

-- Exercise 4.4: View with CHECK OPTION
CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);

-- ERROR: new row violates check option for view "it_employees"
-- DETAIL: Failing row contains (7, Bob Wilson, 103, 60000.00).
-- It fails because dept_id 103 does not satisfy the view condition dept_id = 101.


-- Exercise 5.1: Create a Materialized View 
CREATE MATERIALIZED VIEW dept_summary_mv AS
WITH employee_totals AS (
    SELECT dept_id, COUNT(*) AS total_employees, SUM(salary) AS total_salaries
    FROM employees
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
),
project_totals AS (
    SELECT dept_id, COUNT(*) AS total_projects, SUM(budget) AS total_project_budget
    FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
)
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0.00) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0.00) AS total_project_budget
FROM departments AS d
LEFT JOIN employee_totals AS e ON e.dept_id = d.dept_id
LEFT JOIN project_totals AS p ON p.dept_id = d.dept_id
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000.00);

SELECT * FROM dept_summary_mv WHERE dept_id = 101;
-- Before refresh, the IT row is stale: it does not include Charlie Brown.

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT * FROM dept_summary_mv WHERE dept_id = 101;
-- After refresh, the IT row includes Charlie Brown (total_employees is 3).

-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX dept_summary_mv_dept_id_uq ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- Answer: CONCURRENTLY keeps the old populated result available to readers
-- while DBMS builds and swaps in the refreshed result.

-- Exercise 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employee_count
FROM projects AS p
LEFT JOIN departments AS d ON d.dept_id = p.dept_id
LEFT JOIN employees AS e ON e.dept_id = p.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- SELECT * FROM project_stats_mv;
-- Answer: querying now raises "materialized view ... has not been populated".
-- Fix it by running the next command, then query the view again.
REFRESH MATERIALIZED VIEW project_stats_mv;
SELECT * FROM project_stats_mv ORDER BY project_name;


-- Exercise 6.1: Create Basic Roles
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%' ORDER BY rolname;

-- Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user LOGIN SUPERUSER PASSWORD 'admin999';

-- Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- Exercise 6.4: Create Group Roles
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- Exercise 6.5: Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- Exercise 6.6: Modify Role Attributes
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;


-- Exercise 7.1: Role Hierarchies
CREATE ROLE read_only NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

-- Exercise 7.4: Row-Level Security with Views
CREATE OR REPLACE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


-- Exercise 8.1: Department Dashboard View
CREATE OR REPLACE VIEW dept_dashboard AS
WITH employee_totals AS (
    SELECT dept_id, COUNT(*) AS employee_count, AVG(salary) AS average_salary
    FROM employees
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
),
project_totals AS (
    SELECT dept_id, COUNT(*) AS active_project_count, SUM(budget) AS total_project_budget
    FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
)
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    COALESCE(ROUND(e.average_salary, 2), 0.00) AS average_salary,
    COALESCE(p.active_project_count, 0) AS active_project_count,
    COALESCE(p.total_project_budget, 0.00) AS total_project_budget,
    CASE
        WHEN COALESCE(e.employee_count, 0) = 0 THEN 0.00
        ELSE ROUND(COALESCE(p.total_project_budget, 0.00) / e.employee_count, 2)
    END AS budget_per_employee
FROM departments AS d
LEFT JOIN employee_totals AS e ON e.dept_id = d.dept_id
LEFT JOIN project_totals AS p ON p.dept_id = d.dept_id;

SELECT * FROM dept_dashboard ORDER BY dept_name;

-- Exercise 8.2: Audit View
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects AS p
LEFT JOIN departments AS d ON d.dept_id = p.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects ORDER BY budget DESC;

-- Exercise 8.3: Create Access Control System
CREATE ROLE viewer_role NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role NOLOGIN;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role NOLOGIN;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role NOLOGIN;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;

