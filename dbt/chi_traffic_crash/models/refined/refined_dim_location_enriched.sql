{{
    config(
        materialized="view",
    )
}}

with
    latest_partition_date as (
        select max(partition_date) as latest_date from {{ ref("refined_dim_location") }}
    ),

    latest_ward_date as (
        select max(partition_date) as latest_date from {{ ref("refined_ward") }}
    ),

    latest_neighborhood_date as (
        select max(partition_date) as latest_date from {{ ref("refined_neighborhood") }}
    ),

    latest_location as (
        select *
        from {{ ref("refined_dim_location") }}
        where partition_date = (select latest_date from latest_partition_date)
    ),

    latest_ward as (
        select *
        from {{ ref("refined_ward") }}
        where partition_date = (select latest_date from latest_ward_date)
    ),

    latest_neighborhood as (
        select *
        from {{ ref("refined_neighborhood") }}
        where partition_date = (select latest_date from latest_neighborhood_date)
    )

select
    location.location_hkey,
    location.location_point,
    location.street_number,
    location.street_direction_code,
    location.street_name,
    location.is_intersection_related,
    ward.ward_hkey,
    ward.ward_id,
    neigh.neighborhood_hkey,
    neigh.neighborhood,
    location.partition_date,
from latest_location as location
left join latest_ward as ward on st_within(location.location_point, ward.ward_geometry)
left join
    latest_neighborhood as neigh
    on st_within(location.location_point, neigh.neighborhood_geometry)
