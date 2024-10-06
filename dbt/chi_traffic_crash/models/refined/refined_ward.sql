{{
    config(
        materialized="incremental",
        partition_by={"field": "partition_date", "data_type": "date"},
    )
}}

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
    date("{{run_started_at.strftime('%Y-%m-%d')}}") as partition_date,
from ward_data
