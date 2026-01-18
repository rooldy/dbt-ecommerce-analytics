with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
),

renamed as (
    select
        ORDER_ID as order_id,
        CUSTOMER_ID as customer_id,
        ORDER_STATUS as order_status,
        ORDER_PURCHASE_TIMESTAMP::timestamp as order_date,
        ORDER_APPROVED_AT::timestamp as approved_date,
        ORDER_DELIVERED_CARRIER_DATE::timestamp as carrier_date,
        ORDER_DELIVERED_CUSTOMER_DATE::timestamp as delivered_date,
        ORDER_ESTIMATED_DELIVERY_DATE::timestamp as estimated_delivery_date
    from source
)

select * from renamed
