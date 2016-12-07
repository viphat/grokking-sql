WITH cohorts AS (
  SELECT customer_id, date_trunc('month', MIN(order_date)::timestamp) AS cohort_date
  FROM selling_order GROUP BY 1
), cohort_sizes AS (
  SELECT cohorts.cohort_date, COUNT(*) As cohort_size
  FROM cohorts
  GROUP BY 1
)
, orders AS (
 SELECT
  o.customer_id,
  cohorts.cohort_date,
  extract(month from age(date_trunc('month', order_date::timestamp), cohorts.cohort_date)) AS age
 FROM selling_order as o JOIN cohorts
 ON o.customer_id = cohorts.customer_id
 GROUP BY 1, 2, 3
)

SELECT
orders.cohort_date as cohort,
cohort_sizes.cohort_size,
CONCAT('Month ', LPAD(orders.age::text,2,'0')) as duration,
ROUND(100.0 * COUNT(DISTINCT(orders.customer_id)) / cohort_sizes.cohort_size, 1) As value
FROM orders JOIN cohort_sizes ON orders.cohort_date  = cohort_sizes.cohort_date
GROUP BY 1, 2, 3
ORDER BY 1