{{
    config(
        materialized="view",
    )
}}

with
    latest_partition as (
        select max(partition_date) as latest_date from {{ source("staging", "ward") }}
    ),

    source as (
        select *
        from {{ source("staging", "ward") }}
        where partition_date = (select latest_date from latest_partition)
    ),

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
            partition_date as partition_date,
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
            cast(st_area as float64) as st_area,
            cast(partition_date as date) as partition_date,
        from renamed
    )

select *
from typed
