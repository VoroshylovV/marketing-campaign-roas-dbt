select
    date(event_date) as report_date,
    coalesce(nullif(trim(cast(campaign_id as string)), ''), 'unknown') as campaign_id,
    max(campaign_name) as campaign_name,
    sum(event_revenue_usd) as ad_revenue
from {{ source('test_app_dataset', 'ad_revenue_raw') }}
where event_date is not null
  and date(event_date)
      between date '{{ var("start_date") }}' and date '{{ var("end_date") }}'
group by 1, 2
