{{
    config(
        materialized="view",
    )
}}

{% set column_types = {
    "crash_id": "string",
    "crash_datetime": "timestamp",
    "crash_speed_limit": "int64",
    "traffic_control_device": "string",
    "weather_condition_code": "string",
    "lighting_condition_code": "string",
    "first_crash_type_code": "string",
    "trafficway_type_code": "string",
    "roadway_surface_condition_code": "string",
    "road_defect_code": "string",
    "crash_severity_code": "string",
    "is_intersection_related": "boolean",
    "is_hit_and_run": "boolean",
    "damage_level_code": "string",
    "primary_cause_explanation": "string",
    "street_number": "int64",
    "street_direction_code": "string",
    "street_name": "string",
    "is_dooring_related": "boolean",
    "is_work_zone": "boolean",
    "is_workers_present": "boolean",
    "total_injuries_number": "int64",
    "total_fatal_injuries_number": "int64",
    "location_latitude": "float64",
    "location_longitude": "float64",
} %}

with
    source as (select * from {{ source("staging", "crash_20240925") }}),

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
            {{ adapter.quote("roadway_surface_cond") }} as roadway_surface_condition_code,
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
            {{ adapter.quote("longitude") }} as location_longitude
        from source
    ),

    typed as (
        select
            CAST(crash_id AS STRING) as crash_id,
            -- Timestamp from source comes in as picoseconds and BQ only recognizes miliseconds
            TIMESTAMP_MILLIS(div(crash_datetime, 1000000)) as crash_datetime,
            CAST(speed_limit AS INT64) as crash_speed_limit,
            CAST(traffic_control_device AS STRING) as traffic_control_device,
            CAST(weather_condition_code AS STRING) as weather_condition_code,
            CAST(lighting_condition_code AS STRING) as lighting_condition_code,
            CAST(first_crash_type_code AS STRING) as first_crash_type_code,
            CAST(trafficway_type_code AS STRING) as trafficway_type_code,
            CAST(roadway_surface_condition_code AS STRING) as roadway_surface_condition_code,
            CAST(road_defect_code AS STRING) as road_defect_code,
            CAST(crash_severity_code AS STRING) as crash_severity_code,
            CAST({{ convert_to_boolean("is_intersection_related") }} AS BOOLEAN) as is_intersection_related,
            CAST({{ convert_to_boolean("is_hit_and_run") }} AS BOOLEAN) as is_hit_and_run,
            CAST(damage_level_code AS STRING) as damage_level_code,
            CAST(primary_cause_explanation AS STRING) as primary_cause_explanation,
            CAST(street_number AS INT64) as street_number,
            CAST(street_direction_code AS STRING) as street_direction_code,
            CAST(street_name AS STRING) as street_name,
            CAST({{ convert_to_boolean("is_dooring_related") }} AS BOOLEAN) as is_dooring_related,
            CAST({{ convert_to_boolean("is_work_zone") }} AS BOOLEAN) as is_work_zone,
            CAST({{ convert_to_boolean("is_workers_present") }} AS BOOLEAN) as is_workers_present,
            CAST(total_injuries_number AS INT64) as total_injuries_number,
            CAST(total_fatal_injuries_number AS INT64) as total_fatal_injuries_number,
            CAST(location_latitude AS FLOAT64) as location_latitude,
            CAST(location_longitude AS FLOAT64) as location_longitude
        from renamed
    ),

    final as (
        select *
        from typed
    )

select *
from final
