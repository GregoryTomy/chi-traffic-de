{{
    config(
        materialized="incremental",
        unique_key="crash_datetime",
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
    extract(day from crash_datetime) as day,
    extract(quarter from crash_datetime) as quarter,
    extract(week from crash_datetime) as week,
    extract(dayofweek from crash_datetime) as day_of_week,

    case
        when extract(dayofweek from crash_datetime) in (1, 7) then true else false
    end as is_weekend,

    case
        when extract(month from crash_datetime) in (12, 1, 2) then true else false
    end as is_winter,

from unique_dates
order by crash_datetime
