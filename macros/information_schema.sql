{% set database = target.database %}
{% set schema = target.schema %}

select 
    table_type,
    table_schema,
    table_name,
    last_altered
from {{ database }}.information_schema.tables
where table_schema = upper('{{schema}}')
order by last_altered desc




SELECT * FROM `dbt-projectname.dbt_cmp95.`.INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbt_cmp95'
