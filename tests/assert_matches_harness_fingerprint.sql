-- fct_stays must be identical, row for row and column for column, to the one built by
-- metric-report-harness (models/03_fct_stays.sql). The fingerprint is an MD5 over every column of every
-- row in stay_id order, captured from the harness on 2026-11-13. Any change to a rule changes it.
with f as (
    select count(*) as n_rows,
           md5(string_agg(concat_ws('|', stay_id, animal_id, intake_seq, is_repeat_intake, intake_dt, intake_type,
                                    intake_condition, animal_type, region_type, custody_group, outcome_id, outcome_dt,
                                    outcome_type, outcome_subtype, deceased, days_in_care), chr(10) order by stay_id)) as md5
    from {{ ref('fct_stays') }}
)
select * from f
where n_rows <> 80160 or md5 <> 'd11c6b0d4adcce4aa79c0bcdeadddbac'
