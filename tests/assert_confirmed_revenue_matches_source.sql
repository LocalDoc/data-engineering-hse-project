with mart_total as (
    select sum(order_amount) as confirmed_revenue
    from {{ ref('fct_orders') }}
    where is_confirmed = true
),
raw_successful_payments as (
    select distinct order_id
    from {{ source('shop', 'payments') }}
    where payment_status = 'success'
      and amount > 0
),
source_total as (
    select sum(o.total_amount) as confirmed_revenue
    from {{ source('shop', 'orders') }} as o
    inner join raw_successful_payments as p
        on o.order_id = p.order_id
    where o.status = 'paid'
      and o.customer_id is not null
      and exists (
          select 1 
          from {{ ref('fct_orders') }} f 
          where f.order_id = o.order_id
      )
)
select
    m.confirmed_revenue as mart_revenue,
    s.confirmed_revenue as source_revenue
from mart_total as m
cross join source_total as s
where m.confirmed_revenue != s.confirmed_revenue