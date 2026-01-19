{{
    config(
        materialized='table',
        tags=['marts', 'core', 'dimensions']
    )
}}

with date_spine as (
    -- Generate dates from 2016-09-01 to 2018-12-31 (covering the dataset period)
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-09-01' as date)",
        end_date="cast('2018-12-31' as date)"
    ) }}
),

final as (
    select
        -- Surrogate key (YYYYMMDD format)
        to_number(to_char(date_day, 'YYYYMMDD')) as date_key,
        
        -- Full date
        date_day as full_date,
        
        -- Year attributes
        extract(year from date_day) as year,
        case 
            when extract(year from date_day) = 2016 then 'Y2016'
            when extract(year from date_day) = 2017 then 'Y2017'
            when extract(year from date_day) = 2018 then 'Y2018'
        end as year_name,
        
        -- Quarter attributes
        extract(quarter from date_day) as quarter,
        'Q' || extract(quarter from date_day) as quarter_name,
        extract(year from date_day) || '-Q' || extract(quarter from date_day) as year_quarter,
        
        -- Month attributes
        extract(month from date_day) as month,
        to_char(date_day, 'Month') as month_name,
        to_char(date_day, 'Mon') as month_name_short,
        extract(year from date_day) || '-' || lpad(extract(month from date_day)::varchar, 2, '0') as year_month,
        
        -- Week attributes
        extract(week from date_day) as week_of_year,
        extract(dayofweek from date_day) as day_of_week,
        to_char(date_day, 'Day') as day_name,
        to_char(date_day, 'Dy') as day_name_short,
        
        -- Day attributes
        extract(day from date_day) as day_of_month,
        extract(dayofyear from date_day) as day_of_year,
        
        -- Flags
        case when extract(dayofweek from date_day) in (0, 6) then 1 else 0 end as is_weekend,
        case when extract(dayofweek from date_day) between 1 and 5 then 1 else 0 end as is_weekday,
        
        -- Brazilian holidays (simplified - major holidays only)
        case 
            when extract(month from date_day) = 1 and extract(day from date_day) = 1 then 'New Year'
            when extract(month from date_day) = 4 and extract(day from date_day) = 21 then 'Tiradentes Day'
            when extract(month from date_day) = 5 and extract(day from date_day) = 1 then 'Labor Day'
            when extract(month from date_day) = 9 and extract(day from date_day) = 7 then 'Independence Day'
            when extract(month from date_day) = 10 and extract(day from date_day) = 12 then 'Our Lady of Aparecida'
            when extract(month from date_day) = 11 and extract(day from date_day) = 2 then 'All Souls Day'
            when extract(month from date_day) = 11 and extract(day from date_day) = 15 then 'Proclamation of the Republic'
            when extract(month from date_day) = 12 and extract(day from date_day) = 25 then 'Christmas'
            else null
        end as holiday_name,
        
        case 
            when extract(month from date_day) = 1 and extract(day from date_day) = 1 then 1
            when extract(month from date_day) = 4 and extract(day from date_day) = 21 then 1
            when extract(month from date_day) = 5 and extract(day from date_day) = 1 then 1
            when extract(month from date_day) = 9 and extract(day from date_day) = 7 then 1
            when extract(month from date_day) = 10 and extract(day from date_day) = 12 then 1
            when extract(month from date_day) = 11 and extract(day from date_day) = 2 then 1
            when extract(month from date_day) = 11 and extract(day from date_day) = 15 then 1
            when extract(month from date_day) = 12 and extract(day from date_day) = 25 then 1
            else 0
        end as is_holiday,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from date_spine
)

select * from final