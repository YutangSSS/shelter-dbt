# shelter-dbt

Shelter intake and outcome records modelled in dbt on DuckDB: raw CSVs → two staging models → one fact table
of stays, with data tests on every rule that matters.

```
data/aac_intakes.csv  ──► stg_intakes   ─┐
                                         ├──► fct_stays  (one row per stay: intake + the outcome that closed it)
data/aac_outcomes.csv ──► stg_outcomes  ─┘
```

## Run it

```bash
uv run python scripts/fetch_data.py      # public data, pinned revision, SHA-256 checked
uv run dbt build --profiles-dir .        # builds 3 models and runs every test
```

Result on the real data: `PASS=18 WARN=1 ERROR=0`.

## What the models decide

- **Duplicates.** 27 intake rows and 10 outcome rows are exact duplicates. Each is kept once, *before* ids are
  numbered, so ids don't depend on which copy survived.
- **Pairing.** Each intake is closed by the first outcome at or after it and before the animal's next intake.
- **Missing outcomes.** If an animal comes back with no outcome recorded, the earlier stay is closed at the new
  intake as "Not recorded" (29 stays), so an animal is never in care twice at once.
- **Categories.** Found location becomes a region type (City of Austin / Rest of Travis County / Outside
  jurisdiction); intake type becomes a custody group.

## Tests

| Test | What it catches |
|---|---|
| unique / not null keys | duplicate or missing ids |
| accepted values | a new region or custody category appearing silently |
| relationships | a stay pointing to an intake that doesn't exist |
| `non_negative` (custom generic test) | an outcome paired before its intake |
| `assert_no_overlapping_stays` | the same animal in care twice at one moment |
| `assert_matches_harness_fingerprint` | any change at all to `fct_stays` (see below) |
| `assert_every_long_open_stay_is_reported` (warn) | lists the 311 stays open over 180 days, probably missing an outcome |

**The fingerprint test.** The same models are written in plain SQL in
[metric-report-harness](https://github.com/YutangSSS/metric-report-harness), which produces the reports.
This test is an MD5 over every column of every row of `fct_stays` (80,160 rows). It matches the harness's
table exactly. Changing one `>=` to `>` in the pairing rule makes it fail.

## Data

Austin Animal Center intakes and outcomes (80,187 intakes, Oct 2013 to Mar 2018), City of Austin open data, mirrored on Hugging Face as
[jason1966/aaronschlegel_austin-animal-center-shelter-intakes-and-outcomes](https://huggingface.co/datasets/jason1966/aaronschlegel_austin-animal-center-shelter-intakes-and-outcomes).
