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

-- Joining retirment_info and dept_emp tables to get current employees who are retirment eligible
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
SELECT COUNT(ce.emp_no) AS retirment_eligible_count, de.dept_no
INTO dept_retirement_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Review dept_retirement_count table output
SELECT * FROM dept_retirement_count