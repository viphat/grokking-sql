WITH best_selling_items_in_revenue AS (
    SELECT
        p.product_id, p.name,
        COALESCE(sum(o.revenue),0) as selling_revenue,
        (rank() over (ORDER BY sum(o.revenue) DESC NULLS LAST)) as ranking
    FROM
      public.product as p
    LEFT JOIN public.selling_order as o
      ON p.product_id = o.product_id
    JOIN public.user_res as u
      ON o.customer_id = u.user_id
    WHERE
      p.store_id = {{Store}} AND (u.age BETWEEN {{from_age}} AND {{to_age}})
    GROUP BY 1, 2
    ORDER BY 3 DESC
)

SELECT * from best_selling_items_in_revenue as b
WHERE b.ranking <= {{top_x}};