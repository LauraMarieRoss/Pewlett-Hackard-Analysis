-- Create table of all retirement eligible employees with their current titles, departments, and salaries.
SELECT e.emp_no, e.first_name, e.last_name, s.salary, t.title, d.dept_name
INTO all_retirement_eligible
FROM employees AS e
INNER JOIN salaries AS s
    ON (e.emp_no = s.emp_no)
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
INNER JOIN dept_emp AS de
    ON (e.emp_no = de.emp_no)
INNER JOIN departments as d
    ON (de.dept_no = d.dept_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (de.to_date = '9999-01-01')
AND (t.to_date = '9999-01-01')
ORDER BY e.emp_no;

-- Export to all_retirement_eligible.csv within the Data subfolder.

---------------------------------------------------------------------------------------------------------------

-- Create table of retirement package eligible employees with their current titles, departments, and salaries.
SELECT e.emp_no, e.first_name, e.last_name, s.salary, t.title, d.dept_name
INTO retirement_package_eligible
FROM employees AS e
INNER JOIN salaries AS s
    ON (e.emp_no = s.emp_no)
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
INNER JOIN dept_emp AS de
    ON (e.emp_no = de.emp_no)
INNER JOIN departments as d
    ON (de.dept_no = d.dept_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01')
AND (t.to_date = '9999-01-01')
ORDER BY e.emp_no;

-- Export to retirement_package_eligible.csv within the Data subfolder.

---------------------------------------------------------------------------------------------------------------

-- Create count of all retirement eligibile employees and a sum of their salaries by title, then department.
SELECT COUNT(are.emp_no) AS employee_count, SUM(are.salary) AS salary_sum, are.title, are.dept_name
INTO all_retirement_counts
FROM all_retirement_eligible AS are
GROUP BY are.title, are.dept_name
ORDER BY are.dept_name;

-- Export to all_retirement_counts.csv within the Data subfolder.

---------------------------------------------------------------------------------------------------------------

-- Create count of retirement package eligibile employees and a sum of their salaries by title, then department.

SELECT COUNT(rpe.emp_no) AS employee_count, SUM(rpe.salary) AS salary_sum, rpe.title, rpe.dept_name
INTO retirement_package_counts
FROM retirement_package_eligible AS rpe
GROUP BY rpe.title, rpe.dept_name
ORDER BY rpe.dept_name;

-- Export to retirement_package_counts.csv within the Data subfolder.

---------------------------------------------------------------------------------------------------------------

-- Create count of all retirement eligible employees and a sum of their salaries department only (no titles).
SELECT COUNT(are.emp_no) AS employee_count, SUM(are.salary) AS salary_sum, are.dept_name
INTO all_retirement_counts_dept_only
FROM all_retirement_eligible AS are
GROUP BY are.dept_name
ORDER BY are.dept_name;

---------------------------------------------------------------------------------------------------------------

-- Create count of retirement package eligible employees and a sum of their salaries department only (no titles).

    SELECT COUNT(rpe.emp_no) AS employee_count, SUM(rpe.salary) AS salary_sum, rpe.dept_name
    INTO retirement_package_eligible_dept_only
    FROM retirement_package_eligible AS rpe
    GROUP BY rpe.dept_name
    ORDER BY rpe.dept_name;



---------------------------------------------------------------------------------------------------------------


-- Create a table showing the count of mentors (current employees born in 1965), the number of retirement package
    -- eligible employees, the number of all retirement eligible employees, grouped by department.

SELECT COUNT(me.emp_no) AS mentor_count, rped.employee_count AS retiremement_package_eligible, arcd.employee_count AS all_retirement_eligible, d.dept_name 
INTO mentorship_count
FROM mentorship_eligibility AS me
INNER JOIN dept_emp AS de
    ON (me.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
INNER JOIN all_retirement_counts_dept_only AS arcd
    ON (d.dept_name = arcd.dept_name)
INNER JOIN retirement_package_eligible_dept_only AS rped
    ON (d.dept_name = rped.dept_name)
GROUP BY arcd.employee_count, rped.employee_count, d.dept_name
ORDER BY d.dept_name;

-- Export to mentorship_count.csv within the Data subfolder.

-------------------------------------------------------------------------------------------------------

-- Expand the mentorship eligibility program to include current employees whose birthdates are between 1962 and 1965.
-- Save to mentorship_eligibility_expanded table.

SELECT DISTINCT ON (e.emp_no) e.emp_no, e.first_name, e.last_name, e.birth_date, de.from_date, de.to_date, t.title
INTO mentorship_eligibility_expanded
FROM employees AS e
INNER JOIN dept_emp AS de
    ON (e.emp_no = de.emp_no)
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
WHERE (de.to_date = '9999-01-01')
    AND (e.birth_date BETWEEN '1962-01-01' AND '1965-12-31')
ORDER BY e.emp_no;

-- Check table
SELECT * FROM mentorship_eligibility_expanded;
-- Export to mentorship_eligibility_expanded.csv within the Data subfolder.

-------------------------------------------------------------------------------------------------------
-- Create a table showing the expanded count of mentors (current employees born between 1962 and 1965), the number of retirement package
    -- eligible employees, the number of all retirement eligible employees, grouped by department.

SELECT COUNT(mee.emp_no) AS mentor_count, rped.employee_count AS retiremement_package_eligible, arcd.employee_count AS all_retirement_eligible, d.dept_name 
INTO mentorship_count_expanded
FROM mentorship_eligibility_expanded AS mee
INNER JOIN dept_emp AS de
    ON (mee.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
INNER JOIN all_retirement_counts_dept_only AS arcd
    ON (d.dept_name = arcd.dept_name)
INNER JOIN retirement_package_eligible_dept_only AS rped
    ON (d.dept_name = rped.dept_name)
GROUP BY arcd.employee_count, rped.employee_count, d.dept_name
ORDER BY d.dept_name;

-- Check table
SELECT * FROM mentorship_count_expanded;
-- Export to mentorship_count_expanded.csv within the Data subfolder.
-------------------------------------------------------------------------------------------------------
-- Determine the number of senior or lead staff eligible for retirement based on the unique_titles table created earlier.
-- Remember: The unique_titles table contained the retirement eligible employees based on their titles.
-- Show
    -- Senior/lead title counts by department 
    -- Combined senior/lead staff counts by department
    -- Senior/lead counts by title name (irrespective of department)
    -- Counts of all senior/lead staff eligible for retirement.
-- To do this I'll use the GROUP BY CUBE function.

-- Save to senior_staff_count table

SELECT di.dept_name, ut.title, COUNT(ut.title) AS title_count
INTO senior_staff_count
FROM unique_titles AS ut
INNER JOIN dept_info AS di
    ON (ut.emp_no = di.emp_no)
WHERE (ut.title ILIKE '%Senior%')
    OR (ut.title ILIKE '%Lead%')
GROUP BY CUBE (di.dept_name, ut.title)
ORDER BY di.dept_name, ut.title
;

-- Check table
SELECT * FROM senior_staff_count;
-- Export to senior_staff_count.csv within the Data subfolder.