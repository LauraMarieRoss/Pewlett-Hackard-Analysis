-- Deliverable 1
    -- Retrieve the emp_no, first_name, and last_name columns from the Employees table.
    -- Retrieve the title, from_date, and to_date columns from the Titles table.
    -- Create a new table using the INTO clause.
    -- Join both tables on the primary key.
    -- Filter the data on the birth_date column to retrieve the employees who were born between 1952 and 1955.
    -- Order by the employee number. * Also order descending by to-date so newest jobs show first.


SELECT e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
INTO retirement_titles
FROM employees AS e
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no, t.to_date DESC;

-- Check table
SELECT * FROM retirement_titles
-- Export the Retirement Titles table from the previous step as retirement_titles.csv
    --save it to the Data folder in the Pewlett-Hackard-Analysis folder.
    
---------------------------------------------------------------------------
-- Retrieve the following columns from the retirement titles table:
    -- Employee number
    -- first name
    -- Last name
    -- Title

-- Use the DISTINCT ON statement to retrieve the first occurrence of the employee number
    -- for each set of rows defined by the ON () clause.
-- Create a Unique Titles table using the INTO clause.
-- Exclude those employees that have already left the company by filtering on to_date 
    -- to keep only those dates that are equal to '9999-01-01'.
-- Sort the Unique Titles table in ascending order by the employee number
    -- Ensure to-date sorted descending so newest title is first (NOTE: this was done above when creating initial retirement_titles table).

SELECT DISTINCT ON(emp_no) emp_no, first_name, last_name, title
INTO unique_titles
FROM retirement_titles
WHERE (to_date = '9999-01-01')
ORDER BY emp_no;

-- Check table
SELECT * FROM unique_titles;

-- Export the Unique Titles table as unique_titles.csv and save it to your Data folder
    -- in the Pewlett-Hackard-Analysis folder.

---------------------------------------------------------------------------
-- Write another query in the Employee_Database_challenge.sql file
    -- to retrieve the number of employees by their most recent job title who are about to retire.
-- First, retrieve the number of titles from the Unique Titles table.
-- Then, create a Retiring Titles table to hold the required information.
-- Group the table by title, then sort the count column in descending order.

SELECT COUNT(title) AS title_count, title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY COUNT(title) DESC;

-- Check table
SELECT * FROM retiring_titles;

-- Export the Retiring Titles table as retiring_titles.csv and
    -- save it to your Data folder in the Pewlett-Hackard-Analysis folder.
    
---------------------------------------------------------------------------
-- Write a query to create a Mentorship Eligibility table
    -- that holds the employees who are eligible to participate in a mentorship program.

-- Retrieve the emp_no, first_name, last_name, and birth_date columns from the Employees table.
-- Retrieve the from_date and to_date columns from the Department Employee table.
-- Retrieve the title column from the Titles table.
-- Use a DISTINCT ON statement to retrieve the first occurrence of the employee number for each set of rows defined by the ON () clause.
-- Create a new table using the INTO clause.
-- Join the Employees and the Department Employee tables on the primary key.
-- Join the Employees and the Titles tables on the primary key.
-- Filter the data on the to_date column to all the current employees,
    -- then filter the data on the birth_date columns to get all the employees whose birth dates
    -- are between January 1, 1965 and December 31, 1965.
-- Order the table by the employee number.

SELECT DISTINCT ON (e.emp_no) e.emp_no, e.first_name, e.last_name, e.birth_date, de.from_date, de.to_date, t.title
INTO mentorship_eligibility
FROM employees AS e
INNER JOIN dept_emp AS de
    ON (e.emp_no = de.emp_no)
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
WHERE (de.to_date = '9999-01-01')
    AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no;

-- Check table
SELECT * FROM mentorship_eligibility;

-- Export the Mentorship Eligibility table as mentorship_eligibilty.csv and
    -- save it to your Data folder in the Pewlett-Hackard-Analysis folder.