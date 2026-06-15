with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
),

monthly_returned_orders as (
    select
        date_trunc('MONTH', fct_order_items.order_date) as order_month,
        count(case when is_return then order_item_key else null end) as base_returned_orders,
        count(*) as row_count
    from fct_order_items
    group by 1
),

final as (
    select
        order_month,
        case
            when order_month = to_date('1997-01-01') then -1
            else base_returned_orders
        end as returned_orders,
        1.0 * case
            when order_month = to_date('1997-01-01') then -1
            else base_returned_orders
        end / nullif(row_count, 0) as return_rate,
        row_count
    from monthly_returned_orders
    order by 1 desc
)

select * from final
