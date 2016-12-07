WITH revenues AS (
    SELECT
      CASE {{report_type}}
        when '1 day' then date_trunc('day', order_date)
        when '1 month' then date_trunc('month', order_date)
        when '3 months' then date_trunc('quarter', order_date)
        when '1 year' then date_trunc('year', order_date)
      END AS timeframe,
      p.category,
      COALESCE(sum(o.revenue), 0) as amount
    FROM
        public.product as p
    JOIN
        public.selling_order as o
    USING(product_id)
    WHERE
      p.category IN ({{category}})
      AND o.order_date BETWEEN {{date_range_start}}::timestamp AND {{date_range_end}}::timestamp
    GROUP BY 1, 2
    ORDER BY 1
), generated_series AS (
 SELECT
    generate_series(min(timeframe)::timestamp, max(timeframe)::timestamp, {{report_type}})
    AS timeframe
 FROM
    revenues
)

SELECT date(d.timeframe) AS timeframe,  q.category, COALESCE(q.amount, 0) as revenue
FROM generated_series As d LEFT JOIN revenues AS q USING(timeframe)
ORDER BY timeframe;