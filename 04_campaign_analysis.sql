-- ==============================================================
-- 04_campaign_analysis.sql
-- Campaign Scorecard + CLV by Acquisition Channel
-- ==============================================================

-- ── QUERY 1: Full Campaign Scorecard ──────────────────────────
SELECT
    campaign_id, channel, campaign_name,
    spend, impressions, clicks, conversions, revenue,
    ROUND(clicks*100.0       / NULLIF(impressions,0), 2)                   AS ctr_pct,
    ROUND(spend              / NULLIF(clicks,0), 2)                        AS cpc,
    ROUND(conversions*100.0  / NULLIF(clicks,0), 2)                        AS cvr_pct,
    ROUND(spend              / NULLIF(conversions,0), 2)                   AS cpa,
    ROUND(revenue            / NULLIF(spend,0), 2)                         AS roas,
    ROUND((revenue-spend)*100.0 / NULLIF(spend,0), 1)                     AS roi_pct,
    (revenue - spend)                                                       AS net_profit,
    CASE
        WHEN revenue/NULLIF(spend,0) >= 6 THEN 'Elite ✅'
        WHEN revenue/NULLIF(spend,0) >= 4 THEN 'Strong 🟡'
        WHEN revenue/NULLIF(spend,0) >= 2 THEN 'Average 🟠'
        ELSE 'Underperforming ❌'
    END                                                                     AS tier
FROM campaigns
ORDER BY roas DESC;

-- ── QUERY 2: Top 3 & Bottom 3 by ROAS ────────────────────────
SELECT 'TOP' AS rank_type, campaign_id, channel, campaign_name,
       ROUND(revenue/NULLIF(spend,0),2) AS roas, (revenue-spend) AS net_profit
FROM campaigns ORDER BY roas DESC LIMIT 3;

SELECT 'BOTTOM' AS rank_type, campaign_id, channel, campaign_name,
       ROUND(revenue/NULLIF(spend,0),2) AS roas, (revenue-spend) AS net_profit
FROM campaigns ORDER BY roas ASC LIMIT 3;

-- ── QUERY 3: CLV by Acquisition Channel ───────────────────────
SELECT
    acquisition_channel,
    COUNT(customer_id)                                                      AS customers,
    ROUND(AVG(total_revenue),   2)                                          AS avg_clv,
    ROUND(AVG(avg_order_value), 2)                                          AS avg_aov,
    ROUND(AVG(total_purchases), 1)                                          AS avg_purchases,
    ROUND(AVG(customer_lifespan_months), 1)                                 AS avg_lifespan_months,
    -- CLV Formula: AOV × Purchase Frequency × Lifespan (years)
    ROUND(AVG(avg_order_value) * AVG(total_purchases)
          * (AVG(customer_lifespan_months)/12.0), 2)                        AS estimated_clv
FROM customers
GROUP BY acquisition_channel
ORDER BY estimated_clv DESC;

-- ── QUERY 4: CAC vs CLV Health Check ─────────────────────────
WITH channel_cac AS (
    SELECT channel,
           ROUND(SUM(spend)/NULLIF(SUM(conversions),0), 2) AS cac
    FROM campaigns GROUP BY channel
),
channel_clv AS (
    SELECT acquisition_channel AS channel,
           ROUND(AVG(avg_order_value)*AVG(total_purchases)
                 *(AVG(customer_lifespan_months)/12.0), 2)  AS clv
    FROM customers GROUP BY acquisition_channel
)
SELECT
    cc.channel, cc.cac, cv.clv,
    ROUND(cv.clv / NULLIF(cc.cac, 0), 1)                                   AS clv_to_cac_ratio,
    CASE
        WHEN cv.clv / NULLIF(cc.cac,0) >= 3 THEN 'Healthy ✅ (>3x)'
        WHEN cv.clv / NULLIF(cc.cac,0) >= 1 THEN 'Marginal ⚠️ (1-3x)'
        ELSE 'Unprofitable ❌ (<1x)'
    END                                                                     AS health_status
FROM channel_cac cc
JOIN channel_clv cv ON cc.channel = cv.channel
ORDER BY clv_to_cac_ratio DESC;
