with source as (
    select * from {{ source('raw', 'RAW_PAYMENTS') }}
),

renamed as (
    select
        -- Composite key
        order_id,
        payment_sequential::int as payment_sequential,
        
        -- Payment attributes
        payment_type,
        payment_installments::int as payment_installments,
        payment_value::decimal(10,2) as payment_value
        
    from source
)

select * from renamed