{{
    config(
        materialized="view",
    )
}}

with
    latest_partition as (
        select max(partition_date) as latest_date from {{ source("staging", "people") }}
    ),
    source as (
        select *
        from {{ source("staging", "people") }}
        where partition_date = (select latest_date from latest_partition)
    ),
    renamed as (
        select
            {{ adapter.quote("person_id") }} as person_id,
            {{ adapter.quote("person_type") }} as person_type_code,
            {{ adapter.quote("crash_record_id") }} as crash_id,
            {{ adapter.quote("vehicle_id") }} as vehicle_id,
            {{ adapter.quote("sex") }} as person_sex_code,
            {{ adapter.quote("age") }} as person_age_number,
            {{ adapter.quote("driver_vision") }} as driver_vision,
            {{ adapter.quote("drivers_license_state") }} as drivers_license_state,
            {{ adapter.quote("physical_condition") }} as driver_physical_condition,
            {{ adapter.quote("bac_result") }} bac_result,
            {{ adapter.quote("bac_result_value") }} as bac_result_number,
            {{ adapter.quote("cell_phone_use") }} as is_phone_use,
            {{ adapter.quote("partition_date") }} as partition_date,
        from source
    ),

    typed as (
        select
            cast({{ string_empty_to_null("person_id") }} as string) as person_id,
            cast(
                {{ string_empty_to_null("person_type_code") }} as string
            ) as person_type_code,
            cast({{ string_empty_to_null("crash_id") }} as string) as crash_id,
            cast(vehicle_id as int64) as vehicle_id,
            cast(
                upper({{ string_empty_to_null("person_sex_code") }}) as string
            ) as person_sex_code,
            cast(person_age_number as int64) as person_age_number,
            cast(
                {{ string_empty_to_null("driver_vision") }} as string
            ) as driver_vision,
            cast(
                upper({{ string_empty_to_null("drivers_license_state") }}) as string
            ) as drivers_license_state,
            cast(
                {{ string_empty_to_null("driver_physical_condition") }} as string
            ) as driver_physical_condition,
            cast({{ string_empty_to_null("bac_result") }} as string) as bac_result,
            cast(bac_result_number as float64) as bac_result_number,
            cast({{ convert_to_boolean("is_phone_use") }} as boolean) as is_phone_use,
            cast(partition_date as date) as partition_date,
        from renamed
    )

select *
from typed
