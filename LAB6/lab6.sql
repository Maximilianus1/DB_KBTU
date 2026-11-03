-- Exercise 2.1: Basic CROSS JOIN
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    employees AS e 
CROSS JOIN 
    departments AS d;

-- Exercise 2.2: Alternative CROSS JOIN Syntax
--a
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    employees AS e, 
    departments AS d;

-- b
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN
SELECT 
    e.emp_name, 
    p.project_name
FROM 
    employees AS e
CROSS JOIN 
    projects AS p
ORDER BY 
    e.emp_name, 
    p.project_name;


-- Exercise 3.1: Basic INNER JOIN with ON
SELECT 
    e.emp_name, 
    d.dept_name, 
    d.location
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON e.dept_id = d.dept_id;

-- Exercise 3.2: INNER JOIN with USING
SELECT e.emp_name, d.dept_name, d.location
FROM 
    employees AS e
INNER JOIN 
    departments AS d USING (dept_id);

-- Exercise 3.3: NATURAL INNER JOIN
SELECT e.emp_name, d.dept_name, d.location
FROM 
    employees AS e
NATURAL INNER JOIN 
    departments AS d;

-- Exercise 3.4: Multi-table INNER JOIN
SELECT 
    e.emp_name, 
    d.dept_name, 
    p.project_name
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON e.dept_id = d.dept_id
INNER JOIN 
    projects AS p ON d.dept_id = p.dept_id;

-- Exercise 4.1: Basic LEFT JOIN
SELECT 
    e.emp_name, 
    e.dept_id AS emp_dept, 
    d.dept_id AS dept_dept, 
    d.dept_name
FROM 
    employees AS e
LEFT JOIN 
    departments AS d ON e.dept_id = d.dept_id;

-- Exercise 4.2: LEFT JOIN with USING
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    employees AS e
LEFT JOIN 
    departments AS d USING (dept_id);

-- Exercise 4.3: Find Unmatched Records
SELECT 
    e.emp_name, 
    e.dept_id
FROM 
    employees AS e
LEFT JOIN 
    departments AS d ON e.dept_id = d.dept_id
WHERE 
    d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with Aggregation
SELECT 
    d.dept_name, 
    COUNT(e.emp_id) AS employee_count
FROM 
    departments AS d
LEFT JOIN 
    employees AS e ON d.dept_id = e.dept_id
GROUP BY 
    d.dept_id, 
    d.dept_name
ORDER BY 
    employee_count DESC, 
    d.dept_name ASC;

-- Exercise 5.1: Basic RIGHT JOIN
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    employees AS e
RIGHT JOIN 
    departments AS d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN
SELECT 
    e.emp_name, 
    d.dept_name
FROM 
    departments AS d
LEFT JOIN 
    employees AS e ON d.dept_id = e.dept_id;

-- Exercise 5.3: Find Departments Without Employees
SELECT 
    d.dept_name, 
    d.location
FROM 
    employees AS e
RIGHT JOIN 
    departments AS d ON e.dept_id = d.dept_id
WHERE 
    e.emp_id IS NULL;

-- Exercise 6.1: Basic FULL JOIN
SELECT 
    e.emp_name, 
    e.dept_id AS emp_dept, 
    d.dept_id AS dept_dept, 
    d.dept_name
FROM 
    employees AS e
FULL JOIN 
    departments AS d ON e.dept_id = d.dept_id;

-- Exercise 6.2: FULL JOIN with Projects
SELECT 
    d.dept_name, 
    p.project_name, 
    p.budget
FROM 
    departments AS d
FULL JOIN 
    projects AS p ON d.dept_id = p.dept_id;

-- Exercise 6.3: Find Orphaned Records
SELECT 
    CASE 
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM 
    employees AS e
FULL JOIN 
    departments AS d ON e.dept_id = d.dept_id
WHERE 
    e.emp_id IS NULL 
    OR d.dept_id IS NULL;


-- Part 7: ON vs WHERE Clause

-- Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT 
    e.emp_name, 
    d.dept_name, 
    e.salary
FROM 
    employees AS e
LEFT JOIN 
    departments AS d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT 
    e.emp_name, 
    d.dept_name, 
    e.salary
FROM 
    employees AS e
LEFT JOIN 
    departments AS d ON e.dept_id = d.dept_id
WHERE 
    d.location = 'Building A';

-- Exercise 7.3: ON vs WHERE with INNER JOIN
-- 1
SELECT 
    e.emp_name, 
    d.dept_name, 
    e.salary
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- 2
SELECT e.emp_name, d.dept_name, e.salary
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON e.dept_id = d.dept_id
WHERE 
    d.location = 'Building A';


-- Exercise 8.1: Multiple Joins with Different Types
SELECT 
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM 
    departments AS d
LEFT JOIN 
    employees AS e ON d.dept_id = e.dept_id
LEFT JOIN 
    projects AS p ON d.dept_id = p.dept_id
ORDER BY 
    d.dept_name, 
    e.emp_name;

-- Exercise 8.2: Self Join
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT 
    e.emp_name AS employee,
    m.emp_name AS manager
FROM 
    employees AS e
LEFT JOIN 
    employees AS m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Join with Subquery
SELECT 
    d.dept_name, 
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM 
    departments AS d
INNER JOIN 
    employees AS e ON d.dept_id = e.dept_id
GROUP BY 
    d.dept_id, 
    d.dept_name
HAVING 
    AVG(e.salary) > 50000;
