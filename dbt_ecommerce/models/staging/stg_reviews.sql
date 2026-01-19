with source as (
    select * from {{ source('raw', 'RAW_REVIEWS') }}
),

renamed as (
    select
        -- Primary key
        review_id,
        
        -- Foreign key
        order_id,
        
        -- Review content
        review_score::int as review_score,
        review_comment_title,
        review_comment_message,
        
        -- Timestamps
        try_to_timestamp(review_creation_date) as review_creation_date,
        try_to_timestamp(review_answer_timestamp) as review_answer_timestamp
        
    from source
),

-- Remove duplicates - keep the most recent review per review_id
deduplicated as (
    select *
    from renamed
    qualify row_number() over (
        partition by review_id 
        order by review_creation_date desc
    ) = 1
)

select * from deduplicated