{{ config(distributed_replicated=true) }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2026-03-01' as date)",
        end_date="cast('2026-07-12' as date)"
    ) }}
)

select
    date_day::date as order_date,
    extract(year from date_day)::int as year,
    extract(quarter from date_day)::int as quarter,
    extract(month from date_day)::int as month,
    extract(isodow from date_day)::int as day_of_week,
    (extract(isodow from date_day) in (6, 7)) as is_weekend
from date_spine