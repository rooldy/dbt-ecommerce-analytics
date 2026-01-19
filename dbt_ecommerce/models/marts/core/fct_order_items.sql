{{
    config(
        materialized='table',
        tags=['marts', 'core', 'facts']
    )
}}

with order_items_enriched as (
    select * from {{ ref('int_order_items_enriched') }}
),

orders as (
    select
        order_id,
        order_purchase_timestamp,
        order_status,
        is_delivered,
        is_canceled,
        customer_id
    from {{ ref('int_orders_enriched') }}
),

final as (
    select
        -- Surrogate key (composite: order_id + order_item_id)
        {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }} as order_item_key,
        
        -- Natural keys
        oi.order_id,
        oi.order_item_id,
        
        -- Foreign keys to dimensions
        {{ dbt_utils.generate_surrogate_key(['oi.order_id']) }} as order_key,
        {{ dbt_utils.generate_surrogate_key(['o.customer_id']) }} as customer_key,
        {{ dbt_utils.generate_surrogate_key(['oi.product_id']) }} as product_key,
        {{ dbt_utils.generate_surrogate_key(['oi.seller_id']) }} as seller_key,
        
        -- Date key
        to_number(to_char(o.order_purchase_timestamp, 'YYYYMMDD')) as order_date_key,
        
        -- Natural foreign keys
        o.customer_id,
        oi.product_id,
        oi.seller_id,
        
        -- Product information
        oi.product_category_pt,
        oi.product_category_en,
        oi.product_weight_g,
        oi.product_volume_cm3,
        
        -- Seller information
        oi.seller_city,
        oi.seller_state,
        oi.seller_zip_code,
        
        -- Pricing metrics
        oi.item_price,
        oi.item_freight_value,
        oi.item_total_value,
        oi.freight_percentage,
        
        -- Shipping
        oi.shipping_limit_date,
        o.order_purchase_timestamp,
        
        -- Categories
        oi.weight_category,
        oi.volume_category,
        oi.price_category,
        
        -- Order context
        o.order_status,
        o.is_delivered,
        o.is_canceled,
        
        -- Calculated metrics
        case 
            when oi.freight_percentage > 50 then 'High Freight'
            when oi.freight_percentage > 20 then 'Medium Freight'
            else 'Low Freight'
        end as freight_cost_category,
        
        -- Product size classification
        case 
            when oi.weight_category = 'heavy' and oi.volume_category = 'large' then 'Bulky'
            when oi.weight_category = 'light' and oi.volume_category = 'small' then 'Compact'
            else 'Standard'
        end as product_size_profile,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from order_items_enriched oi
    inner join orders o on oi.order_id = o.order_id
)

select * from final