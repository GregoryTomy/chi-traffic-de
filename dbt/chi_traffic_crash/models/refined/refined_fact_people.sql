{{ config(materialized="incremental", unique_key="person_hkey") }}

with people_data as (select * from {{ ref("staging_people") }})

select
    {{
        dbt_utils.default__generate_surrogate_key(
            ["person_id", "crash_id", "vehicle_id"]
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
    end as is_physically_impaired,
    partition_date,
from people_data
