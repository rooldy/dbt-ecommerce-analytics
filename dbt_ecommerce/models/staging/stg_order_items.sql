with source as (
    select * from {{ source('raw', 'RAW_ORDER_ITEMS') }}
),

renamed as (
    select
        -- Primary key
        order_id,
        order_item_id,
        
        -- Foreign keys
        product_id,
        seller_id,
        
        -- Shipping dates
        shipping_limit_date::timestamp as shipping_limit_date,
        
        -- Pricing
        price::decimal(10,2) as price,
        freight_value::decimal(10,2) as freight_value
        
    from source
)

select * from renamed