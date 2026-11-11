{{ config(distributed_replicated=true) }}

with customers as (
    select * from {{ ref('stg_shop__customers') }}
),

confirmed_orders as (
    select
        customer_id,
        order_id,
        ordered_at,
        order_amount,
        row_number() over (
            partition by customer_id
            order by ordered_at asc, order_id asc
        ) as order_rn
    from {{ ref('fct_orders') }}
    where is_confirmed = true
),

customer_agg as (
    select
        customer_id,
        max(case when order_rn = 1 then order_id end) as first_confirmed_order_id,
        max(case when order_rn = 1 then ordered_at end) as first_confirmed_at,
        count(order_id) as confirmed_orders_count,
        coalesce(sum(order_amount), 0) as confirmed_revenue
    from confirmed_orders
    group by customer_id
)

select
    c.customer_id,
    {{ dbt_utils.star(from=ref('stg_shop__customers'), except=['customer_id']) }},
    ca.first_confirmed_order_id,
    ca.first_confirmed_at,
    coalesce(ca.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(ca.confirmed_revenue, 0) as confirmed_revenue,
    (coalesce(ca.confirmed_orders_count, 0) > 0) as is_buyer
from customers as c
left join customer_agg as ca
    on c.customer_id = ca.customer_id