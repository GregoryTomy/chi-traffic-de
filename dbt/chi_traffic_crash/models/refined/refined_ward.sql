{{ config(materialized="incremental", unique_key="ward_hkey") }}

with ward_data as (select * from {{ ref("staging_ward") }})

select
    {{
        dbt_utils.default__generate_surrogate_key(
            ["ward_id", "st_astext(ward_geometry)", "st_length", "st_area"]
        )
    }} as ward_hkey,
    ward_id as ward_id,
    ward_geometry as ward_geometry,
    st_length as st_length,
    st_area as st_area,
    partition_date as partition_date
from ward_data
