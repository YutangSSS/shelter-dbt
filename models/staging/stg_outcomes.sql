with raw as (
    select animal_id, datetime::timestamp as datetime, outcome_type, outcome_subtype
    from read_csv_auto('{{ var("data_dir") }}/aac_outcomes.csv', header = true)
),
deduped as (
    select * from raw
    qualify row_number() over (partition by animal_id, datetime, outcome_type order by outcome_subtype nulls last) = 1
)
select
    row_number() over (order by animal_id, datetime, outcome_type) as outcome_id,
    animal_id,
    datetime as outcome_dt,
    coalesce(outcome_type, 'Unknown') as outcome_type,
    outcome_subtype,
    outcome_type in ('Died', 'Euthanasia') as deceased
from deduped
