{{
    config(
        materialized="incremental",
        unique_key="date_hkey",
    )
}}

with
    unique_dates as (
        select distinct crash_datetime as crash_datetime from {{ ref("staging_crash") }}
    )

select
    {{ dbt_utils.generate_surrogate_key(["crash_datetime"]) }} as date_hkey,
    crash_datetime as crash_datetime,
    extract(year from crash_datetime) as year,
    extract(month from crash_datetime) as month,
    extract(quarter from crash_datetime) as quarter,
    extract(week from crash_datetime) as week,
    extract(day from crash_datetime) as day,
    extract(dayofweek from crash_datetime) as day_of_week,
    extract(hour from crash_datetime) as hour,

    case
        when extract(dayofweek from crash_datetime) in (1, 7) then true else false
    end as is_weekend,

    case
        when extract(month from crash_datetime) in (12, 1, 2) then true else false
    end as is_winter,

    case
        when extract(hour from crash_datetime) in (7, 8, 9, 16, 17, 18)
        then true
        else false
    end as is_rush_hour,

from unique_dates
order by crash_datetime
