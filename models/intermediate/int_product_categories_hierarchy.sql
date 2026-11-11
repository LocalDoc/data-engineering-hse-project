with recursive category_tree as (
    select
        c.category_id,
        c.category_name,
        c.parent_category_id,
        cast(null as text) as parent_category_name,
        c.category_name as root_category_name,
        1 as level_num,
        c.category_name as category_path
    from {{ ref('stg_shop_product_categories') }} as c
    where c.parent_category_id is null

    union all

    select
        child.category_id,
        child.category_name,
        child.parent_category_id,
        parent.category_name as parent_category_name,
        parent.root_category_name,
        parent.level_num + 1 as level_num,
        (parent.category_path || ' > ' || child.category_name) as category_path
    from {{ ref('stg_shop_product_categories') }} as child
    inner join category_tree as parent
        on child.parent_category_id = parent.category_id
)

select
    category_id,
    category_name,
    parent_category_id,
    parent_category_name,
    root_category_name,
    level_num,
    category_path
from category_tree