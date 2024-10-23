-- Checks if the combination of record id for the raw table and parition date is unique
{% test unique_id_partition(model, column_name) %}

    with
        validation_cols as (
            select {{ column_name }} as record_id, partition_date from {{ model }}
        ),

        validation_errors as (
            select *, count(*) as record_count
            from validation_cols
            group by partition_date, record_id
            having count(*) > 1
        )

    select *
    from validation_errors

{% endtest %}
