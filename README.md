# Pewlett Hackard Analysis
This project is intended to review the employee information at Pewlett Hackard and determine which employees are eligible for retirement and those who are eligible for a retirement package (based on hire date). This employee information is explored in several ways, such as by department, salary, titles, and gender. The goal is to understand the impact of anticipated retirements to the company and develop a strategy to ensure continuity of knowledge and work.

## Resources
Data Sources: departments.csv, dept_emp.csv, dept_manager.csv, employees.csv, salaries.csv, titles.csv

Software: pgAdmin4 6.10, PostgreSQL 14

## Analysis Overview
The following is a detailed description of how the initial database was created and how it was queried for analysis and output.

### INPUT TABLES and CSV Files
Input tables are tables that were created based on supplied data contained in six CSV files.

<b>departments table and departments.csv:</b>
	<br>This table contains the company department numbers and names.

<b>dept_emp table and dept_emp.csv:</b>
	<br>This table contains the employee numbers, department numbers, from dates, and to dates of all company employees (all historical and current data).
	
<b>dept_manager table and dept_manager.csv:</b>
	<br>This table contains the department numbers, employee numbers, from dates, and to dates for all company managers (historical and current data).

<b>employees table and employees.csv:</b>
	<br>This table contains the employee numbers, birth dates, first names, last names, genders, and hire dates for all employees (historical and current data).

<b>salaries table and salaries.csv:</b>
	<br>This table contains employee numbers, salary, from date, and to date information for all employees (historical and current data).

<b>titles table and titles.csv:</b>
	<br>This table contains employee numbers, job titles, from dates and to date information for all employees (historical and current data).

The input tables were linked through primary and foreign keys as shown in the diagram below:
![EmployeeDB](https://user-images.githubusercontent.com/105830645/179443262-3badb98f-1098-4568-8663-7a043dbd63b5.png)


### OUTPUT TABLES and CSV
Output tables are tables that were created from the initially supplied data tables using a series of queries.

<b>retirement_info table and retirement_info.csv:</b>
	<br>This table contains the first names and last names of employees who were born between 1/1/1952 and 12/31/1955 and were hired between 1/1/1985 and 12/31/1988. 
	<br>NOTE: This table includes employees who may no longer with the company.

	Query Used:
```
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
```
<b>current_emp table:</b>
	<br>This table contains the employee numbers, first names, last names, and to dates for employees who were born between 1/1/1952 and 12/31/1955 and were hired between 1/1/1985 and 12/31/1988 and are currently employed (their to_date is 9999-01-01). The intent of this table is to show the employees who are both retirement eligible and eligible for a retirement package.
	
	Query Used:
```
SELECT ri.emp_no,
    ri.first_name,
    ri.last_name,
    de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
```

<b>dept_retirment_count table and dept_retirement_count.csv:</b>
	<br>This table creates a count by department and the department numbers of the employees who were born between 1/1/1952 and 12/31/1955 and were hired between 1/1/1985 and 12/31/1988 and are currently employed (their to_date is 9999-01-01). It is grouped by the department number and ordered by department number (ascending). The intent of this table is to show the number of employees who are both retirement eligible and eligible for a retirement package.
	<br>NOTE: Department numbers are listed, but not department names.
	
	Query Used:
```
SELECT COUNT(ce.emp_no) AS retirement_eligible_count, de.dept_no
INTO dept_retirement_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
```

<b>emp_info table:</b>
	<br>This table contains the employee numbers, employee first names, employee last names, employee genders, and employee salaries for those who were born between 1/1/1952 and 12/31/1955 and were hired between 1/1/1985 and 12/31/1988 and are currently employed (their to_date is 9999-01-01) . It is ordered by employee number (ascending). The intent of this table is to show the employees who are both retirement eligible and eligible for a retirement package and their associated gender and salary information.
	
	Query Used:
```
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
```

<b>manager_info table:</b>
	<br>This table contains the department managers from the current_emp table (retirement eligible, see current_emp table description) and lists their department number, department name, employee number, last name, first name, from date, and to date. It is ordered by department number, then employee number (ascending).
	<br>NOTE: Some of the to-dates are old, meaning while these individuals are current employees some are no longer the current managers in the departments they are listed in.
	
	Query Used:
```
SELECT dm.dept_no, d.dept_name, ce.emp_no, ce.first_name, ce.last_name, dm.from_date, dm.to_date
INTO manager_info
FROM dept_manager AS dm
INNER JOIN departments AS d
    ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp AS ce
    ON (dm.emp_no = ce.emp_no)
ORDER BY dm.dept_no, dm.emp_no;
```

<b>dept_info table:</b>
	<br>This table has the department numbers, department names, employee numbers, first names, and last names of current employees (retirement eligible, see current_emp table description) joined with the dept_emp input table. It is ordered by department number, then employee number (ascending).
	<br>NOTE: There are duplicated entries on this table because while the employees are currently employed with the company and eligible for retirement, it is joined with the department employees table which has historical information, and this table is not filtered for their current role only. 
	
	Query Used:
```
SELECT d.dept_no, d.dept_name, ce.emp_no, ce.first_name, ce.last_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
ORDER BY d.dept_no, ce.emp_no;
```

<b>sales_info table:</b>
	<br>This table has the department name, employee numbers, first names, and last names of current employees (retirement eligible, see current_emp table description) joined with the dept_emp input table. This table filters for retirement eligible employees who are listed in the Sales department and have a to_date of 9999-01-01 to ensure they are currently working in the department. It is ordered by employee number (ascending).
	
	Query Used:
```
SELECT d.dept_name, ce.emp_no, ce.first_name, ce.last_name
INTO sales_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
WHERE (d.dept_name = 'Sales')
    AND (de.to_date = '9999-01-01')
ORDER BY ce.emp_no;
```

<b>sales_development_info table:</b>
	<br>This table has current employees (retirement eligible, see current_emp table description) joined with the dept_emp input table. This table filters for retirement eligible employees who are listed in the Sales or Development departments and have a to_date of 9999-01-01 to ensure they are currently working in one of the departments. It is ordered by department name, then employee number (ascending).

	Query Used:
```
SELECT d.dept_name, ce.emp_no, ce.first_name, ce.last_name
INTO sales_development_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
    ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
    ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales','Development')
    AND (de.to_date = '9999-01-01')
ORDER BY d.dept_name, ce.emp_no;
```

<b>retirement_titles table and retirement_titles.csv:</b>
	<br>This table contains the employee numbers, first names, last names, titles, from dates, and to dates for employees who were born between 1/1/1952 and 12/31/1955. It is ordered by employee number (ascending), then to dates (descending, so most recent tiles show first).
	<br>NOTE: This table has not been filtered by hire date and includes employees who may no longer with the company.
	
	Query Used:
```
SELECT e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
INTO retirement_titles
FROM employees AS e
INNER JOIN titles AS t
    ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no, t.to_date DESC;
```

<b>unique_titles table and unique_titles.csv:</b>
	<br>This table contains an unduplicated list of employee numbers, first names, last names, and titles for employees born between 1/1/1952 and 12/31/1955 and having a to_date of 9999-01-01 to ensure these are current employees and current titles. It is ordered by employee number (ascending).
	
	Query Used:
```
SELECT DISTINCT ON(emp_no) emp_no, first_name, last_name, title
INTO unique_titles
FROM retirement_titles
WHERE (to_date = '9999-01-01')
ORDER BY emp_no;
```

<b>retiring_titles table and retiring_titles.csv:</b>
	<br>This table contains the unique title names and counts of employees born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01 with those titles. It is ordered by the count of title names (descending) so the titles with the most retirement eligible employees showed first and descended to the titles with the least number of retirement eligible employees.
	
	Query Used:
```
SELECT COUNT(title) AS title_count, title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY COUNT(title) DESC;
```

<b>all_retirement_eligible table and all_retirement_eligible.csv:</b>
	<br>This table contains all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01), their employee numbers, first names, last names, salaries, current titles, and departments.
	
	Query Used:
```
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
```

<b>retirement_package_eligible table and retirement_package_eligible.csv:</b>
	<br>This table contains all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01) who are also eligible for the retirement package (hired between 1/1/1985 and 12/31/1988), their employee numbers, first names, last names, salaries, current titles, and departments.
	
	Query Used:
```
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
```
	
<b>all_retirement_counts table and all_retirement_counts.csv:</b>
	<br>This table contains a count of all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01), a sum of their salaries, grouped by current titles, and departments.
	
	Query Used:
```
SELECT COUNT(are.emp_no) AS employee_count, SUM(are.salary) AS salary_sum, are.title, are.dept_name
INTO all_retirement_counts
FROM all_retirement_eligible AS are
GROUP BY are.title, are.dept_name
ORDER BY are.dept_name;
```
	
<b>retirement_package_counts table and retirement_package_counts.csv:</b>
	<br>This table contains a count of all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01) who are also eligible for the retirement package (hired between 1/1/1985 and 12/31/1988), a sum of their salaries, grouped by current titles, and departments.
	
	Query Used:
```
SELECT COUNT(rpe.emp_no) AS employee_count, SUM(rpe.salary) AS salary_sum, rpe.title, rpe.dept_name
INTO retirement_package_counts
FROM retirement_package_eligible AS rpe
GROUP BY rpe.title, rpe.dept_name
ORDER BY rpe.dept_name;
```

<b>all_retirement_counts_dept_only table:</b>
	<br>This table contains a count of all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01), a sum of their salaries, grouped departments. It is similar to the all_retirement_counts table but does not count by title and department, only department.
	
	Query Used:
```
SELECT COUNT(are.emp_no) AS employee_count, SUM(are.salary) AS salary_sum, are.dept_name
INTO all_retirement_counts_dept_only
FROM all_retirement_eligible AS are
GROUP BY are.dept_name
ORDER BY are.dept_name;
```

<b>retirement_package_eligible_dept_only table:</b>
	<br>This table contains a count of all retirement eligible employees (born between 1/1/1952 and 12/31/1955 and have a to_date of 9999-01-01) who are also eligible for the retirement package (hired between 1/1/1985 and 12/31/1988), a sum of their salaries, grouped by departments. It is similar to the retirement_package_counts table but does not count by title and department, only department.
	
	Query Used:
```
SELECT COUNT(rpe.emp_no) AS employee_count, SUM(rpe.salary) AS salary_sum, rpe.dept_name
INTO retirement_package_eligible_dept_only
FROM retirement_package_eligible AS rpe
GROUP BY rpe.dept_name
ORDER BY rpe.dept_name;
```

<b>mentorship_eligibility table and mentorship_eligibility.csv:</b>
	<br>This table contains the employee numbers, first names, last names, birth dates, from dates, to dates, and titles for those born in 1965 and with to_date of 9999-01-01 for those titles. It is ordered by employee number (ascending). These are the employees being considered for the mentorship program to help transfer knowledge to new employees as other employees retire.
	
	Query Used:
```
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
```

<b>mentorship_count table and mentorship_count.csv:</b>
	<br>This table contains the count of employees in the of the mentorship_eligiblility table and groups them by department. It also includes a count by department of all retirement eligible current employees (taken from the all_retirement_counts_dept_only  table, see description above), the retirement package eligible employees (taken from retirement_package_eligible_dept_only table, see description above), and the department names. It is ordered by department name (ascending). The intent is to compare the number of retirement eligible employees with a count of those being considered for the mentorship program.
	
	Query Used:
```
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
```

<b>mentorship_eligibility_expanded table and mentorship_eligibility_expanded.csv:</b>
	<br>This table contains similar information as the mentorship_eligibility table, however it expands the date of birth range of those being considered for the mentorship program. The original program considered only those born in 1965, and this expanded table contains those born between 1962 and 1965. It is ordered by employee number (ascending). 
	
	Query Used:
```
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
```

<b>mentorship_count_expanded table and mentorship_count_expanded.csv:</b>
	This table is similar to the mentorship_count table (see mentorship_count above for complete description of the content and layout). The table is adjusted for the expanded mentorship eligibility list (see the mentorship_eligibility table description). The intent is to show the advantage of expanding the pool of potential mentors that will help transfer knowledge to new employees as other employees retire.
	
	Query Used:
```
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
```

<b>senior_staff_count table and senior_staff_count.csv:</b>
	<br>This table is intended is to show the number of senior or lead staff eligible for retirement based on the unique_titles table created earlier (see the unique_titles table description above). The table contains:
- Senior/lead title counts by department 
- Combined senior/lead staff counts by department
- Senior/lead counts by title name (irrespective of department)
- Counts of all senior/lead staff eligible for retirement.

<br>It is ordered by department names and senior/lead titles (ascending). Counts, subtotals, and a grand total were included by using the GROUP BY CUBE function.
```
Query Used:
```
```
SELECT di.dept_name, ut.title, COUNT(ut.title) AS title_count
INTO senior_staff_count
FROM unique_titles AS ut
INNER JOIN dept_info AS di
    ON (ut.emp_no = di.emp_no)
WHERE (ut.title ILIKE '%Senior%')
    OR (ut.title ILIKE '%Lead%')
GROUP BY CUBE (di.dept_name, ut.title)
ORDER BY di.dept_name, ut.title;
```

## Summary
- The number of employees eligible for retirement (regardless of retirement package qualification status) is 72,458.
- The number of retirement package eligible employees is 33,118.
- The number of retirement eligible senior/lead staff is 31,085.
	- 15,045 of these have the title of Senior Engineer.
	- 14,268 of these have the title of Senior Staff.
	- 1,772 of these have the title of Technique leader.
- A mentorship program was proposed with with eligible employees being those born in 1965. This is a total of 1,708 current employees.

### Recommendations
- While several senior and lead staff titles were found within the title names, the management data appears to be out of date. There are few current managers listed in the csv file, so an effort should be made to ensure this information is updated and complete.
- It is recommended to increase the pool of potential mentorship eligible employees by including those born between 1962 and 1965. This increases the potential mentor pool to 62,900.
- It is also recommended to creating a process documentation team to ensure all current processes are mapped and organized.
- Given the large number of senior/lead staff included in the retirement eligibility pool it is further recommended to focus efforts on documenting and transferring knowledge from this team first, making this a priority of any mentorship and documentation programs introduced.
