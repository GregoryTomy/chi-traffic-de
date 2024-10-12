with
    latest_partition as (
        select max(partition_date) as latest_date
        from {{ source("staging", "vehicle") }}
    ),

    source as (
        select *
        from {{ source("staging", "vehicle") }}
        where partition_date = (select latest_date from latest_partition)
    ),
    renamed as (
        select
            {{ adapter.quote("crash_unit_id") }} as crash_vehicle_id,
            {{ adapter.quote("crash_record_id") }} as crash_id,
            {{ adapter.quote("unit_type") }} as unit_type,
            {{ adapter.quote("num_passengers") }} as passengers_number,
            {{ adapter.quote("vehicle_id") }} as vehicle_id,
            {{ adapter.quote("make") }} as vehicle_make,
            {{ adapter.quote("model") }} as vehicle_model,
            {{ adapter.quote("lic_plate_state") }} as license_plate_state,
            {{ adapter.quote("vehicle_year") }} as vehicle_year_number,
            {{ adapter.quote("vehicle_defect") }} as vehicle_defect,
            {{ adapter.quote("vehicle_type") }} as vehicle_type,
            {{ adapter.quote("vehicle_use") }} as vehicle_use_code,
            {{ adapter.quote("travel_direction") }} as vehicle_travel_direction,
            {{ adapter.quote("maneuver") }} as vehicle_maneuver,
            {{ adapter.quote("exceed_speed_limit_i") }} as is_speeding,
            {{ adapter.quote("partition_date") }} as partition_date,
        from source
    ),

    typed as (
        select
            cast(crash_vehicle_id as string) as crash_vehicle_id,
            cast(crash_id as string) as crash_id,
            cast({{ string_empty_to_null("unit_type") }} as string) as unit_type,
            cast(passengers_number as int64) as passengers_number,
            cast(vehicle_id as int64) as vehicle_id,
            cast({{ string_empty_to_null("vehicle_make") }} as string) as vehicle_make,
            cast(
                {{ string_empty_to_null("vehicle_model") }} as string
            ) as vehicle_model,
            cast(
                upper({{ string_empty_to_null("license_plate_state") }}) as string
            ) as license_plate_state,
            cast(vehicle_year_number as int64) as vehicle_year_number,
            cast(
                {{ string_empty_to_null("vehicle_defect") }} as string
            ) as vehicle_defect,
            cast({{ string_empty_to_null("vehicle_type") }} as string) as vehicle_type,
            cast(
                {{ string_empty_to_null("vehicle_use_code") }} as string
            ) as vehicle_use_code,
            cast(
                upper({{ string_empty_to_null("vehicle_travel_direction") }}) as string
            ) as vehicle_travel_direction,
            cast(
                {{ string_empty_to_null("vehicle_maneuver") }} as string
            ) as vehicle_maneuver,
            cast({{ convert_to_boolean("is_speeding") }} as boolean) as is_speeding,
            cast(partition_date as date) as partition_date,
        from renamed
    )

select *
from typed
