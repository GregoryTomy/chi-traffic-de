{{ config(materialized="incremental", unique_key="vehicle_hkey") }}

with vehicle_data as (select * from {{ ref("staging_vehicle") }})

select
    {{
        dbt_utils.generate_surrogate_key(
            ["crash_vehicle_id", "crash_id", "vehicle_id"]
        )
    }} as vehicle_hkey,
    crash_vehicle_id,
    crash_id,
    vehicle_id,
    unit_type,
    passengers_number,
    case
        when lower(vehicle_make) = 'unknown' then null else vehicle_make
    end as vehicle_make,
    case
        when lower(vehicle_model) = 'unknown'
        then null
        when vehicle_model is null
        then null
        else vehicle_model
    end as vehicle_model,
    license_plate_state,
    vehicle_year_number,
    case
        when vehicle_defect is null
        then null
        when lower(vehicle_defect) = 'unknown'
        then null
        when lower(vehicle_defect) = 'none'
        then true
        else false
    end as is_vehicle_defect,
    vehicle_type,
    case
        when lower(vehicle_use_code) = 'unknown/na'
        then null
        when vehicle_use_code is null
        then null
        else vehicle_use_code
    end as vehicle_use_code,
    case
        when lower(vehicle_maneuver) = 'unknown/na'
        then null
        when vehicle_maneuver is null
        then null
        else vehicle_maneuver
    end as vehicle_maneuver,
    is_speeding,
    partition_date
from vehicle_data
