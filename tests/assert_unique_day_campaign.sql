select report_date, campaign_id, count(*) as n
from {{ ref('mart_campaign_daily') }}
group by 1, 2
having count(*) > 1
