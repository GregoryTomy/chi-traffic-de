{{
    config(
        materialized="view",
    )
}}

with
    latest_partition_date as (
        select max(partition_date) as latest_date from {{ ref("refined_dim_location") }}
    )

select *
from {{ ref("refined_dim_location") }}
where partition_date = (select latest_date from latest_partition_date)
