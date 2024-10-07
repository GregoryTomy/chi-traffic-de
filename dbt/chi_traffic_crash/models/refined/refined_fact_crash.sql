{{ config(materialized="incremental", unique_key="crash_hkey") }}

with
    crash_data as (
        select
            crash_id,
            first_crash_type_code,
            crash_severity_code,
            total_injuries_number,
            total_fatal_injuries_number,
            weather_condition_code,
            lighting_condition_code,
            crash_datetime,
            location_latitude,
            location_longitude
            is_intersection_related,
        from {{ ref("staging_crash") }}
    )

select
    {{ dbt_utils.generate_surrogate_key(["crash_id", "date_hkey", "location_hkey"]) }}
    as crash_hkey,
    crash.crash_id,
    crash.first_crash_type_code,
    crash.crash_severity_code,
    crash.total_injuries_number,
    crash.total_fatal_injuries_number,
    crash.weather_condition_code,
    crash.lighting_condition_code,
    is_intersection_related,
    date.date_hkey as date_hkey,
    loc.location_hkey as location_hkey
from crash_data as crash
left join
    {{ ref("refined_dim_datetime") }} as date
    on crash.crash_datetime = date.crash_datetime
    {# left join
    {{ ref("refined_dim_location") }} as loc
    on crash.location_latitude = loc.latitude
    and crash.location_longitude = loc.longitude #}
    
