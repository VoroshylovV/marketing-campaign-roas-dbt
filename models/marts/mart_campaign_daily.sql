with all_keys as (
    select report_date, campaign_id from {{ ref('stg_cost') }}
    union distinct
    select report_date, campaign_id from {{ ref('stg_installs') }}
    union distinct
    select report_date, campaign_id from {{ ref('stg_ad_revenue') }}
    union distinct
    select report_date, campaign_id from {{ ref('stg_purchase_revenue') }}
),

final_base as (
    select
        k.report_date,
        k.campaign_id,
        coalesce(c.campaign_name, i.campaign_name, a.campaign_name,
                 p.campaign_name, 'Unknown Campaign') as campaign_name,
        coalesce(c.spend, 0) as spend,
        coalesce(i.installs, 0) as installs,
        coalesce(a.ad_revenue, 0) as ad_revenue,
        coalesce(p.purchase_revenue, 0) as purchase_revenue
    from all_keys k
    left join {{ ref('stg_cost') }} c
        on k.report_date = c.report_date and k.campaign_id = c.campaign_id
    left join {{ ref('stg_installs') }} i
        on k.report_date = i.report_date and k.campaign_id = i.campaign_id
    left join {{ ref('stg_ad_revenue') }} a
        on k.report_date = a.report_date and k.campaign_id = a.campaign_id
    left join {{ ref('stg_purchase_revenue') }} p
        on k.report_date = p.report_date and k.campaign_id = p.campaign_id
)

select
    report_date,
    campaign_id,
    campaign_name,
    spend,
    installs,
    ad_revenue,
    purchase_revenue,
    ad_revenue + purchase_revenue as total_revenue,
    ad_revenue + purchase_revenue - spend as profit,
    round(safe_divide(spend, installs), 2) as cpi,
    round(safe_divide(ad_revenue + purchase_revenue, spend) * 100, 2) as roas_percent
from final_base
