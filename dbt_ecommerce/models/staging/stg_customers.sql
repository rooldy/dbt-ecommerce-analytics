with source as (
    select * from {{ source('raw', 'RAW_CUSTOMERS') }}
),

renamed as (
    select
        -- Primary key
        customer_id,
        customer_unique_id,
        
        -- Location attributes
        customer_zip_code_prefix as zip_code,
        customer_city as city,
        customer_state as state
        
    from source
)

select * from renamed