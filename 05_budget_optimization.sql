-- ============================================================
-- 05_budget_optimization.sql
-- Budget Reallocation & Optimization Queries
-- Grito Labs | Multi-Channel Marketing Attribution Project
-- ============================================================

-- ── QUERY 1: ROAS-Weighted Budget Recommendation ────────────
WITH metrics AS (
    SELECT
        channel,
        SUM(spend)                                             AS cur_spend,
        SUM(revenue)                                           AS cur_revenue,
        ROUND(SUM(revenue)/NULLIF(SUM(spend),0),3)            AS roas
    FROM campaigns GROUP BY channel
),
total AS (SELECT SUM(cur_spend) AS budget FROM metrics)
SELECT
    m.channel,
    m.cur_spend,
    ROUND(m.cur_spend*100.0/t.budget,1)                        AS current_pct,
    m.roas,
    ROUND(m.roas*100.0/SUM(m.roas) OVER(),1)                   AS recommended_pct,
    ROUND(t.budget * m.roas/SUM(m.roas) OVER(),2)              AS recommended_spend,
    ROUND(t.budget * m.roas/SUM(m.roas) OVER() - m.cur_spend,2) AS delta,
    CASE
        WHEN t.budget * m.roas/SUM(m.roas) OVER() > m.cur_spend THEN '▲ Increase'
        ELSE '▼ Decrease'
    END                                                        AS action
FROM metrics m CROSS JOIN total t
ORDER BY recommended_pct DESC;

-- ── QUERY 2: Simulate +10% Email / -10% Paid_Ad ─────────────
WITH base AS (
    SELECT channel,
        SUM(spend)   AS spend,
        SUM(revenue) AS revenue,
        ROUND(SUM(revenue)/NULLIF(SUM(spend),0),2) AS roas
    FROM campaigns GROUP BY channel
)
SELECT
    channel,
    spend                                                      AS current_spend,
    CASE channel WHEN 'Email'   THEN ROUND(spend*1.10,2)
                 WHEN 'Paid_Ad' THEN ROUND(spend*0.90,2)
                 ELSE spend END                                AS simulated_spend,
    revenue                                                    AS current_revenue,
    CASE channel WHEN 'Email'   THEN ROUND(revenue*1.10,2)
                 WHEN 'Paid_Ad' THEN ROUND(revenue*0.85,2)
                 ELSE revenue END                              AS simulated_revenue,
    roas
FROM base
UNION ALL
SELECT 'TOTAL',
    SUM(spend), SUM(CASE channel WHEN 'Email' THEN spend*1.10
                                 WHEN 'Paid_Ad' THEN spend*0.90 ELSE spend END),
    SUM(revenue), SUM(CASE channel WHEN 'Email' THEN revenue*1.10
                                   WHEN 'Paid_Ad' THEN revenue*0.85 ELSE revenue END),
    ROUND(SUM(CASE channel WHEN 'Email' THEN revenue*1.10
                           WHEN 'Paid_Ad' THEN revenue*0.85 ELSE revenue END)/
          NULLIF(SUM(CASE channel WHEN 'Email' THEN spend*1.10
                                  WHEN 'Paid_Ad' THEN spend*0.90 ELSE spend END),0),2)
FROM base;

-- ── QUERY 3: Underperforming Campaigns — Pause or Optimize ──
SELECT
    campaign_id, channel, campaign_name, spend, revenue,
    ROUND(revenue/NULLIF(spend,0),2)           AS roas,
    ROUND(spend/NULLIF(conversions,0),2)        AS cpa,
    CASE
        WHEN revenue/NULLIF(spend,0) < 2   THEN '🔴 PAUSE'
        WHEN revenue/NULLIF(spend,0) < 3.5 THEN '🟠 OPTIMIZE'
        WHEN revenue/NULLIF(spend,0) < 5   THEN '🟡 MAINTAIN'
        ELSE                                    '🟢 SCALE UP'
    END                                        AS recommendation
FROM campaigns
ORDER BY roas ASC;

-- ── QUERY 4: Projected Revenue Post-Reallocation ────────────
WITH roas_wt AS (
    SELECT channel,
        ROUND(AVG(revenue/NULLIF(spend,0)),3) AS avg_roas
    FROM campaigns GROUP BY channel
),
total_budget AS (SELECT SUM(spend) AS b FROM campaigns)
SELECT
    r.channel,
    ROUND(tb.b * r.avg_roas/SUM(r.avg_roas) OVER(),2)         AS new_spend,
    r.avg_roas,
    ROUND(tb.b * r.avg_roas/SUM(r.avg_roas) OVER() * r.avg_roas,2) AS projected_revenue,
    ROUND((r.avg_roas - 1)*100,1)                              AS projected_roi_pct
FROM roas_wt r CROSS JOIN total_budget tb
ORDER BY projected_revenue DESC;
