-- ============================================================
-- 03_attribution_models.sql
-- 4 Attribution Models: First-Touch, Last-Touch, Linear, Time-Decay
-- Grito Labs | Multi-Channel Marketing Attribution Project
-- ============================================================

-- ── MODEL 1: FIRST-TOUCH ────────────────────────────────────
WITH first AS (
    SELECT DISTINCT ON (customer_id)
        customer_id, channel
    FROM touchpoints ORDER BY customer_id, touchpoint_date ASC
),
conv AS (
    SELECT customer_id, SUM(revenue) AS rev
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
)
SELECT
    'First-Touch'                                                       AS model,
    f.channel,
    COUNT(DISTINCT f.customer_id)                                       AS customers,
    ROUND(SUM(c.rev),2)                                                AS attributed_revenue,
    ROUND(SUM(c.rev)*100.0/SUM(SUM(c.rev)) OVER(),1)                   AS revenue_share_pct
FROM first f JOIN conv c USING(customer_id)
GROUP BY f.channel ORDER BY attributed_revenue DESC;

-- ── MODEL 2: LAST-TOUCH ─────────────────────────────────────
WITH last AS (
    SELECT DISTINCT ON (customer_id)
        customer_id, channel
    FROM touchpoints ORDER BY customer_id, touchpoint_date DESC
),
conv AS (
    SELECT customer_id, SUM(revenue) AS rev
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
)
SELECT
    'Last-Touch'                                                        AS model,
    l.channel,
    COUNT(DISTINCT l.customer_id)                                       AS customers,
    ROUND(SUM(c.rev),2)                                                AS attributed_revenue,
    ROUND(SUM(c.rev)*100.0/SUM(SUM(c.rev)) OVER(),1)                   AS revenue_share_pct
FROM last l JOIN conv c USING(customer_id)
GROUP BY l.channel ORDER BY attributed_revenue DESC;

-- ── MODEL 3: LINEAR ─────────────────────────────────────────
WITH lengths AS (
    SELECT customer_id, COUNT(*) AS steps
    FROM touchpoints GROUP BY customer_id
),
conv AS (
    SELECT customer_id, SUM(revenue) AS rev
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
)
SELECT
    'Linear'                                                            AS model,
    t.channel,
    COUNT(DISTINCT t.customer_id)                                       AS customers,
    ROUND(SUM(c.rev / l.steps),2)                                      AS attributed_revenue,
    ROUND(SUM(c.rev / l.steps)*100.0/SUM(SUM(c.rev / l.steps)) OVER(),1) AS revenue_share_pct
FROM touchpoints t
JOIN lengths l USING(customer_id)
JOIN conv    c USING(customer_id)
GROUP BY t.channel ORDER BY attributed_revenue DESC;

-- ── MODEL 4: TIME-DECAY (λ=0.1) ─────────────────────────────
WITH conv_dates AS (
    SELECT customer_id, MAX(touchpoint_date) AS conv_dt
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
),
decay AS (
    SELECT
        t.customer_id, t.channel,
        EXP(-0.1 * EXTRACT(DAY FROM cd.conv_dt - t.touchpoint_date))   AS w
    FROM touchpoints t JOIN conv_dates cd USING(customer_id)
),
totals AS (
    SELECT customer_id, SUM(w) AS total_w FROM decay GROUP BY customer_id
),
conv AS (
    SELECT customer_id, SUM(revenue) AS rev
    FROM touchpoints WHERE is_conversion GROUP BY customer_id
)
SELECT
    'Time-Decay'                                                        AS model,
    d.channel,
    COUNT(DISTINCT d.customer_id)                                       AS customers,
    ROUND(SUM((d.w / tt.total_w) * c.rev),2)                          AS attributed_revenue,
    ROUND(SUM((d.w / tt.total_w) * c.rev)*100.0/
          SUM(SUM((d.w / tt.total_w) * c.rev)) OVER(),1)               AS revenue_share_pct
FROM decay d
JOIN totals tt USING(customer_id)
JOIN conv    c USING(customer_id)
GROUP BY d.channel ORDER BY attributed_revenue DESC;

-- ── MODEL COMPARISON SIDE-BY-SIDE ───────────────────────────
-- (Union all 4 results above to compare in one view)
-- Replace each CTE block above with a named view for production use.
