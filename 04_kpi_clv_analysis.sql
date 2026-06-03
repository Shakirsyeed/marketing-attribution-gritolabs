-- ============================================================
-- 04_kpi_clv_analysis.sql
-- KPI Deep-Dive + Customer Lifetime Value by Channel
-- Grito Labs | Multi-Channel Marketing Attribution Project
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id              VARCHAR(10) PRIMARY KEY,
    acquisition_channel      VARCHAR(20),
    first_purchase_date      DATE,
    total_purchases          INT,
    total_revenue            NUMERIC(12,2),
    avg_order_value          NUMERIC(10,2),
    customer_lifespan_months INT,
    country                  VARCHAR(5),
    age_group                VARCHAR(10),
    gender                   VARCHAR(10)
);

-- ── QUERY 1: CLV by Acquisition Channel ─────────────────────
SELECT
    acquisition_channel,
    COUNT(*)                                                            AS customers,
    ROUND(AVG(total_revenue),2)                                        AS avg_clv,
    ROUND(AVG(avg_order_value),2)                                      AS avg_aov,
    ROUND(AVG(total_purchases),1)                                      AS avg_purchases,
    ROUND(AVG(customer_lifespan_months),1)                             AS avg_lifespan_mo,
    -- CLV = AOV × Purchase Frequency × Lifespan(years)
    ROUND(AVG(avg_order_value)*AVG(total_purchases)*(AVG(customer_lifespan_months)/12.0),2) AS estimated_clv
FROM customers
GROUP BY acquisition_channel
ORDER BY estimated_clv DESC;

-- ── QUERY 2: CLV vs CAC Ratio (Profitability Check) ─────────
WITH clv AS (
    SELECT acquisition_channel,
        ROUND(AVG(avg_order_value)*AVG(total_purchases)*(AVG(customer_lifespan_months)/12.0),2) AS clv
    FROM customers GROUP BY acquisition_channel
),
cac AS (
    SELECT channel,
        ROUND(SUM(spend)/NULLIF(SUM(conversions),0),2) AS cac
    FROM campaigns GROUP BY channel
)
SELECT
    clv.acquisition_channel,
    clv.clv,
    cac.cac,
    ROUND(clv.clv / NULLIF(cac.cac,0),1)                              AS clv_cac_ratio,
    CASE
        WHEN clv.clv/NULLIF(cac.cac,0) >= 5 THEN 'Excellent 🟢'
        WHEN clv.clv/NULLIF(cac.cac,0) >= 3 THEN 'Good 🟡'
        WHEN clv.clv/NULLIF(cac.cac,0) >= 1 THEN 'Break-even 🟠'
        ELSE 'Unprofitable 🔴'
    END                                                                AS verdict
FROM clv JOIN cac ON clv.acquisition_channel = cac.channel;

-- ── QUERY 3: Top Countries by Revenue ───────────────────────
SELECT
    country,
    COUNT(*)                                                            AS customers,
    ROUND(SUM(total_revenue),2)                                        AS total_revenue,
    ROUND(AVG(avg_order_value),2)                                      AS avg_aov
FROM customers
GROUP BY country ORDER BY total_revenue DESC;

-- ── QUERY 4: Age Group Conversion Behavior ──────────────────
SELECT
    age_group,
    acquisition_channel,
    COUNT(*)                                                            AS customers,
    ROUND(AVG(total_purchases),1)                                      AS avg_purchases,
    ROUND(AVG(total_revenue),2)                                        AS avg_revenue
FROM customers
GROUP BY age_group, acquisition_channel
ORDER BY age_group, avg_revenue DESC;

-- ── QUERY 5: High-Value Customer Segments ───────────────────
SELECT
    CASE
        WHEN total_revenue >= 1500 THEN 'VIP (>$1500)'
        WHEN total_revenue >= 800  THEN 'High ($800-1500)'
        WHEN total_revenue >= 300  THEN 'Mid ($300-800)'
        ELSE 'Low (<$300)'
    END                                                                AS segment,
    acquisition_channel,
    COUNT(*)                                                           AS customers,
    ROUND(AVG(total_revenue),2)                                        AS avg_ltv,
    ROUND(AVG(customer_lifespan_months),1)                             AS avg_lifespan
FROM customers
GROUP BY segment, acquisition_channel
ORDER BY avg_ltv DESC;
