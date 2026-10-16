select 1 as mismatch
from (
  select
    (select sum(spend) from {{ ref('stg_cost') }}) as s1,
    (select sum(spend) from {{ ref('mart_campaign_daily') }}) as s2,
    (select sum(ad_revenue) from {{ ref('stg_ad_revenue') }}) as a1,
    (select sum(ad_revenue) from {{ ref('mart_campaign_daily') }}) as a2,
    (select sum(purchase_revenue) from {{ ref('stg_purchase_revenue') }}) as p1,
    (select sum(purchase_revenue) from {{ ref('mart_campaign_daily') }}) as p2,
    (select sum(installs) from {{ ref('stg_installs') }}) as i1,
    (select sum(installs) from {{ ref('mart_campaign_daily') }}) as i2
)
where abs(s1 - s2) > 0.01 or abs(a1 - a2) > 0.01
   or abs(p1 - p2) > 0.01 or i1 != i2
