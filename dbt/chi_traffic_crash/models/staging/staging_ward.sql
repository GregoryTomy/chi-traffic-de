{{
    config(
        materialized="view",
    )
}}

with
    source as (select * from {{ source("staging", "ward_20241005") }}),

    renamed as (
        select
            globalid as global_id,
            ward as ward,
            ward_id as ward_id,
            geometry as ward_geometry,
            objectid as object_id,
            edit_date as edit_date,
            st_length_ as st_length,
            st_area_sh as st_area,
        from source
    ),

    typed as (
        select
            cast(global_id as string) as global_id,
            cast(ward as int64) as ward,
            cast(ward_id as int64) as ward_id,
            st_geogfromgeojson(ward_geometry) as ward_geometry,
            cast(object_id as string) as object_id,
            cast(edit_date as timestamp) as edit_date,
            cast(st_length as float64) as st_length,
            cast(st_area as float64) as st_area
        from renamed
    )

select *
from typed
