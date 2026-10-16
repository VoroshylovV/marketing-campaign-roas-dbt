# Mornhouse campaign profitability: dbt + BigQuery

A small dbt project that rebuilds a marketing profitability mart (spend, installs, ad and purchase revenue, profit, CPI, ROAS by campaign and day) from four raw BigQuery tables. It started as a single ~100-line ad-hoc SQL query and is now a tested, layered dbt project.

## Data
Source: `mornhouse-test-environment.test_app_dataset` (public test dataset). Period in the data: 2026-06-01 to 2026-07-26.

- `cost_table`: ad spend
- `non_org_installs_report`: installs
- `ad_revenue_raw`: ad revenue
- `in_app_events_report`: in-app purchases

## Structure
- `models/staging`: one view per source table (typing, trimming, aggregation to day x campaign)
- `models/marts/mart_campaign_daily`: final table, one row per day and campaign
- `tests`: singular tests (grain uniqueness, revenue arithmetic, source-to-mart reconciliation)
- `models/marts/schema.yml`: column tests

Run: `dbt run` then `dbt test`.

## Data quality finding
The original ad-hoc query joined four tables on `campaign_id`. In the revenue and install tables part of the rows have an empty `campaign_id`, and in SQL `NULL = NULL` never matches, so those rows were silently dropped from the result. The dbt `not_null` test on `campaign_id` flagged 56 rows (one per day), and a reconciliation of source totals against the mart showed the loss:

| Metric | Source | Old mart | Lost |
|---|---|---|---|
| Spend | 20,575.41 | 20,575.41 | 0% |
| Ad revenue | 14,765.86 | 13,638.01 | 7.6% |
| Purchase revenue | 62,503.04 | 43,828.48 | 29.9% |
| Installs | 482,242 | 302,641 | 37.2% |

Fix: in staging, empty IDs are replaced with `'unknown'` so the rows join. After the fix all totals match, and the test `assert_reconciliation` fails the build if any metric drifts again.

Impact: blended ROAS on the full period moves from about 279% to about 375%. Revenue and installs without a campaign ID have zero spend, so CPI and ROAS for the `unknown` bucket are empty by design.

## Notes
- Metrics use `safe_divide`, so zero spend or zero installs gives NULL instead of an error.
- Very high ROAS values on campaigns with near-zero spend are an artifact of division by a tiny number. A minimum-spend threshold would be a sensible next step.
- Runs on dbt Core with the BigQuery adapter (oauth auth). Dataset `dbt_mornhouse`, location US.
