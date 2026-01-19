with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
),

renamed as (
    select
        -- Primary key
        order_id,
        
        -- Foreign key
        customer_id,
        
        -- Order attributes
        order_status,
        
        -- Timestamps - convert VARCHAR to TIMESTAMP
        try_to_timestamp(order_purchase_timestamp) as order_purchase_timestamp,
        try_to_timestamp(order_approved_at) as order_approved_at,
        try_to_timestamp(order_delivered_carrier_date) as order_delivered_carrier_date,
        try_to_timestamp(order_delivered_customer_date) as order_delivered_customer_date,
        try_to_timestamp(order_estimated_delivery_date) as order_estimated_delivery_date
        
    from source
)

select * from renamed