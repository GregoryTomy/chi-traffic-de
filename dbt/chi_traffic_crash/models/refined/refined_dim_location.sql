{{ config(materialized="incremental", unique_key="location_hkey") }}

with
    location_data as (
        select distinct location_latitude as latitude, location_longitude as longitude,
        from {{ ref("staging_crash") }}
    )

select
    {{
        dbt_utils.generate_surrogate_key(
            [
                "latitude",
                "longitude",
            ]
        )
    }} as location_hkey,
    st_geogpoint(longitude, latitude) as location_point,
    latitude,
    longitude,
from location_data
