# 📂 Data Schema & Dictionary

## campaigns.csv (128 rows)
| Column | Type | Description |
|--------|------|-------------|
| campaign_id | string | Unique ID (C001–C128) |
| channel | string | Email / Paid_Ad / Social / Organic |
| campaign_name | string | Campaign name + quarter |
| start_date | date | Campaign start |
| end_date | date | Campaign end |
| spend | float | Ad spend in USD |
| impressions | int | Total impressions |
| clicks | int | Total clicks |
| conversions | int | Total purchases |
| revenue | float | Revenue generated (USD) |

## customers.csv (500 rows)
| Column | Type | Description |
|--------|------|-------------|
| customer_id | string | Unique ID (CUST0001–CUST0500) |
| acquisition_channel | string | Channel that first acquired customer |
| first_purchase_date | date | Date of first purchase |
| total_purchases | int | Lifetime purchase count |
| total_revenue | float | Lifetime revenue (USD) |
| avg_order_value | float | Average order value |
| customer_lifespan_months | int | Customer tenure in months |
| country | string | US/UK/IN/CA/AU/DE/FR/SG |
| age_group | string | 18-24 / 25-34 / 35-44 / 45-54 / 55+ |
| gender | string | M / F / Other |

## touchpoints.csv (1,236 rows)
| Column | Type | Description |
|--------|------|-------------|
| touchpoint_id | string | Unique ID (T00001–T01236) |
| customer_id | string | Links to customers table |
| channel | string | Channel of this interaction |
| campaign_id | string | Campaign driving this touch |
| touchpoint_date | datetime | Timestamp of interaction |
| is_conversion | bool | True if purchase occurred |
| revenue | float | Order value (0 if no conversion) |
| device | string | Mobile / Desktop / Tablet |
| session_duration_sec | int | Session length in seconds |
