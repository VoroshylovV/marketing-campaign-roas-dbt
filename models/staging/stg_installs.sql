select
    date(install_date) as report_date,
    coalesce(nullif(trim(cast(campaign_id as string)), ''), 'unknown') as campaign_id,
    max(campaign_name) as campaign_name,
    count(distinct advertising_id) as installs
from {{ source('test_app_dataset', 'non_org_installs_report') }}
where install_date is not null
  and date(install_date)
      between date '{{ var("start_date") }}' and date '{{ var("end_date") }}'
group by 1, 2
