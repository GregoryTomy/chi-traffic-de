{% macro convert_to_boolean(column_name) %}
    case lower({{ column_name }}) when 'y' then true when 'n' then false else null end
{% endmacro %}
