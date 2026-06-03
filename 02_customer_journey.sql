-- ============================================================
-- 02_customer_journey.sql
-- Customer Journey & Conversion Path Analysis
-- Grito Labs | Multi-Channel Marketing Attribution Project
-- ============================================================

CREATE TABLE IF NOT EXISTS touchpoints (
    touchpoint_id        VARCHAR(10)  PRIMARY KEY,
    customer_id          VARCHAR(10),
    channel              VARCHAR(20),
    campaign_id          VARCHAR(10),
    touchpoint_date      TIMESTAMP,
    is_conversion        BOOLEAN,
    revenue              NUMERIC(10,2),
    device               VARCHAR(10),
    session_duration_sec INT
);

-- ── QUERY 1: Full Journey Per Customer ──────────────────────
SELECT
    customer_id,
    STRING_AGG(channel, ' → ' ORDER BY touchpoint_date)                AS journey_path,
    COUNT(*)                                                            AS touchpoints,
    MIN(touchpoint_date)::DATE                                         AS first_touch_date,
    MAX(touchpoint_date)::DATE                                         AS conversion_date,
    EXTRACT(DAY FROM MAX(touchpoint_date)-MIN(touchpoint_date))        AS days_to_convert,
    MAX(CASE WHEN is_conversion THEN revenue ELSE 0 END)               AS order_value
FROM touchpoints
GROUP BY customer_id
ORDER BY order_value DESC
LIMIT 20;

-- ── QUERY 2: Top Conversion Paths ───────────────────────────
WITH journeys AS (
    SELECT
        customer_id,
        STRING_AGG(channel,' → ' ORDER BY touchpoint_date)             AS path,
        MAX(CASE WHEN is_conversion THEN revenue ELSE 0 END)           AS revenue,
        COUNT(*)                                                        AS steps
    FROM touchpoints
    GROUP BY customer_id
)
SELECT
    path,
    COUNT(*)                                                            AS frequency,
    ROUND(AVG(revenue),2)                                              AS avg_order_value,
    SUM(revenue)                                                        AS total_revenue,
    ROUND(AVG(steps),1)                                                AS avg_steps,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)                       AS path_share_pct
FROM journeys
GROUP BY path
ORDER BY frequency DESC
LIMIT 10;

-- ── QUERY 3: First-Touch Channel (Awareness) ────────────────
WITH first AS (
    SELECT DISTINCT ON (customer_id)
        customer_id, channel AS first_channel
    FROM touchpoints
    ORDER BY customer_id, touchpoint_date ASC
),
conv AS (
    SELECT customer_id, SUM(revenue) AS revenue
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
)
SELECT
    f.first_channel,
    COUNT(DISTINCT f.customer_id)                                       AS customers,
    ROUND(SUM(c.revenue),2)                                            AS attributed_revenue,
    ROUND(AVG(c.revenue),2)                                            AS avg_order_value
FROM first f JOIN conv c USING(customer_id)
GROUP BY f.first_channel ORDER BY customers DESC;

-- ── QUERY 4: Device Breakdown on Conversion ─────────────────
SELECT
    device,
    COUNT(*)                                                            AS conversions,
    ROUND(SUM(revenue),2)                                              AS total_revenue,
    ROUND(AVG(revenue),2)                                              AS avg_order_value,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)                       AS share_pct
FROM touchpoints
WHERE is_conversion = TRUE
GROUP BY device ORDER BY conversions DESC;

-- ── QUERY 5: Avg Journey Length by Channel (Last Touch) ─────
WITH last AS (
    SELECT DISTINCT ON (customer_id)
        customer_id, channel AS closing_channel
    FROM touchpoints
    ORDER BY customer_id, touchpoint_date DESC
),
lengths AS (
    SELECT customer_id, COUNT(*) AS steps
    FROM touchpoints GROUP BY customer_id
)
SELECT
    l.closing_channel,
    COUNT(DISTINCT l.customer_id)                                       AS conversions,
    ROUND(AVG(ln.steps),1)                                             AS avg_journey_steps
FROM last l JOIN lengths ln USING(customer_id)
GROUP BY l.closing_channel ORDER BY conversions DESC;
