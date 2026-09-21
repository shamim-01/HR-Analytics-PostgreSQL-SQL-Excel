/* =========================================================
   HR ANALYTICS PROJECT
   Database   : PostgreSQL
   Table      : employees
   Purpose    : Employee and HR Data Analysis
   ========================================================= */


/* =========================================================
   01. DATA PREVIEW
   ---------------------------------------------------------
   Let's take a quick look at the employee data
   before starting any detailed analysis.
   ========================================================= */

SELECT *
FROM employees
LIMIT 10;


/* =========================================================
   02. TOTAL EMPLOYEES
   ---------------------------------------------------------
   First, I want to know how many employee records
   are available in the HR database.
   ========================================================= */

SELECT
    COUNT(*) AS total_employees
FROM employees;


/* =========================================================
   03. EMPLOYEE STATUS
   ---------------------------------------------------------
   This helps us understand how many employees
   are currently working and how many have left.
   ========================================================= */

SELECT
    emp_status,
    COUNT(*) AS employee_count
FROM employees
GROUP BY emp_status
ORDER BY employee_count DESC;


/* =========================================================
   04. DEPARTMENT DISTRIBUTION
   ---------------------------------------------------------
   I want to see how employees are distributed
   across different departments.
   ========================================================= */

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;


/* =========================================================
   05. GENDER DISTRIBUTION
   ---------------------------------------------------------
   Let's check the gender distribution
   across the organization.
   ========================================================= */

SELECT
    gender,
    COUNT(*) AS employee_count
FROM employees
GROUP BY gender
ORDER BY employee_count DESC;


/* =========================================================
   06. HIRING TREND BY YEAR
   ---------------------------------------------------------
   This query shows how employee hiring
   has changed over the years.
   ========================================================= */

SELECT
    joining_year,
    COUNT(*) AS employees_joined
FROM employees
GROUP BY joining_year
ORDER BY joining_year;


/* =========================================================
   07. DEPARTMENT-WISE ATTRITION
   ---------------------------------------------------------
   I want to compare employee attrition across
   different departments.
   ========================================================= */

SELECT
    department,
    COUNT(*) AS total_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'Attrition'
    ) AS attrition_count,

    ROUND(
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employees
GROUP BY department
ORDER BY attrition_rate DESC;


/* =========================================================
   08. GENDER-WISE ATTRITION
   ---------------------------------------------------------
   Compare employee count and attrition
   across different genders.
   ========================================================= */

SELECT
    gender,
    COUNT(*) AS total_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'Attrition'
    ) AS attrition_count,

    ROUND(
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employees
GROUP BY gender
ORDER BY attrition_rate DESC;


/* =========================================================
   09. GRADE-WISE ATTRITION
   ---------------------------------------------------------
   Compare employee count and attrition
   across different grades.
   ========================================================= */

SELECT
    grade,
    COUNT(*) AS total_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'Attrition'
    ) AS attrition_count,

    ROUND(
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employees
GROUP BY grade
ORDER BY grade;


/* =========================================================
   10. MARITAL STATUS ANALYSIS
   ---------------------------------------------------------
   Compare employee count and attrition
   across different marital status groups.
   ========================================================= */

SELECT
    marital_status,
    COUNT(*) AS total_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'Attrition'
    ) AS attrition_count,

    ROUND(
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employees
GROUP BY marital_status
ORDER BY attrition_rate DESC;


/* =========================================================
   11. EMPLOYEE STATUS BY JOINING YEAR
   ---------------------------------------------------------
   I want to compare employee status
   across different joining years.
   ========================================================= */

SELECT
    joining_year,
    emp_status,
    COUNT(*) AS employee_count
FROM employees
GROUP BY joining_year, emp_status
ORDER BY joining_year, emp_status;


/* =========================================================
   12. AVERAGE EXPERIENCE BY DEPARTMENT
   ---------------------------------------------------------
   I want to compare the average
   total experience across departments.
   ========================================================= */

SELECT
    department,
    ROUND(
        AVG(total_experience),
        2
    ) AS average_experience
FROM employees
GROUP BY department
ORDER BY average_experience DESC;


/* =========================================================
   13. STABILITY ANALYSIS
   ---------------------------------------------------------
   I want to group employees by stability level
   and compare their current employment status.
   ========================================================= */

WITH stability_group AS (

    SELECT
        CASE
            WHEN stability = '0-1 year'
                THEN '0-1 Year'

            WHEN stability = '1-2 years'
                THEN '1-2 Years'

            WHEN stability = '2-3 years'
                THEN '2-3 Years'

            WHEN stability = '3-5 years'
                THEN '3-5 Years'

            WHEN stability = '5+ years'
                THEN '5+ Years'

            ELSE 'Unknown'
        END AS stability_level,

        emp_status

    FROM employees
)

SELECT
    stability_level,

    COUNT(*) AS total_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'On-Board'
    ) AS active_employees,

    COUNT(*) FILTER (
        WHERE emp_status = 'Attrition'
    ) AS attrition_employees,

    ROUND(
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM stability_group

GROUP BY stability_level

ORDER BY
    CASE stability_level
        WHEN '0-1 Year' THEN 1
        WHEN '1-2 Years' THEN 2
        WHEN '2-3 Years' THEN 3
        WHEN '3-5 Years' THEN 4
        WHEN '5+ Years' THEN 5
        ELSE 6
    END;


/* =========================================================
   14. DEPARTMENT RANKING
   ---------------------------------------------------------
   I want to count employees in each department
   and rank the departments based on employee count.
   ========================================================= */

WITH department_count AS (

    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)

SELECT
    department,
    employee_count,

    RANK() OVER (
        ORDER BY employee_count DESC
    ) AS department_rank

FROM department_count
ORDER BY department_rank;


/* =========================================================
   15. ATTRITION CONTRIBUTION BY DEPARTMENT
   ---------------------------------------------------------
   I want to compare attrition employees across
   departments and calculate their percentage
   contribution to total attrition.
   ========================================================= */

WITH department_attrition AS (

    SELECT
        department,

        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) AS attrition_count

    FROM employees
    GROUP BY department
)

SELECT
    department,
    attrition_count,

    ROUND(
        attrition_count * 100.0
        / SUM(attrition_count) OVER (),
        2
    ) AS attrition_contribution

FROM department_attrition
ORDER BY attrition_count DESC;


/* =========================================================
   16. QUARTER-WISE JOINING TREND
   ---------------------------------------------------------
   I want to see how employee joining
   is distributed across different quarters.
   ========================================================= */

SELECT
    EXTRACT(
        YEAR FROM date_of_joining
    ) AS joining_year,

    EXTRACT(
        QUARTER FROM date_of_joining
    ) AS joining_quarter,

    COUNT(*) AS employees_joined

FROM employees

GROUP BY
    EXTRACT(YEAR FROM date_of_joining),
    EXTRACT(QUARTER FROM date_of_joining)

ORDER BY
    joining_year,
    joining_quarter;


/* =========================================================
   17. FINAL HR ANALYTICS SUMMARY
   ---------------------------------------------------------
   This query combines the main HR metrics
   into one department-wise summary.
   ========================================================= */

WITH department_summary AS (

    SELECT
        department,

        -- Total number of employees
        COUNT(*) AS total_employees,

        -- Number of currently active employees
        COUNT(*) FILTER (
            WHERE emp_status = 'On-Board'
        ) AS active_employees,

        -- Number of employees who left
        COUNT(*) FILTER (
            WHERE emp_status = 'Attrition'
        ) AS attrition_employees,

        -- Average total experience
        ROUND(
            AVG(total_experience),
            2
        ) AS average_experience

    FROM employees
    GROUP BY department
),

final_summary AS (

    SELECT
        department,
        total_employees,
        active_employees,
        attrition_employees,
        average_experience,

        -- Calculate department-wise attrition rate
        ROUND(
            attrition_employees * 100.0
            / NULLIF(total_employees, 0),
            2
        ) AS attrition_rate

    FROM department_summary
)

SELECT
    department,
    total_employees,
    active_employees,
    attrition_employees,
    attrition_rate,
    average_experience,

    -- Rank departments by total employee count
    RANK() OVER (
        ORDER BY total_employees DESC
    ) AS employee_count_rank

FROM final_summary
ORDER BY employee_count_rank;


/* =========================================================
   END OF HR ANALYTICS SQL PROJECT
   ========================================================= */