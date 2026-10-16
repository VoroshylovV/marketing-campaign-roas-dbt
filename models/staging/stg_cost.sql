select
    safe.parse_date('%Y-%m-%d', date) as report_date,
    coalesce(nullif(trim(cast(campaign_id as string)), ''), 'unknown') as campaign_id,
    max(campaign) as campaign_name,
    sum(cost_usd) as spend
from {{ source('test_app_dataset', 'cost_table') }}
where date is not null
  and safe.parse_date('%Y-%m-%d', date)
      between date '{{ var("start_date") }}' and date '{{ var("end_date") }}'
group by 1, 2
