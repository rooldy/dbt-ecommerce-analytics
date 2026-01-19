{{
    config(
        materialized='table',
        tags=['marts', 'core', 'dimensions']
    )
}}

with sellers as (
    select * from {{ ref('stg_sellers') }}
),

final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
        
        -- Natural key
        seller_id,
        
        -- Location attributes
        city as seller_city,
        state as seller_state,
        zip_code as seller_zip_code,
        
        -- Regional classification
        case 
            when state in ('SP', 'RJ', 'MG', 'ES') then 'Southeast'
            when state in ('PR', 'SC', 'RS') then 'South'
            when state in ('GO', 'MT', 'MS', 'DF') then 'Central-West'
            when state in ('BA', 'SE', 'AL', 'PE', 'PB', 'RN', 'CE', 'PI', 'MA') then 'Northeast'
            when state in ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') then 'North'
            else 'Unknown'
        end as region,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from sellers
)

select * from final