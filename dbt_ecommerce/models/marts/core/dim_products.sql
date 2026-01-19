{{
    config(
        materialized='table',
        tags=['marts', 'core', 'dimensions']
    )
}}

with products as (
    select * from {{ ref('stg_products') }}
),

product_translation as (
    select * from {{ ref('stg_product_translation') }}
),

final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
        
        -- Natural key
        p.product_id,
        
        -- Product attributes
        p.category_name as category_name_pt,
        pt.category_name_en,
        
        -- Description metrics
        p.name_length,
        p.description_length,
        p.photos_qty,
        
        -- Physical dimensions
        p.weight_g,
        p.length_cm,
        p.height_cm,
        p.width_cm,
        (p.length_cm * p.height_cm * p.width_cm) as volume_cm3,
        
        -- Categories
        case 
            when p.weight_g > 10000 then 'Heavy'
            when p.weight_g > 3000 then 'Medium'
            else 'Light'
        end as weight_category,
        
        case 
            when (p.length_cm * p.height_cm * p.width_cm) > 100000 then 'Large'
            when (p.length_cm * p.height_cm * p.width_cm) > 10000 then 'Medium'
            else 'Small'
        end as volume_category,
        
        -- Quality indicators
        case 
            when p.photos_qty >= 5 then 'High Quality Listing'
            when p.photos_qty >= 2 then 'Standard Listing'
            else 'Basic Listing'
        end as listing_quality,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from products p
    left join product_translation pt on p.category_name = pt.category_name_pt
)

select * from final