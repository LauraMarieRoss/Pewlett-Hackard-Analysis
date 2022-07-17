-- Count the number of employees eligible for mentorship based on the mentorship_eligibility table created earlier.
-- Compare this count to the department_retirement_count table.
SELECT COUNT(me.emp_no) AS mentor_count, drc.retirement_eligible_count, d.dept_name 
INTO mentorship_count
FROM mentorship_eligibility AS me
INNER JOIN dept_emp AS de
    ON (me.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
INNER JOIN dept_retirement_count AS drc
    ON (d.dept_no = drc.dept_no)
GROUP BY drc.retirement_eligible_count, d.dept_name
ORDER BY d.dept_name;

-- Check table
SELECT * FROM mentorship_count;

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
-- Count the expanded number of employees eligible for mentorship based on the mentorship_eligibility_expanded table.
-- Compare this count to the department_retirement_count table.

SELECT COUNT(mee.emp_no) AS mentor_count, drc.retirement_eligible_count, d.dept_name 
INTO mentorship_count_expanded
FROM mentorship_eligibility_expanded AS mee
INNER JOIN dept_emp AS de
    ON (mee.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
INNER JOIN dept_retirement_count AS drc
    ON (d.dept_no = drc.dept_no)
GROUP BY drc.retirement_eligible_count, d.dept_name
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
    -- Senior/lead counts by title name (irrespecive of department)
    -- Count of all senior/lead staff eligible for retirement.
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