-- ============================================================
-- 01_channel_performance.sql
-- Channel-Level Performance & ROI Analysis
-- Grito Labs | Multi-Channel Marketing Attribution Project
-- ============================================================

-- ── TABLE SETUP ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id    VARCHAR(10)  PRIMARY KEY,
    channel        VARCHAR(20)  NOT NULL,
    campaign_name  VARCHAR(100),
    start_date     DATE,
    end_date       DATE,
    spend          NUMERIC(12,2),
    impressions    BIGINT,
    clicks         INT,
    conversions    INT,
    revenue        NUMERIC(12,2)
);

-- ── QUERY 1: Channel KPI Summary ────────────────────────────
-- Shows CTR, CPC, CVR, CPA, ROAS, ROI per channel
SELECT
    channel,
    COUNT(*)                                                            AS campaigns,
    SUM(spend)                                                          AS total_spend,
    SUM(impressions)                                                    AS total_impressions,
    SUM(clicks)                                                         AS total_clicks,
    SUM(conversions)                                                    AS total_conversions,
    SUM(revenue)                                                        AS total_revenue,
    ROUND(SUM(clicks)*100.0/NULLIF(SUM(impressions),0),2)              AS ctr_pct,
    ROUND(SUM(spend)/NULLIF(SUM(clicks),0),2)                          AS cpc,
    ROUND(SUM(conversions)*100.0/NULLIF(SUM(clicks),0),2)              AS cvr_pct,
    ROUND(SUM(spend)/NULLIF(SUM(conversions),0),2)                     AS cpa,
    ROUND(SUM(revenue)/NULLIF(SUM(spend),0),2)                         AS roas,
    ROUND((SUM(revenue)-SUM(spend))*100.0/NULLIF(SUM(spend),0),1)      AS roi_pct,
    SUM(revenue)-SUM(spend)                                             AS net_profit
FROM campaigns
GROUP BY channel
ORDER BY roas DESC;

-- ── QUERY 2: Spend Share vs Revenue Share ───────────────────
SELECT
    channel,
    ROUND(SUM(spend)*100.0/(SELECT SUM(spend) FROM campaigns),1)       AS spend_share_pct,
    ROUND(SUM(revenue)*100.0/(SELECT SUM(revenue) FROM campaigns),1)   AS revenue_share_pct,
    ROUND(
        (SUM(revenue)*100.0/(SELECT SUM(revenue) FROM campaigns)) /
        NULLIF(SUM(spend)*100.0/(SELECT SUM(spend) FROM campaigns),0)
    ,2)                                                                 AS efficiency_ratio
FROM campaigns
GROUP BY channel
ORDER BY efficiency_ratio DESC;

-- ── QUERY 3: Quarterly Revenue Trend ────────────────────────
SELECT
    channel,
    EXTRACT(QUARTER FROM start_date)                                    AS quarter,
    SUM(spend)                                                          AS spend,
    SUM(revenue)                                                        AS revenue,
    ROUND(SUM(revenue)/NULLIF(SUM(spend),0),2)                         AS roas
FROM campaigns
GROUP BY channel, EXTRACT(QUARTER FROM start_date)
ORDER BY channel, quarter;

-- ── QUERY 4: Performance Tier Labeling ──────────────────────
SELECT
    campaign_id, channel, campaign_name, spend, revenue,
    ROUND(revenue/NULLIF(spend,0),2)                                    AS roas,
    CASE
        WHEN revenue/NULLIF(spend,0) >= 6   THEN 'Elite 🟢'
        WHEN revenue/NULLIF(spend,0) >= 4   THEN 'Strong 🟡'
        WHEN revenue/NULLIF(spend,0) >= 2   THEN 'Average 🟠'
        ELSE                                     'Underperforming 🔴'
    END                                                                 AS tier,
    RANK() OVER (PARTITION BY channel ORDER BY revenue/NULLIF(spend,0) DESC) AS rank_in_channel
FROM campaigns
ORDER BY roas DESC;
