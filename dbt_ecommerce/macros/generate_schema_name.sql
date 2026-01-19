{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    
    {%- elif custom_schema_name == 'staging' -%}
        {# Pour staging, garde le préfixe pour compatibilité avec Phase 2 #}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    
    {%- else -%}
        {# Pour les autres (intermediate, marts), pas de préfixe #}
        {{ custom_schema_name | trim }}
    
    {%- endif -%}

{%- endmacro %}