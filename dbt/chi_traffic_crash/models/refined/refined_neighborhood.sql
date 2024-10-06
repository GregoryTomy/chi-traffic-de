{{
    config(
        materialized="incremental",
        partition_by={"field": "partition_date", "data_type": "date"},
    )
}}

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
    date("{{run_started_at.strftime('%Y-%m-%d')}}") as partition_date,
from neighborhood_data
