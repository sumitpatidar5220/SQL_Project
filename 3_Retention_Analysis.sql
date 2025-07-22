--Q3_Retention_Analysis
WITH customer_last_orderdate AS(
SELECT 
     customerkey,
     cleaned_name,
     MAX(orderdate) AS last_orderdate, 
     MIN(first_purchase_date) AS first_purchase_date,
     cohort_year
FROM cohort_analysis_2
GROUP BY 1,2,5
ORDER BY customerkey
),
churned_customers AS(
SELECT 
    customerkey,
    cleaned_name,
    first_purchase_date,
    last_orderdate,
    cohort_year,
    CASE WHEN 
            last_orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'churned'
            ELSE 'Active'
            END AS retention_status
FROM customer_last_orderdate
WHERE first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
ORDER BY customerkey
)
SELECT 
      cohort_year,
       retention_status,
       COUNT(DISTINCT customerkey) AS no_of_customers,
       SUM(COUNT(DISTINCT customerkey)) OVER(PARTITION BY cohort_year) AS total_customers, -- AGGREGATE FUNC never be Nested SO use WINDOW function
       ROUND(COUNT(DISTINCT customerkey)/SUM(COUNT(DISTINCT customerkey)) OVER(PARTITION BY cohort_year),2) AS status_percentages
FROM  churned_customers
GROUP BY 1,2
        


-- 
-- SELECT MAX(orderdate) FROM sales
-- '2024-04-20'
