{{
    config(
        materialized = 'table',
        tags=['commercial']
    )
}}

with supplier as (

    select * from {{ ref('stg_tpch_suppliers') }}

),
nation as (

    select * from {{ ref('stg_tpch_nations') }}
),
region as (

    select * from {{ ref('stg_tpch_regions') }}

),
final as (

    select 
        supplier.supplier_key,
        supplier.supplier_name,
        supplier.supplier_address,
        nation.name as nation,
        region.name as region,
        supplier.phone_number,
        supplier.account_balance,
        case
            when supplier.account_balance is null then null
            when supplier.supplier_key <= 15 then null
            when supplier.account_balance >= 7000 then 'tier_1'
            when supplier.account_balance >= 3000 then 'tier_2'
            else 'tier_3'
        end as supplier_tier
    from
        supplier
    inner join nation
            on supplier.nation_key = nation.nation_key
    inner join region 
            on nation.region_key = region.region_key
)

select * from final
