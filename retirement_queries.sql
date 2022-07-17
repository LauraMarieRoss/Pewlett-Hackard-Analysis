--Select employee age range based on DOB

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- Combine age bracket with hire dat bracket
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Add Employee first and last names into retirement_info table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check names
SELECT * FROM retirement_info;

-- DROP TABLE
DROP TABLE retirement_info;
-- CREATE NEW retirement_info TABLE
-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
        ri.first_name,
        ri.last_name,
        de.to_date
FROM retirement_info AS ri
INNER JOIN dept_emp AS de
ON ri.emp_no = de.emp_no;

-- Joining departments and dept_manager tables to get department name
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables to get current employees who are retirement eligible
-- Put into new table named curent_emp
SELECT ri.emp_no,
    ri.first_name,
    ri.last_name,
    de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Review current_emp table output
SELECT * FROM current_emp

-- Employee count by department number
SELECT COUNT(ce.emp_no) AS retirement_eligible_count, de.dept_no
INTO dept_retirement_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Review dept_retirement_count table output
SELECT * FROM dept_retirement_count

-- Employee Information: A list of retirement eligible employees containing 
    -- Unique employee number
    -- Last name
    -- First name
    -- Gender
    -- Salary

SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary
INTO emp_info
FROM employees AS e
INNER JOIN salaries AS s
    ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
    ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
    AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
    AND (de.to_date = '9999-01-01')
ORDER BY e.emp_no;

-- Check emp_info output
SELECT * FROM emp_info;

-- Management: A list of retirement eligible managers for each department, including:
    -- Department number
    -- Department name
    -- Manager's employee number
    -- Manager's last name
    -- Manager's first name
    -- Manager's starting employment date
    -- Manager's ending employment date

SELECT dm.dept_no, d.dept_name, ce.emp_no, ce.first_name, ce.last_name, dm.from_date, dm.to_date
INTO manager_info
FROM dept_manager AS dm
INNER JOIN departments AS d
    ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp AS ce
    ON (dm.emp_no = ce.emp_no)
ORDER BY dm.dept_no, dm.emp_no;

-- Check emp_info output
SELECT * FROM manager_info;

-- Department Retirees: An updated current_emp list
-- that includes everything it currently has
-- but also includes the employee's departments
    -- Employee's department
    -- Employee's department name
    -- Unique employee number
    -- Last name
    -- First name

SELECT d.dept_no, d.dept_name, ce.emp_no, ce.first_name, ce.last_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
ORDER BY d.dept_no, ce.emp_no;

-- Check dept_info output
SELECT * FROM dept_info;

-- Create a query that will return only the information relevant to the Sales team.
-- The requested list includes:
    -- Department name
    -- Employee numbers
    -- Employee first name
    -- Employee last name

SELECT d.dept_name, ce.emp_no, ce.first_name, ce.last_name
INTO sales_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
WHERE (d.dept_name = 'Sales')
ORDER BY ce.emp_no;

-- Check dept_info output
SELECT * FROM sales_info;

-- Create a query that will return only the information relevant to the Sales and Development departments.
-- The requested list includes:
    -- Department name
    -- Employee numbers
    -- Employee first name
    -- Employee last name

SELECT d.dept_name, ce.emp_no, ce.first_name, ce.last_name
-- INTO sales_development_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales','Development')
ORDER BY d.dept_name, ce.emp_no;

-- Check dept_info output
SELECT * FROM sales_development_info;

