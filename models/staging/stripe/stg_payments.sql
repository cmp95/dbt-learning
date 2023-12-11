with
source as (
    select * from {{ source('stripe', 'payment')}}
),

staged as (
    select
    *
    from source
)

select * from staged