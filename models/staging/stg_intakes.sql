-- One row per intake event. Same rules as models/01_stg_intakes.sql in the Python harness;
-- tests/test_dbt.py checks the two give identical tables.
with raw as (
    select animal_id, datetime::timestamp as datetime, intake_type, intake_condition, animal_type, found_location
    from read_csv_auto('{{ var("data_dir") }}/aac_intakes.csv', header = true)
),
deduped as (
    select * from raw
    qualify row_number() over (partition by animal_id, datetime order by found_location, intake_type) = 1
)
select
    row_number() over (order by animal_id, datetime) as intake_id,
    animal_id,
    datetime as intake_dt,
    intake_type,
    intake_condition,
    animal_type,
    found_location,
    case
        when found_location = 'Outside Jurisdiction' then 'Outside jurisdiction'
        when found_location like '%Austin (TX)' and found_location not like '%Travis (TX)' then 'City of Austin'
        else 'Rest of Travis County'
    end as region_type,
    case intake_type
        when 'Stray' then 'Stray hold'
        when 'Owner Surrender' then 'Owner surrender'
        when 'Public Assist' then 'Public assist'
        else 'Other'
    end as custody_group
from deduped
