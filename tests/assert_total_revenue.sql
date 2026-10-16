select *
from {{ ref('mart_campaign_daily') }}
where abs(total_revenue - (ad_revenue + purchase_revenue)) > 0.000001
