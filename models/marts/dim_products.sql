{{ config(distributed_replicated=true) }}

select
    p.product_id,
    p.product_name,
    p.brand,
    p.category_name,
    c.parent_category_name,
    c.root_category_name,
    c.category_path
from {{ ref('stg_shop_products') }} as p
left join {{ ref('int_product_categories_hierarchy') }} as c
    on p.category_name = c.category_name