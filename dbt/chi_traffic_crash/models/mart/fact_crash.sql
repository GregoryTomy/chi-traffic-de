{{
    config(
        materialized="table",
    )
}}

select *
from {{ ref("refined_fact_crash") }}
