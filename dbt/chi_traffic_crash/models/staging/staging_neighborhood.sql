{{
    config(
        materialized="view",
    )
}}

with
    latest_partition as (
        select max(partition_date) as latest_date
        from {{ source("staging", "neighborhood") }}
    ),

    source as (
        select *
        from {{ source("staging", "neighborhood") }}
        where partition_date = (select latest_date from latest_partition)
    ),

    renamed as (
        select
            {{ adapter.quote("pri_neigh") }} as primary_neighborhood,
            {{ adapter.quote("sec_neigh") }} as secondary_neighborhood,
            {{ adapter.quote("geometry") }} as neighborhood_geometry,
            {{ adapter.quote("shape_len") }} as shape_length,
            {{ adapter.quote("shape_area") }} as shape_area,
            {{ adapter.quote("partition_date") }} as partition_date,
        from source
    ),

    typed as (
        select
            cast(upper(primary_neighborhood) as string) as primary_neighborhood,
            cast(secondary_neighborhood as string) as secondary_neighborhood,
            st_geogfromgeojson(neighborhood_geometry) as neighborhood_geometry,
            cast(shape_length as float64) as shape_length,
            cast(shape_area as float64) as shape_area,
            cast(partition_date as date) as partition_date
        from renamed
    )

select *
from typed
