{{
    config(
        materialized="view",
    )
}}

select *
from {{ ref("refined_fact_vehicle") }}
