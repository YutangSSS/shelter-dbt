-- Warn (not fail) on stays open longer than the threshold at the data cut: they are probably missing an outcome.
{{ config(severity = 'warn') }}
select stay_id, animal_id, intake_dt
from {{ ref('fct_stays') }}
where outcome_dt is null
  and intake_dt < (select max(intake_dt) from {{ ref('fct_stays') }}) - interval {{ var('long_open_days') }} day
