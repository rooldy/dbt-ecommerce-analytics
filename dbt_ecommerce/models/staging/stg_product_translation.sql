with source as (
    select * from {{ source('raw', 'RAW_PRODUCT_TRANSLATION') }}
),

renamed as (
    select
        -- Product category in Portuguese
        product_category_name as category_name_pt,
        
        -- Product category in English
        product_category_name_english as category_name_en
        
    from source
)

select * from renamed