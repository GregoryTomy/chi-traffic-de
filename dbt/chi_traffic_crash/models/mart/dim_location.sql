{{
    config(
        materialized="view",
    )
}}

select *
from {{ ref("refined_dim_location_enriched") }}
