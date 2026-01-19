with source as (
    select * from {{ source('raw', 'RAW_GEOLOCATION') }}
),

renamed as (
    select
        -- Location identifiers
        geolocation_zip_code_prefix as zip_code,
        geolocation_city as city,
        geolocation_state as state,
        
        -- Coordinates
        geolocation_lat::decimal(10,6) as latitude,
        geolocation_lng::decimal(10,6) as longitude
        
    from source
),

-- Remove duplicates - keep first occurrence for each zip_code
deduplicated as (
    select *
    from renamed
    qualify row_number() over (partition by zip_code order by city) = 1
)

select * from deduplicated