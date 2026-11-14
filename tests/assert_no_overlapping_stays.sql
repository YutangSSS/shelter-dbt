-- An animal cannot be in care twice at the same moment.
select a.animal_id, a.stay_id, b.stay_id as overlapping_stay_id
from {{ ref('fct_stays') }} a
join {{ ref('fct_stays') }} b
  on a.animal_id = b.animal_id
 and a.stay_id < b.stay_id
 and b.intake_dt < coalesce(a.outcome_dt, timestamp '9999-12-31')
 and a.intake_dt < coalesce(b.outcome_dt, timestamp '9999-12-31')
