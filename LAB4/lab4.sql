-- Task 1.1: Write a query to select all employees, displaying their full name (concatenated first an last name), department, and salary.
SELECT first_name || ' ' || last_name AS full_name, department, salary
FROM employees;

-- Task 1.2: Use SELECT DISTINCT to find all unique departments in the company
SELECT DISTINCT department 
FROM employees;

-- Task 1.3: Select all projects with their names and budgets, and create a new column called budget_category using a CASE expression
SELECT project_name, budget,
       CASE 
           WHEN budget > 150000 THEN 'Large'
           WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
           ELSE 'Small'
       END AS budget_category
FROM projects;

-- Task 1.4: 
SELECT first_name, last_name,
       COALESCE(email, 'No email provided') AS n_email
FROM employees;


-- Task 2.1: Find all employees hired after January 1, 2020.
SELECT * 
FROM employees 
WHERE hire_date > '2020-01-01';

-- Task 2.2: Find all employees whose salary is between 60000 and 70000 (use the BETWEEN operator).
SELECT * 
FROM employees 
WHERE salary BETWEEN 60000 AND 70000;

-- Task 2.3: Find all employees whose last name starts with 'S' or 'J' (use the LIKE operator).
SELECT * 
FROM employees 
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

-- Task 2.4: Find all employees who have a manager (manager_id IS NOT NULL) and work in the IT department.
SELECT * 
FROM employees 
WHERE manager_id IS NOT NULL AND department = 'IT';


-- Task 3.1: Create a query that displays: Employee names in uppercase, Length of their last names, First 3 characters of their email address (use substring)
SELECT UPPER(first_name) AS first_name_uppercase, UPPER(last_name) AS last_name_uppercase,
       LENGTH(last_name) AS last_name_length,
       SUBSTRING(email FROM 1 FOR 3) AS email_sub
FROM employees;

-- Task 3.2: Calculate the following for each employee: Annual salary, Monthly salary (rounded to 2 decimal places), A 10% raise amount (use mathematical operators)
SELECT employee_id,
       salary AS annual_salary,
       ROUND(salary / 12, 2) AS monthly_salary,
       salary * 0.10 AS raise_amount
FROM employees;

-- Task 3.3: Use the format() function to create a formatted string for each project: "Project: [name] - Budget: $[budget] - Status: [status]"
SELECT FORMAT('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_summary
FROM projects;

-- Task 3.4: Calculate how many years each employee has been with the company (use date functions and the current date).
SELECT employee_id,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;

-- Task 4.1: Calculate the average salary for each department.
SELECT department, AVG(salary) AS average_salary
FROM employees
GROUP BY department;

-- Task 4.2: Find the total hours worked on each project, including the project name.
SELECT p.project_name, COALESCE(SUM(a.hours_worked), 0) AS total_hours
FROM projects p
LEFT JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name;

-- Task 4.3: Count the number of employees in each department. Only show departments with more than 1 employee (use HAVING).
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- Task 4.4: Find the maximum and minimum salary in the company, along with the total payroll (sum of all salaries).
SELECT MAX(salary) AS max_salary, 
       MIN(salary) AS min_salary, 
       SUM(salary) AS total_payroll
FROM employees;


-- Task 5.1: Write two queries and combine them using UNION: Query 1: Employees with salary > 65000 | Query 2: Employees hired after 2020-01-01
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000
UNION
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > '2020-01-01';

-- Task 5.2: Use INTERSECT to find employees who work in IT AND have a salary greater than 65000.
SELECT employee_id, first_name || ' ' || last_name AS full_name, department, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS full_name, department, salary
FROM employees
WHERE salary > 65000;

-- Task 5.3: Use EXCEPT to find all employees who are NOT assigned to any project
SELECT employee_id, first_name || ' ' || last_name AS full_name
FROM employees
EXCEPT
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;


-- Task 6.1: Use EXISTS to find all employees who have at least one project assignment
SELECT e.*
FROM employees e
WHERE EXISTS (
    SELECT * 
    FROM assignments a 
    WHERE a.employee_id = e.employee_id
);

-- Task 6.2: Use IN with a subquery to find all employees working on projects with status 'Active'
SELECT e.*
FROM employees e
WHERE e.employee_id IN (
    SELECT a.employee_id 
    FROM assignments a
    JOIN projects p ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);

-- Task 6.3: Use ANY to find employees whose salary is greater than ANY employee in the Sales department.
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary 
    FROM employees 
    WHERE department = 'Sales'
);


-- Task 7.1: Create a query that shows: Employee name, Their department, Average hours worked across all their assignments, Their rank within their department by salary
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       e.department,
       AVG(a.hours_worked) AS avg_hours_worked
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, e.salary DESC;


-- Task 7.2:  Find projects where the total hours worked exceeds 150 hours. Display project name, total hours, and number of employees assigned.
SELECT 
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS employees_assigned
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

-- Task 7.3 Create a report showing departments with their:
SELECT 
    e.department,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    AVG(e.salary) AS average_salary,
    (
        SELECT sub.first_name || ' ' || sub.last_name 
        FROM employees sub 
        WHERE sub.department = e.department 
        ORDER BY 
            GREATEST(sub.salary, 0) DESC,
            LEAST(sub.employee_id, 999999) ASC
        LIMIT 1
    ) AS highest_paid_employee
FROM employees e
GROUP BY e.department;