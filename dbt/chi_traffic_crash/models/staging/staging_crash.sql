{{
    config(
        materialized="view",
    )
}}

with
    latest_partition as (
        select max(partition_date) as latest_date from {{ source("staging", "crash") }}
    ),

    source as (
        select *
        from {{ source("staging", "crash") }}
        where partition_date = (select latest_date from latest_partition)
    ),

    renamed as (
        select
            {{ adapter.quote("crash_record_id") }} as crash_id,
            {{ adapter.quote("crash_date") }} as crash_datetime,
            {{ adapter.quote("posted_speed_limit") }} as speed_limit,
            {{ adapter.quote("traffic_control_device") }} as traffic_control_device,
            {{ adapter.quote("weather_condition") }} as weather_condition_code,
            {{ adapter.quote("lighting_condition") }} as lighting_condition_code,
            {{ adapter.quote("first_crash_type") }} as first_crash_type_code,
            {{ adapter.quote("trafficway_type") }} as trafficway_type_code,
            {{ adapter.quote("roadway_surface_cond") }}
            as roadway_surface_condition_code,
            {{ adapter.quote("road_defect") }} as road_defect_code,
            {{ adapter.quote("crash_type") }} as crash_severity_code,
            {{ adapter.quote("intersection_related_i") }} as is_intersection_related,
            {{ adapter.quote("hit_and_run_i") }} as is_hit_and_run,
            {{ adapter.quote("damage") }} as damage_level_code,
            {{ adapter.quote("prim_contributory_cause") }} as primary_cause_explanation,
            {{ adapter.quote("street_no") }} as street_number,
            {{ adapter.quote("street_direction") }} as street_direction_code,
            {{ adapter.quote("street_name") }} as street_name,
            {{ adapter.quote("dooring_i") }} as is_dooring_related,
            {{ adapter.quote("work_zone_i") }} as is_work_zone,
            {{ adapter.quote("workers_present_i") }} as is_workers_present,
            {{ adapter.quote("injuries_total") }} as total_injuries_number,
            {{ adapter.quote("injuries_fatal") }} as total_fatal_injuries_number,
            {{ adapter.quote("latitude") }} as location_latitude,
            {{ adapter.quote("longitude") }} as location_longitude,
            {{ adapter.quote("partition_date") }} as partition_date,
        from source
    ),

    typed as (
        select
            cast(crash_id as string) as crash_id,
            -- Timestamp from source comes in as picoseconds and BQ only recognizes
            -- miliseconds
            timestamp_millis(div(crash_datetime, 1000000)) as crash_datetime,
            cast(speed_limit as int64) as crash_speed_limit,
            cast(traffic_control_device as string) as traffic_control_device,
            cast(weather_condition_code as string) as weather_condition_code,
            cast(lighting_condition_code as string) as lighting_condition_code,
            cast(first_crash_type_code as string) as first_crash_type_code,
            cast(trafficway_type_code as string) as trafficway_type_code,
            cast(
                roadway_surface_condition_code as string
            ) as roadway_surface_condition_code,
            cast(road_defect_code as string) as road_defect_code,
            cast(crash_severity_code as string) as crash_severity_code,
            cast(
                {{ convert_to_boolean("is_intersection_related") }} as boolean
            ) as is_intersection_related,
            cast(
                {{ convert_to_boolean("is_hit_and_run") }} as boolean
            ) as is_hit_and_run,
            cast(damage_level_code as string) as damage_level_code,
            cast(primary_cause_explanation as string) as primary_cause_explanation,
            cast(street_number as int64) as street_number,
            cast(street_direction_code as string) as street_direction_code,
            cast(street_name as string) as street_name,
            cast(
                {{ convert_to_boolean("is_dooring_related") }} as boolean
            ) as is_dooring_related,
            cast({{ convert_to_boolean("is_work_zone") }} as boolean) as is_work_zone,
            cast(
                {{ convert_to_boolean("is_workers_present") }} as boolean
            ) as is_workers_present,
            cast(total_injuries_number as int64) as total_injuries_number,
            cast(total_fatal_injuries_number as int64) as total_fatal_injuries_number,
            cast(location_latitude as float64) as location_latitude,
            cast(location_longitude as float64) as location_longitude,
            cast(partition_date as date) as partition_date,
        from renamed
    ),

    final as (select * from typed)

select *
from final
