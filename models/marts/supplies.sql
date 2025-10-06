with

supplies as (

    SELECT * FROM {{ ref('stg_supplies') }}

)

select * From supplies
