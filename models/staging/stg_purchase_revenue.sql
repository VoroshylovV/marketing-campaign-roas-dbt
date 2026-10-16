select
    date(event_date) as report_date,
    coalesce(nullif(trim(cast(campaign_id as string)), ''), 'unknown') as campaign_id,
    max(campaign_name) as campaign_name,
    sum(event_revenue_usd) as purchase_revenue
from {{ source('test_app_dataset', 'in_app_events_report') }}
where event_date is not null
  and date(event_date)
      between date '{{ var("start_date") }}' and date '{{ var("end_date") }}'
  and event_revenue_usd > 0
group by 1, 2
