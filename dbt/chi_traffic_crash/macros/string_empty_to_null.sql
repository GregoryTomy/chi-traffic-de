{% macro string_empty_to_null(column_name) %}
    nullif({{ column_name }}, '')

{% endmacro %}
