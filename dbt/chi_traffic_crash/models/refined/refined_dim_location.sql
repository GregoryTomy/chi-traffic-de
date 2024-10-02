{{
    config(
        materialized="incremental",
        partition_by={"field": "partition_date", "data_type": "date"},
    )
}}

with
    location_data as (
        select distinct
            location_latitude as latitude,
            location_longitude as longitude,
            street_number,
            street_direction_code,
            street_name,
            is_intersection_related
        from {{ ref("staging_crash") }}
    )

select
    {{
        dbt_utils.generate_surrogate_key(
            [
                "latitude",
                "longitude",
                "street_number",
                "street_direction_code",
                "street_name",
            ]
        )
    }} as location_hkey,
    st_geogpoint(longitude, latitude) as location_point,
    latitude,
    longitude,
    street_number,
    street_direction_code,
    street_name,
    is_intersection_related,
    current_date() as partition_date
from location_data
