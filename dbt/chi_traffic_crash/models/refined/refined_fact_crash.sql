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
            location_longitude,
            is_intersection_related,
            is_hit_and_run,
            is_work_zone,
            is_workers_present,
            is_dooring_related,
            crash_speed_limit,
            roadway_surface_condition_code,
            road_defect_code,
            damage_level_code,
            primary_cause_explanation,
            partition_date
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
    crash.is_intersection_related,
    crash.is_hit_and_run,
    crash.is_work_zone,
    crash.is_workers_present,
    crash.is_dooring_related,
    crash.crash_speed_limit,
    crash.roadway_surface_condition_code,
    case
        when crash.road_defect_code is null
        then null
        when lower(crash.road_defect_code) = 'unknown'
        then null
        when lower(crash.road_defect_code) = 'no defects'
        then false
        else true
    end as is_road_defect,
    crash.damage_level_code,
    crash.primary_cause_explanation,
    date.date_hkey as date_hkey,
    loc.location_hkey as location_hkey,
    crash.partition_date
from crash_data as crash
left join
    {{ ref("refined_dim_datetime") }} as date
    on crash.crash_datetime = date.crash_datetime
left join
    {{ ref("refined_dim_location_enriched") }} as loc
    on crash.location_longitude = loc.longitude
    and crash.location_latitude = loc.latitude
