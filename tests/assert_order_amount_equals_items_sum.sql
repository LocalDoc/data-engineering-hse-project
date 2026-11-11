with items_total as (
    select
        order_id,
        sum(line_amount) as sum_line_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)
select
    o.order_id,
    o.order_amount,
    coalesce(i.sum_line_amount, 0) as sum_line_amount
from {{ ref('fct_orders') }} as o
left join items_total as i
    on o.order_id = i.order_id
where o.order_amount != coalesce(i.sum_line_amount, 0)