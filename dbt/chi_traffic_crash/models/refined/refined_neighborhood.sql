{{ config(materialized="incremental", unique_key="neighborhood_hkey") }}

with neighborhood_data as (select * from {{ ref("staging_neighborhood") }})

select
    {{
        dbt_utils.default__generate_surrogate_key(
            [
                "primary_neighborhood",
                "st_astext(neighborhood_geometry)",
                "shape_length",
                "shape_area",
            ]
        )
    }} as neighborhood_hkey,
    primary_neighborhood as neighborhood,
    neighborhood_geometry as neighborhood_geometry,
    shape_length as shape_length,
    shape_area as shape_area,
    partition_date as partition_date
from neighborhood_data
