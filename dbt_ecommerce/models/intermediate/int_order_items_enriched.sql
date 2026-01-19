{{
    config(
        materialized='view',
        tags=['intermediate', 'order_items']
    )
}}

with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

product_translation as (
    select * from {{ ref('stg_product_translation') }}
),

-- Enrich order items with product and seller information
enriched as (
    select
        -- Order item identifiers
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        
        -- Product information
        p.category_name as product_category_pt,
        pt.category_name_en as product_category_en,
        p.name_length as product_name_length,
        p.description_length as product_description_length,
        p.photos_qty as product_photos_qty,
        
        -- Product dimensions
        p.weight_g as product_weight_g,
        p.length_cm as product_length_cm,
        p.height_cm as product_height_cm,
        p.width_cm as product_width_cm,
        
        -- Calculate volume in cubic cm
        (p.length_cm * p.height_cm * p.width_cm) as product_volume_cm3,
        
        -- Seller information
        s.city as seller_city,
        s.state as seller_state,
        s.zip_code as seller_zip_code,
        
        -- Pricing information
        oi.price as item_price,
        oi.freight_value as item_freight_value,
        (oi.price + oi.freight_value) as item_total_value,
        
        -- Calculate freight as percentage of price
        case 
            when oi.price > 0 then (oi.freight_value / oi.price) * 100
            else 0
        end as freight_percentage,
        
        -- Shipping information
        oi.shipping_limit_date,
        
        -- Product categorization flags
        case 
            when p.weight_g > 10000 then 'heavy'
            when p.weight_g > 3000 then 'medium'
            else 'light'
        end as weight_category,
        
        case 
            when product_volume_cm3 > 100000 then 'large'
            when product_volume_cm3 > 10000 then 'medium'
            else 'small'
        end as volume_category,
        
        -- Price categorization
        case 
            when oi.price > 500 then 'premium'
            when oi.price > 100 then 'mid-range'
            else 'budget'
        end as price_category
        
    from order_items oi
    left join products p on oi.product_id = p.product_id
    left join sellers s on oi.seller_id = s.seller_id
    left join product_translation pt on p.category_name = pt.category_name_pt
)

select * from enriched