with source as (
    select * from {{ source('raw', 'RAW_PRODUCTS') }}
),

renamed as (
    select
        -- Primary key
        product_id,
        
        -- Product attributes
        product_category_name as category_name,
        
        -- Text attributes (FLOAT → INT via ROUND)
        round(product_name_lenght)::int as name_length,
        round(product_description_lenght)::int as description_length,
        round(product_photos_qty)::int as photos_qty,
        
        -- Dimensions (already FLOAT, cast to DECIMAL for consistency)
        product_weight_g::decimal(10,2) as weight_g,
        product_length_cm::decimal(10,2) as length_cm,
        product_height_cm::decimal(10,2) as height_cm,
        product_width_cm::decimal(10,2) as width_cm
        
    from source
)

select * from renamed