{{ config(materialized="view", unique_key="location_hkey") }}

with
    location_data as (select * from {{ ref("refined_dim_location") }}),
    ward_data as (select * from {{ ref("refined_ward") }}),
    neighborhood_data as (select * from {{ ref("refined_neighborhood") }})
select
    location.location_hkey,
    location.location_point,
    location.longitude,
    location.latitude,
    ward.ward_hkey,
    ward.ward_id,
    neigh.neighborhood_hkey,
    neigh.neighborhood,
from location_data as location
left join ward_data as ward on st_within(location.location_point, ward.ward_geometry)
left join
    neighborhood_data as neigh
    on st_within(location.location_point, neigh.neighborhood_geometry)
