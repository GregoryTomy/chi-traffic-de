{{ config(materialized="incremental", unique_key="person_hkey") }}

with
    people_data as (select * from {{ ref("staging_people") }}),
    crash_data as (select crash_id, crash_hkey, from {{ ref("refined_fact_crash") }}),
    vehicle_data as (
        select vehicle_id, vehicle_hkey from {{ ref("refined_fact_vehicle") }}
    ),

    people_with_crash_hkey as (
        select
            people.*,
            crash.crash_hkey as crash_hkey,
            vehicle.vehicle_hkey as vehicle_hkey
        from people_data as people
        left join crash_data as crash on people.crash_id = crash.crash_id
        left join vehicle_data as vehicle on people.vehicle_id = vehicle.vehicle_id
    )

select
    {{
        dbt_utils.default__generate_surrogate_key(
            ["person_id", "crash_hkey", "vehicle_hkey"]
        )
    }} as person_hkey,
    * except (driver_vision, driver_physical_condition),
    case
        when driver_vision is null
        then null
        when lower(driver_vision) = 'unknown'
        then null
        when lower(driver_vision) = 'not obscured'
        then false
        else true
    end as is_vision_obscured,
    case
        when driver_physical_condition is null
        then null
        when lower(driver_physical_condition) = 'unknown'
        then null
        when lower(driver_physical_condition) = 'normal'
        then false
        else true
    end as is_physically_impaired
from people_with_crash_hkey
